import json
import os
from pathlib import Path
import runpy
import unittest
from unittest.mock import patch

import test_package


class PublishingTests(unittest.TestCase):
    def setUp(self):
        self.fixture = test_package.PackageTests()
        self.fixture.setUp()
        self.addCleanup(self.fixture.doCleanups)
        self.fixture.directory = self.fixture.directory / ".release"
        self.fixture.directory.mkdir()
        self.fixture.archive = self.fixture.directory / "tabnav-v1.2.3.zip"
        self.fixture.prepare_notes()
        self.root = self.fixture.directory.parent
        self.publisher = Path(__file__).parents[1] / "scripts/publish-release.py"
        self.calls = []

    def run_publisher(self, existing=None):
        def gh(args, **kwargs):
            self.calls.append(args)
            if args[1] == "api":
                result = existing if args[-1].endswith("/tags/v1.2.3") else {"tag_name": "v1.2.2"}
                return json.dumps(result)
            return ""

        previous = Path.cwd()
        os.chdir(self.root)
        try:
            with patch("sys.argv", [str(self.publisher), "v1.2.3"]), patch.dict("os.environ", {"RUNNER_TEMP": str(self.root), "GITHUB_REPOSITORY": "blingbling2333/Open-TabExtend"}), patch("subprocess.check_output", side_effect=gh):
                runpy.run_path(str(self.publisher), run_name="__main__")
        finally:
            os.chdir(previous)

    def test_publishes_upgrade_body_and_image_attachment(self):
        self.run_publisher()
        notes = (self.root / "tabextend-release-notes.md").read_text()
        self.assertIn("Sidebar animation", notes)
        self.assertIn("chrome://extensions", notes)
        self.assertIn("INSTALL_FOR_AI.md", notes)
        self.assertIn("scripts/install.sh", notes)
        upload = next(call for call in self.calls if call[1:3] == ["release", "upload"])
        self.assertIn(".release/v1.2.2-sidebar.webp", upload)
        self.assertTrue(any(call[1:3] == ["release", "edit"] for call in self.calls))

    def test_retry_checks_published_notes_and_media_without_mutation(self):
        metadata = json.loads((self.fixture.directory / "release.json").read_text())
        existing = {
            "draft": False, "html_url": "https://example.invalid/release", "body": "## Upgrade\n\nSidebar animation\n",
            "assets": [
                {"name": metadata["archive"], "digest": f"sha256:{metadata['sha256']}"},
                {"name": metadata["archive"] + ".sha256"},
                {"name": metadata["media"][0]["name"], "digest": f"sha256:{metadata['media'][0]['sha256']}"}
            ]
        }
        self.run_publisher(existing)
        self.assertTrue(all(call[1] == "api" for call in self.calls))
        existing["assets"].pop()
        with self.assertRaisesRegex(ValueError, "screenshot"):
            self.run_publisher(existing)


if __name__ == "__main__":
    unittest.main()
