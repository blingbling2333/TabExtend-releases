import hashlib
import http.server
import json
import os
from pathlib import Path
import socketserver
import subprocess
import tempfile
import threading
import unittest
import zipfile


def make_extension_zip(dest: Path, version: str, extra_files: dict[str, str] | None = None) -> str:
    manifest = {
        "manifest_version": 3,
        "name": "TabNav",
        "version": version,
    }
    with zipfile.ZipFile(dest, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("manifest.json", json.dumps(manifest))
        zf.writestr("newtab.html", f"<!doctype html><title>TabNav {version}</title>")
        for rel, body in (extra_files or {}).items():
            zf.writestr(rel, body)
    return hashlib.sha256(dest.read_bytes()).hexdigest()


class MockGitHubServer:
    def __init__(self, root: Path):
        self.root = root
        self.routes: dict[str, tuple[int, bytes, str]] = {}
        server_ref = self

        class Handler(http.server.BaseHTTPRequestHandler):
            def _handle(self, send_body: bool):
                entry = server_ref.routes.get(self.path)
                if entry is None:
                    self.send_response(404)
                    self.end_headers()
                    return
                code, payload, ctype = entry
                self.send_response(code)
                if code in (301, 302, 307, 308):
                    self.send_header("Location", payload.decode("utf-8"))
                    self.end_headers()
                    return
                self.send_header("Content-Type", ctype)
                self.send_header("Content-Length", str(len(payload)))
                self.end_headers()
                if send_body:
                    self.wfile.write(payload)

            def do_GET(self):
                self._handle(True)

            def do_HEAD(self):
                self._handle(False)

            def log_message(self, format, *args):
                return

        self.httpd = socketserver.TCPServer(("127.0.0.1", 0), Handler)
        self.port = self.httpd.server_address[1]
        self.thread = threading.Thread(target=self.httpd.serve_forever, daemon=True)
        self.thread.start()

    @property
    def base_url(self) -> str:
        return f"http://127.0.0.1:{self.port}"

    def register_release(self, version: str, zip_path: Path, sha_override: str | None = None, as_latest: bool = True):
        tag = f"v{version}"
        archive_name = f"tabnav-{tag}.zip"
        sha_name = f"{archive_name}.sha256"
        actual_sha = hashlib.sha256(zip_path.read_bytes()).hexdigest()
        sha_text = f"{sha_override or actual_sha}  {archive_name}\n".encode("utf-8")

        zip_route = f"/downloads/{tag}/{archive_name}"
        sha_route = f"/downloads/{tag}/{sha_name}"
        self.routes[zip_route] = (200, zip_path.read_bytes(), "application/zip")
        self.routes[sha_route] = (200, sha_text, "text/plain")

        release_payload = json.dumps({
            "tag_name": tag,
            "html_url": f"https://github.com/blingbling2333/Open-TabExtend/releases/tag/{tag}",
            "assets": [
                {
                    "name": "v0.6.0-preview.webp",
                    "browser_download_url": f"{self.base_url}/downloads/{tag}/preview.webp",
                },
                {
                    "name": archive_name,
                    "browser_download_url": f"{self.base_url}{zip_route}",
                    "digest": f"sha256:{sha_override or actual_sha}",
                },
                {
                    "name": sha_name,
                    "browser_download_url": f"{self.base_url}{sha_route}",
                },
            ],
        }).encode("utf-8")

        self.routes[f"/repos/blingbling2333/Open-TabExtend/releases/tags/{tag}"] = (
            200, release_payload, "application/json"
        )
        if as_latest:
            self.routes["/repos/blingbling2333/Open-TabExtend/releases/latest"] = (
                200, release_payload, "application/json"
            )

    def close(self):
        self.httpd.shutdown()
        self.httpd.server_close()


class InstallScriptTests(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="tabextend-installer-test-"))
        self.server = MockGitHubServer(self.tmp)
        self.script = Path(__file__).parents[1] / "scripts/install.sh"

    def tearDown(self):
        self.server.close()
        subprocess.run(["rm", "-rf", str(self.tmp)], check=True)

    def run_installer(self, *args: str) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["TABEXTEND_API_BASE"] = self.server.base_url
        env["TABEXTEND_WEB_BASE"] = self.server.base_url
        env["TABEXTEND_REPO"] = "blingbling2333/Open-TabExtend"
        return subprocess.run(
            ["bash", str(self.script), *args],
            env=env,
            capture_output=True,
            text=True,
        )

    def test_fresh_install_and_inplace_upgrade_json(self):
        zip_v1 = self.tmp / "tabnav-v0.6.0.zip"
        sha_v1 = make_extension_zip(zip_v1, "0.6.0", {"assets/old-chunk.js": "console.log('old');"})
        self.server.register_release("0.6.0", zip_v1, as_latest=True)

        target = self.tmp / "TabExtend"
        res = self.run_installer("--dir", str(target), "--json")
        self.assertEqual(res.returncode, 0, msg=res.stderr)

        data = json.loads(res.stdout)
        self.assertEqual(data["status"], "ok")
        self.assertEqual(data["action"], "install")
        self.assertEqual(data["version"], "0.6.0")
        self.assertIsNone(data["previousVersion"])
        self.assertEqual(data["sha256"], sha_v1)
        self.assertTrue(data["sha256Verified"])
        self.assertTrue((target / "assets/old-chunk.js").is_file())

        # Now publish v0.6.5 and upgrade in-place
        zip_v2 = self.tmp / "tabnav-v0.6.5.zip"
        sha_v2 = make_extension_zip(zip_v2, "0.6.5", {"assets/new-chunk.js": "console.log('new');"})
        self.server.register_release("0.6.5", zip_v2, as_latest=True)

        res2 = self.run_installer("--dir", str(target), "--json")
        self.assertEqual(res2.returncode, 0, msg=res2.stderr)
        data2 = json.loads(res2.stdout)
        self.assertEqual(data2["action"], "upgrade")
        self.assertEqual(data2["previousVersion"], "0.6.0")
        self.assertEqual(data2["version"], "0.6.5")
        self.assertEqual(data2["sha256"], sha_v2)
        self.assertFalse((target / "assets/old-chunk.js").exists())
        self.assertTrue((target / "assets/new-chunk.js").is_file())

    def test_rejects_sha256_mismatch_without_touching_target(self):
        zip_v1 = self.tmp / "tabnav-v0.6.0.zip"
        make_extension_zip(zip_v1, "0.6.0")
        self.server.register_release("0.6.0", zip_v1, sha_override="0" * 64, as_latest=True)

        target = self.tmp / "TabExtend"
        res = self.run_installer("--dir", str(target), "--json")
        self.assertNotEqual(res.returncode, 0)
        self.assertIn("SHA-256 mismatch", res.stderr)
        self.assertFalse(target.exists())

    def test_refuses_to_wipe_unrelated_non_empty_directory(self):
        zip_v1 = self.tmp / "tabnav-v0.6.0.zip"
        make_extension_zip(zip_v1, "0.6.0")
        self.server.register_release("0.6.0", zip_v1, as_latest=True)

        target = self.tmp / "UserStuff"
        target.mkdir()
        precious = target / "notes.txt"
        precious.write_text("keep me")

        res = self.run_installer("--dir", str(target))
        self.assertNotEqual(res.returncode, 0)
        self.assertIn("does not contain manifest.json", res.stderr)
        self.assertEqual(precious.read_text(), "keep me")

    def test_pins_specific_version_without_v_prefix(self):
        zip_v1 = self.tmp / "tabnav-v0.6.0.zip"
        make_extension_zip(zip_v1, "0.6.0")
        zip_v2 = self.tmp / "tabnav-v0.6.5.zip"
        make_extension_zip(zip_v2, "0.6.5")
        self.server.register_release("0.6.0", zip_v1, as_latest=False)
        self.server.register_release("0.6.5", zip_v2, as_latest=True)

        target = self.tmp / "Pinned"
        res = self.run_installer("--dir", str(target), "--version", "0.6.0", "--json")
        self.assertEqual(res.returncode, 0, msg=res.stderr)
        self.assertEqual(json.loads(res.stdout)["version"], "0.6.0")

    def test_falls_back_to_web_redirect_when_api_is_rate_limited(self):
        zip_v1 = self.tmp / "tabnav-v0.6.0.zip"
        sha_v1 = make_extension_zip(zip_v1, "0.6.0")
        self.server.routes["/repos/blingbling2333/Open-TabExtend/releases/latest"] = (
            403, b'{"message":"API rate limit exceeded"}', "application/json"
        )
        self.server.routes["/blingbling2333/Open-TabExtend/releases/latest"] = (
            302, f"{self.server.base_url}/blingbling2333/Open-TabExtend/releases/tag/v0.6.0".encode("utf-8"), "text/plain"
        )
        self.server.routes["/blingbling2333/Open-TabExtend/releases/tag/v0.6.0"] = (
            200, b"ok", "text/html"
        )
        self.server.routes["/blingbling2333/Open-TabExtend/releases/download/v0.6.0/tabnav-v0.6.0.zip"] = (
            200, zip_v1.read_bytes(), "application/zip"
        )
        self.server.routes["/blingbling2333/Open-TabExtend/releases/download/v0.6.0/tabnav-v0.6.0.zip.sha256"] = (
            200, f"{sha_v1}  tabnav-v0.6.0.zip\n".encode("utf-8"), "text/plain"
        )

        target = self.tmp / "FallbackInstall"
        res = self.run_installer("--dir", str(target), "--json")
        self.assertEqual(res.returncode, 0, msg=res.stderr)
        data = json.loads(res.stdout)
        self.assertEqual(data["version"], "0.6.0")
        self.assertEqual(data["sha256"], sha_v1)
        self.assertTrue(data["sha256Verified"])
        self.assertTrue((target / "manifest.json").is_file())


if __name__ == "__main__":
    unittest.main()
