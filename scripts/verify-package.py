"""Validate an extension archive before it becomes a public release."""
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import stat
import sys
import zipfile


def verify(tag, directory=Path(".release")):
    if not re.fullmatch(r"v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)", tag):
        raise ValueError("Invalid release tag")
    version = tag[1:]
    metadata = json.loads((directory / "release.json").read_text())
    archive_name = f"tabnav-v{version}.zip"
    if metadata["version"] != version or metadata["archive"] != archive_name:
        raise ValueError("Tag and package version must match")
    if not re.fullmatch(r"[a-f0-9]{40}", metadata["sourceCommit"]):
        raise ValueError("Missing source commit provenance")
    archive = directory / archive_name
    if archive.stat().st_size > 20 * 1024 * 1024:
        raise ValueError("Unexpectedly large extension archive")
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    if digest != metadata["sha256"]:
        raise ValueError("Archive SHA-256 mismatch")
    if (directory / f"{archive_name}.sha256").read_text() != f"{digest}  {archive_name}\n":
        raise ValueError("Checksum file mismatch")

    # Older tags have installation-only notes and remain recoverable.
    if "notesSha256" in metadata:
        notes = (directory / "release-notes.md").read_bytes()
        if not notes.strip() or len(notes) > 48 * 1024 or hashlib.sha256(notes).hexdigest() != metadata["notesSha256"]:
            raise ValueError("Invalid upgrade notes or checksum")
    elif metadata.get("media"):
        raise ValueError("Screenshots require upgrade notes")
    seen = set()
    total = 0
    for item in metadata.get("media", []):
        name = item["name"]
        if not re.fullmatch(r"v\d+\.\d+\.\d+-[a-zA-Z0-9][a-zA-Z0-9_-]*\.(webp|png|jpg|gif)", name) or name in seen:
            raise ValueError("Invalid or duplicate screenshot name")
        seen.add(name)
        content = (directory / name).read_bytes()
        total += len(content)
        extension = name.rsplit(".", 1)[1]
        valid_header = {
            "webp": content.startswith(b"RIFF") and content[8:12] == b"WEBP",
            "png": content.startswith(b"\x89PNG\r\n\x1a\n"),
            "jpg": content.startswith(b"\xff\xd8\xff"),
            "gif": content.startswith((b"GIF87a", b"GIF89a")),
        }[extension]
        if not valid_header or len(content) > 200 * 1024 or hashlib.sha256(content).hexdigest() != item["sha256"]:
            raise ValueError("Invalid screenshot, size or checksum")
    if total > 1024 * 1024:
        raise ValueError("Release screenshots exceed 1 MiB")

    with zipfile.ZipFile(archive) as bundle:
        entries = bundle.infolist()
        names = {entry.filename for entry in entries}
        if len(names) != len(entries) or sum(entry.file_size for entry in entries) > 100 * 1024 * 1024:
            raise ValueError("Duplicate entries or oversized expanded archive")
        for entry in entries:
            path = PurePosixPath(entry.filename)
            if path.is_absolute() or ".." in path.parts or "\\" in entry.filename:
                raise ValueError("Unsafe archive path")
            if stat.S_ISLNK(entry.external_attr >> 16):
                raise ValueError("Archive must not contain symlinks")
            if entry.is_dir():
                continue
            if any(part.startswith(".") for part in path.parts):
                raise ValueError("Hidden files must not be distributed")
            allowed_root = entry.filename in {"manifest.json", "newtab.html", "popup.html", "favicon.ico"}
            allowed_asset = path.parts[0] in {"assets", "icons", "emojibase-data"} and path.suffix in {".js", ".css", ".json", ".svg", ".png", ".ico", ".woff", ".woff2", ".ttf"}
            if not (allowed_root or allowed_asset):
                raise ValueError(f"Unexpected file in extension archive: {entry.filename}")
        if bundle.testzip() is not None:
            raise ValueError("Corrupt archive")
        manifest = json.loads(bundle.read("manifest.json"))
        if manifest["version"] != version or manifest["manifest_version"] != 3:
            raise ValueError("Extension manifest version mismatch")
        required = {"newtab.html", "popup.html", manifest["background"]["service_worker"]}
        required.update(manifest["icons"].values())
        for html in ("newtab.html", "popup.html"):
            required.update(re.findall(r'(?:src|href)="/?(assets/[^"?]+)', bundle.read(html).decode()))
        if not required.issubset(names):
            raise ValueError(f"Missing runtime assets: {required - names}")
    return metadata


if __name__ == "__main__":
    result = verify(sys.argv[1])
    print(f"Validated {result['archive']} ({result['sha256']})")
