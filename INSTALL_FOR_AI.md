# Installing Open-TabExtend with an AI Coding Agent

This runbook is written for AI agents (Claude Code, Codex, Cursor, Antigravity, OpenClaw, Windsurf, etc.) helping a user install or upgrade **Open-TabExtend** (displayed as **TabNav** in `chrome://extensions`) from `https://github.com/blingbling2333/Open-TabExtend`.

---

## Goal

1. Download the latest official release archive (`tabnav-v<version>.zip`) from `blingbling2333/Open-TabExtend`.
2. Strictly verify its SHA-256 checksum against the release's `.sha256` sidecar file (and GitHub's asset digest when present).
3. Unpack into a **persistent** local directory (never `/tmp` or a temporary workspace folder, because Chrome loads unpacked extensions directly from disk).
4. If upgrading an existing install, replace files **in-place** inside the same directory path so Chrome keeps the extension ID and local IndexedDB data intact.
5. Hand back clear, short instructions for the one manual Chrome UI action (`Load unpacked` or `Reload`).

---

## 1. Recommended: One-Command Official Installer

If the user already has Open-TabExtend / TabExtend installed at a custom path, ask or inspect first and pass `--dir <existing-path>` (macOS/Linux) or `-Dir <existing-path>` (Windows) so the upgrade happens in-place.

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/blingbling2333/Open-TabExtend/main/scripts/install.sh | bash -s -- --json
```

Useful flags:
- `--dir <path>` — install/upgrade into a specific persistent folder (default: `~/Applications/Open-TabExtend` on macOS, `~/.local/share/open-tabextend` on Linux; auto-detects legacy `TabExtend` dir)
- `--version <x.y.z>` — pin a specific release instead of `latest`
- `--open` — open the unpacked folder in Finder / file manager after verification

### Windows (PowerShell)

```powershell
$script = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/blingbling2333/Open-TabExtend/main/scripts/install.ps1"
& ([scriptblock]::Create($script)) -Json
```

Useful parameters: `-Dir <path>` (default: `%LOCALAPPDATA%\Open-TabExtend`), `-Version <x.y.z>`, `-Open`.

### Expected `--json` Output

```json
{
  "status": "ok",
  "action": "install",
  "repository": "blingbling2333/Open-TabExtend",
  "tag": "v0.6.0",
  "version": "0.6.0",
  "previousVersion": null,
  "extensionName": "TabNav",
  "archive": "tabnav-v0.6.0.zip",
  "sha256": "...",
  "sha256Verified": true,
  "installDir": "/Users/<user>/Applications/Open-TabExtend",
  "manifestPath": "/Users/<user>/Applications/Open-TabExtend/manifest.json",
  "releaseUrl": "https://github.com/blingbling2333/Open-TabExtend/releases/tag/v0.6.0",
  "nextStep": "Open chrome://extensions, enable Developer mode, click 'Load unpacked', and select: ..."
}
```

---

## 2. Manual Step-by-Step Fallback (Without Running Remote Scripts)

If your environment prefers inspecting and running commands directly instead of piping a script:

1. Resolve the latest release tag (using GitHub's unthrottled redirect — works even if `api.github.com` is rate-limited):
   ```bash
   TAG="$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/blingbling2333/Open-TabExtend/releases/latest | awk -F/ '{print $NF}')"
   ```
   (Or query `https://api.github.com/repos/blingbling2333/Open-TabExtend/releases/latest` if you prefer JSON metadata.)
2. Download the deterministic official archive and its `.sha256` file:
   - `https://github.com/blingbling2333/Open-TabExtend/releases/download/${TAG}/tabnav-${TAG}.zip`
   - `https://github.com/blingbling2333/Open-TabExtend/releases/download/${TAG}/tabnav-${TAG}.zip.sha256`
   - **Never** download GitHub's auto-generated `Source code (zip)` / `Source code (tar.gz)`.
3. Download both files into a temporary directory and verify integrity before extracting:
   ```bash
   shasum -a 256 -c tabnav-v<version>.zip.sha256
   ```
   (On Linux, `sha256sum -c`; on Windows PowerShell, compare `(Get-FileHash tabnav-v<version>.zip -Algorithm SHA256).Hash`.)
4. Pick a persistent install directory (`~/Applications/Open-TabExtend` on macOS, `~/.local/share/open-tabextend` on Linux, `%LOCALAPPDATA%\Open-TabExtend` on Windows).
   - If upgrading, confirm `<installDir>/manifest.json` exists, clean old files inside `<installDir>` while keeping the directory itself, then extract the new ZIP directly into `<installDir>`.
5. Verify `<installDir>/manifest.json` exists and its `"version"` matches the release tag.

---

## 3. Rules & Security Boundaries

- **Do not** attempt to modify Chrome's `Preferences`, `Secure Preferences`, or internal profile databases to silently inject an unpacked extension. Chrome requires explicit user confirmation via `chrome://extensions`.
- **Do not** unpack into `/tmp` or a throwaway repo checkout — Chrome will break the extension as soon as that folder is cleaned up.
- **Do not** uninstall the old extension before upgrading — uninstalling wipes local IndexedDB workspace/tab data. In-place file replacement + Chrome's Reload button preserves all data.
- **Stop immediately** if SHA-256 verification fails and report the mismatch to the user.

---

## 4. Final Handoff to the User

Once `installDir` is verified and ready, optionally reveal it (`open <installDir>` on macOS if helpful) and give the user a short, clear handoff:

- **Fresh install (中文模板)**:
  > 已为你下载、校验 SHA-256 并解压 **Open-TabExtend `v<version>`** 到永久目录：
  > `<installDir>`
  >
  > 最后一步（约 10 秒）在 Chrome 中完成加载：
  > 1. 地址栏打开 `chrome://extensions`
  > 2. 开启右上角「开发者模式」
  > 3. 点击「加载已解压的扩展程序」，选择上面的目录即可（扩展名显示为 **TabNav**）

- **In-place upgrade (中文模板)**:
  > 已将 **Open-TabExtend** 原地更新为 **`v<version>`**（SHA-256 校验通过，安装路径不变，本地数据完整保留）：
  > `<installDir>`
  >
  > 最后一步：打开 `chrome://extensions`，点击 **TabNav** 卡片右下角的「重新加载」按钮即可（无需卸载旧版本）。
