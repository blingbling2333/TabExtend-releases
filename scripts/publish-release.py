"""Publish validated attachments, resuming drafts without replacing a release."""
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys

spec = importlib.util.spec_from_file_location("verify_package", Path(__file__).with_name("verify-package.py"))
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)
tag = sys.argv[1]
metadata = validator.verify(tag)
repository = os.environ.get("GITHUB_REPOSITORY", "blingbling2333/TabExtend-releases")
if repository != "blingbling2333/TabExtend-releases":
    raise ValueError("Unexpected release repository")


def gh(*args):
    return subprocess.check_output(["gh", *args], text=True, stderr=subprocess.PIPE)


def api_or_none(endpoint):
    try:
        return json.loads(gh("api", endpoint))
    except subprocess.CalledProcessError as error:
        if "HTTP 404" in error.stderr:
            return None
        raise


archive = metadata["archive"]
media = [Path(".release") / item["name"] for item in metadata.get("media", [])]
endpoint = f"repos/{repository}/releases"
release = api_or_none(f"{endpoint}/tags/{tag}")
if release and not release["draft"]:
    assets = {asset["name"]: asset for asset in release["assets"]}
    if assets.get(archive, {}).get("digest") != f"sha256:{metadata['sha256']}" or f"{archive}.sha256" not in assets:
        raise ValueError("Published release differs from this package; create a new version instead")
    for item in metadata.get("media", []):
        if assets.get(item["name"], {}).get("digest") != f"sha256:{item['sha256']}":
            raise ValueError("Published screenshot differs from this package")
    if metadata.get("notesSha256") and Path(".release/release-notes.md").read_text().strip() not in (release.get("body") or ""):
        raise ValueError("Published release is missing its upgrade notes")
    print(f"Already published: {release['html_url']}")
else:
    notes = Path(os.environ.get("RUNNER_TEMP", "/tmp")) / "tabextend-release-notes.md"
    upgrades = Path(".release/release-notes.md").read_text().strip() + "\n\n---\n\n" if metadata.get("notesSha256") else ""
    notes.write_text(upgrades + f"""### 🤖 让 AI Agent 自动安装 / 更新

直接将仓库链接 `https://github.com/{repository}` 发给 Claude Code / Codex / Cursor / Antigravity 等 AI 工具，或运行官方校验安装脚本（自动下载 `{archive}`、校验 SHA-256 并原地解压）：

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/{repository}/main/scripts/install.sh | bash -s -- --version {metadata['version']}
```

> 更多说明与 Windows PowerShell 脚本见 [AI 安装指南](https://github.com/{repository}/blob/main/INSTALL_FOR_AI.md) · [`llms.txt`](https://github.com/{repository}/blob/main/llms.txt)

---

### 📦 手动安装 / 更新

下载 **`{archive}`** 并解压，然后在 `chrome://extensions` 开启开发者模式，选择「加载已解压的扩展程序」。选中直接包含 `manifest.json` 的目录。

更新时将新版文件替换到原安装目录，再点击扩展的重新加载按钮。建议先导出备份，无需卸载旧扩展。

请下载上述 ZIP 附件，GitHub 自动生成的 `Source code` 附件不是安装包。

[详细安装说明](https://github.com/{repository}#安装) · [功能预览与动图演示](https://github.com/{repository}#readme)

SHA-256: `{metadata['sha256']}`
""")
    if release is None:
        gh("release", "create", tag, "--repo", repository, "--verify-tag", "--draft", "--title", f"TabExtend {tag}", "--notes-file", str(notes))
    gh("release", "upload", tag, str(Path(".release") / archive), str(Path(".release") / f"{archive}.sha256"), *map(str, media), "--repo", repository, "--clobber")
    latest = api_or_none(f"{endpoint}/latest")
    current_version = tuple(map(int, metadata["version"].split(".")))
    previous_tag = latest["tag_name"] if latest else "v0.0.0"
    if not re.fullmatch(r"v\d+\.\d+\.\d+", previous_tag):
        raise ValueError("Cannot compare latest release version")
    is_latest = current_version >= tuple(map(int, previous_tag[1:].split(".")))
    gh("release", "edit", tag, "--repo", repository, "--draft=false", f"--latest={str(is_latest).lower()}", "--notes-file", str(notes))
    print(f"Published: https://github.com/{repository}/releases/tag/{tag}")
