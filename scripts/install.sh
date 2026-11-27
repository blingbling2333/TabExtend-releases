#!/usr/bin/env bash
set -euo pipefail

# TabExtend (Chrome extension name: TabNav) installer & in-place upgrader.
# Safe for both humans and AI coding agents (supports --json structured output).

REPO="${TABEXTEND_REPO:-blingbling2333/TabExtend-releases}"
API_BASE="${TABEXTEND_API_BASE:-https://api.github.com}"
WEB_BASE="${TABEXTEND_WEB_BASE:-https://github.com}"
VERSION="latest"
INSTALL_DIR="${TABEXTEND_INSTALL_DIR:-}"
JSON_OUTPUT=0
FORCE=0
OPEN_AFTER=0

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Download, SHA-256 verify, and unpack TabExtend (TabNav) into a persistent
directory ready for Chrome's "Load unpacked" or in-place "Reload".

Options:
  --dir <path>        Target directory (default: ~/Applications/TabExtend on macOS,
                      ~/.local/share/tabextend on Linux)
  --version <ver>     Release tag or version (e.g. 0.6.0, v0.6.0, or latest)
  --json              Emit a single JSON summary object on stdout
  --force             Allow replacing a non-empty directory without manifest.json
  --open              Reveal the install directory in Finder / file manager
  -h, --help          Show this help message
EOF
}

log() {
  if [ "$JSON_OUTPUT" -eq 1 ]; then
    printf '%s\n' "$*" >&2
  else
    printf '%s\n' "$*"
  fi
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dir)
      [ "$#" -ge 2 ] || die "--dir requires a path argument"
      INSTALL_DIR="$2"
      shift 2
      ;;
    --version)
      [ "$#" -ge 2 ] || die "--version requires a value"
      VERSION="$2"
      shift 2
      ;;
    --json)
      JSON_OUTPUT=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --open)
      OPEN_AFTER=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1 (run with --help for usage)"
      ;;
  esac
done

for cmd in curl unzip; do
  command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
done

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print tolower($1)}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print tolower($1)}'
  else
    die "Neither shasum nor sha256sum is available for SHA-256 verification"
  fi
}

if [ -z "$INSTALL_DIR" ]; then
  case "$(uname -s)" in
    Darwin) INSTALL_DIR="${HOME}/Applications/TabExtend" ;;
    *)      INSTALL_DIR="${HOME}/.local/share/tabextend" ;;
  esac
fi

# Expand leading ~/
case "$INSTALL_DIR" in
  "~")   INSTALL_DIR="$HOME" ;;
  "~/"*) INSTALL_DIR="${HOME}/${INSTALL_DIR#~/}" ;;
esac

# Normalize trailing slash (keep "/" intact for safety check below)
while [ "$INSTALL_DIR" != "/" ] && [ "${INSTALL_DIR%/}" != "$INSTALL_DIR" ]; do
  INSTALL_DIR="${INSTALL_DIR%/}"
done

# Safety guard: never allow wiping root or home directory
if [ -z "$INSTALL_DIR" ] || [ "$INSTALL_DIR" = "/" ] || [ "$INSTALL_DIR" = "$HOME" ] || [ "$INSTALL_DIR" = "/tmp" ] || [ "$INSTALL_DIR" = "/Applications" ]; then
  die "Refusing to install directly into unsafe directory: $INSTALL_DIR"
fi

if [ "$VERSION" = "latest" ]; then
  API_URL="${API_BASE}/repos/${REPO}/releases/latest"
else
  TAG="$VERSION"
  case "$TAG" in
    v*) ;;
    *)  TAG="v${TAG}" ;;
  esac
  API_URL="${API_BASE}/repos/${REPO}/releases/tags/${TAG}"
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/tabextend-install.XXXXXX")"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

RELEASE_JSON="${TMP_DIR}/release.json"
CURL_API_ARGS=(-fsSL -H "Accept: application/vnd.github+json" -H "User-Agent: TabExtend-Installer/1.0")
CURL_DL_ARGS=(-fsSL -H "User-Agent: TabExtend-Installer/1.0")
if [ -n "${GITHUB_TOKEN:-}" ]; then
  CURL_API_ARGS+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

TAG_NAME=""
RELEASE_URL=""
ZIP_NAME=""
ZIP_URL=""
SHA_NAME=""
SHA_URL=""
API_DIGEST=""

parse_release() {
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$RELEASE_JSON" <<'PY'
import json, re, sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

tag = data.get("tag_name") or ""
html_url = data.get("html_url") or ""
assets = data.get("assets") or []

zip_asset = None
sha_asset = None
for asset in assets:
    name = asset.get("name") or ""
    if re.fullmatch(r"tabnav-v\d+\.\d+\.\d+\.zip", name):
        zip_asset = asset
        break

if not zip_asset:
    sys.stderr.write("No tabnav-v*.zip asset found in release\n")
    sys.exit(1)

sha_name = zip_asset["name"] + ".sha256"
for asset in assets:
    if asset.get("name") == sha_name:
        sha_asset = asset
        break

if not sha_asset:
    sys.stderr.write(f"No {sha_name} checksum asset found in release\n")
    sys.exit(1)

digest = (zip_asset.get("digest") or "")
if digest.startswith("sha256:"):
    digest = digest[len("sha256:"):].lower()
else:
    digest = ""

for value in (
    tag,
    html_url,
    zip_asset["name"],
    zip_asset.get("browser_download_url") or "",
    sha_asset["name"],
    sha_asset.get("browser_download_url") or "",
    digest,
):
    print(value)
PY
  elif command -v node >/dev/null 2>&1; then
    node -e '
      const fs = require("fs");
      const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      const assets = data.assets || [];
      const zipAsset = assets.find((a) => /^tabnav-v\d+\.\d+\.\d+\.zip$/.test(a.name || ""));
      if (!zipAsset) { console.error("No tabnav-v*.zip asset found"); process.exit(1); }
      const shaAsset = assets.find((a) => a.name === `${zipAsset.name}.sha256`);
      if (!shaAsset) { console.error(`No ${zipAsset.name}.sha256 asset found`); process.exit(1); }
      const digest = (zipAsset.digest || "").startsWith("sha256:") ? zipAsset.digest.slice(7).toLowerCase() : "";
      console.log([data.tag_name || "", data.html_url || "", zipAsset.name, zipAsset.browser_download_url || "", shaAsset.name, shaAsset.browser_download_url || "", digest].join("\n"));
    ' "$RELEASE_JSON"
  else
    return 1
  fi
}

log "Resolving release metadata for ${REPO} (${VERSION}) ..."
if curl -s "${CURL_API_ARGS[@]}" "$API_URL" -o "$RELEASE_JSON" 2>/dev/null; then
  PARSED=()
  if while IFS= read -r line; do PARSED+=("$line"); done < <(parse_release); then
    TAG_NAME="${PARSED[0]:-}"
    RELEASE_URL="${PARSED[1]:-}"
    ZIP_NAME="${PARSED[2]:-}"
    ZIP_URL="${PARSED[3]:-}"
    SHA_NAME="${PARSED[4]:-}"
    SHA_URL="${PARSED[5]:-}"
    API_DIGEST="${PARSED[6]:-}"
  fi
fi

# Fallback when api.github.com is rate-limited (HTTP 403) or python3/node is unavailable:
# resolve the latest tag via github.com's unthrottled /releases/latest redirect.
if [ -z "$ZIP_URL" ]; then
  log "GitHub API unavailable or rate-limited; falling back to direct release redirect ..."
  if [ "$VERSION" = "latest" ]; then
    EFFECTIVE_URL="$(curl "${CURL_DL_ARGS[@]}" -I -o /dev/null -w '%{url_effective}' "${WEB_BASE}/${REPO}/releases/latest")" || die "Failed to resolve latest release from ${WEB_BASE}/${REPO}/releases/latest"
    TAG_NAME="${EFFECTIVE_URL##*/}"
  else
    TAG_NAME="$TAG"
  fi
  case "$TAG_NAME" in
    v[0-9]*.[0-9]*.[0-9]*) ;;
    *) die "Unexpected release tag resolved from redirect: ${TAG_NAME}" ;;
  esac
  RELEASE_URL="${WEB_BASE}/${REPO}/releases/tag/${TAG_NAME}"
  ZIP_NAME="tabnav-${TAG_NAME}.zip"
  ZIP_URL="${WEB_BASE}/${REPO}/releases/download/${TAG_NAME}/${ZIP_NAME}"
  SHA_NAME="${ZIP_NAME}.sha256"
  SHA_URL="${WEB_BASE}/${REPO}/releases/download/${TAG_NAME}/${SHA_NAME}"
fi

[ -n "$ZIP_NAME" ] && [ -n "$ZIP_URL" ] && [ -n "$SHA_URL" ] || die "Incomplete release asset metadata"

ZIP_PATH="${TMP_DIR}/${ZIP_NAME}"
SHA_PATH="${TMP_DIR}/${SHA_NAME}"

log "Downloading ${ZIP_NAME} ..."
curl "${CURL_DL_ARGS[@]}" "$ZIP_URL" -o "$ZIP_PATH" || die "Failed to download ${ZIP_URL}"
curl "${CURL_DL_ARGS[@]}" "$SHA_URL" -o "$SHA_PATH" || die "Failed to download ${SHA_URL}"

EXPECTED_SHA="$(awk 'NR==1 {print tolower($1)}' "$SHA_PATH")"
[ "${#EXPECTED_SHA}" -eq 64 ] || die "Invalid SHA-256 file format in ${SHA_NAME}"

ACTUAL_SHA="$(sha256_file "$ZIP_PATH")"
if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
  die "SHA-256 mismatch for ${ZIP_NAME}: expected ${EXPECTED_SHA}, got ${ACTUAL_SHA}"
fi
if [ -n "$API_DIGEST" ] && [ "$ACTUAL_SHA" != "$API_DIGEST" ]; then
  die "GitHub asset digest mismatch for ${ZIP_NAME}: expected ${API_DIGEST}, got ${ACTUAL_SHA}"
fi
log "Verified SHA-256: ${ACTUAL_SHA}"

UNPACK_DIR="${TMP_DIR}/unpacked"
mkdir -p "$UNPACK_DIR"
unzip -q "$ZIP_PATH" -d "$UNPACK_DIR"

if [ -f "${UNPACK_DIR}/manifest.json" ]; then
  STAGE_ROOT="$UNPACK_DIR"
else
  FOUND_MANIFEST="$(find "$UNPACK_DIR" -maxdepth 3 -name manifest.json -type f | head -n 1 || true)"
  [ -n "$FOUND_MANIFEST" ] || die "Archive ${ZIP_NAME} does not contain manifest.json"
  STAGE_ROOT="$(dirname "$FOUND_MANIFEST")"
fi

read_manifest_field() {
  local manifest_file="$1"
  local key="$2"
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$manifest_file" "$key" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    print(json.load(f).get(sys.argv[2], ""))
PY
  elif command -v node >/dev/null 2>&1; then
    node -e 'const fs=require("fs"); const d=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); console.log(d[process.argv[2]] || "");' "$manifest_file" "$key"
  else
    sed -n "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$manifest_file" | head -n 1
  fi
}

NEW_VERSION="$(read_manifest_field "${STAGE_ROOT}/manifest.json" "version")"
EXTENSION_NAME="$(read_manifest_field "${STAGE_ROOT}/manifest.json" "name")"
[ -n "$NEW_VERSION" ] || die "Could not read version from manifest.json"

ACTION="install"
PREVIOUS_VERSION=""

if [ -d "$INSTALL_DIR" ]; then
  if [ -f "${INSTALL_DIR}/manifest.json" ]; then
    ACTION="upgrade"
    PREVIOUS_VERSION="$(read_manifest_field "${INSTALL_DIR}/manifest.json" "version")"
  elif [ -n "$(ls -A "$INSTALL_DIR" 2>/dev/null || true)" ] && [ "$FORCE" -ne 1 ]; then
    die "Target directory '${INSTALL_DIR}' is non-empty and does not contain manifest.json. Pass --dir <empty-path> or --force to replace it."
  fi
else
  mkdir -p "$INSTALL_DIR"
fi

# Replace contents in-place so the directory path stays identical for Chrome's Reload button
find "$INSTALL_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp -R "${STAGE_ROOT}/." "$INSTALL_DIR/"

[ -f "${INSTALL_DIR}/manifest.json" ] || die "Installation verification failed: manifest.json missing after copy"

# Resolve canonical path if possible
ABS_INSTALL_DIR="$(cd "$INSTALL_DIR" && pwd)"

if [ "$OPEN_AFTER" -eq 1 ]; then
  if command -v open >/dev/null 2>&1; then
    open "$ABS_INSTALL_DIR" >/dev/null 2>&1 || true
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$ABS_INSTALL_DIR" >/dev/null 2>&1 || true
  fi
fi

if [ "$ACTION" = "upgrade" ]; then
  NEXT_STEP="Open chrome://extensions and click the Reload button on the '${EXTENSION_NAME:-TabNav}' extension card. No need to uninstall."
else
  NEXT_STEP="Open chrome://extensions, enable Developer mode, click 'Load unpacked', and select: ${ABS_INSTALL_DIR}"
fi

if [ "$JSON_OUTPUT" -eq 1 ]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$ACTION" "$REPO" "$TAG_NAME" "$NEW_VERSION" "$PREVIOUS_VERSION" "${EXTENSION_NAME:-TabNav}" "$ZIP_NAME" "$ACTUAL_SHA" "$ABS_INSTALL_DIR" "$RELEASE_URL" "$NEXT_STEP" <<'PY'
import json, sys
action, repo, tag, version, prev, ext_name, archive, sha, install_dir, release_url, next_step = sys.argv[1:]
print(json.dumps({
    "status": "ok",
    "action": action,
    "repository": repo,
    "tag": tag,
    "version": version,
    "previousVersion": prev or None,
    "extensionName": ext_name,
    "archive": archive,
    "sha256": sha,
    "sha256Verified": True,
    "installDir": install_dir,
    "manifestPath": f"{install_dir}/manifest.json",
    "releaseUrl": release_url,
    "nextStep": next_step,
}, ensure_ascii=False, indent=2))
PY
  else
    node -e '
      const [action, repo, tag, version, prev, extName, archive, sha, installDir, releaseUrl, nextStep] = process.argv.slice(1);
      console.log(JSON.stringify({
        status: "ok",
        action,
        repository: repo,
        tag,
        version,
        previousVersion: prev || null,
        extensionName: extName,
        archive,
        sha256: sha,
        sha256Verified: true,
        installDir,
        manifestPath: `${installDir}/manifest.json`,
        releaseUrl,
        nextStep,
      }, null, 2));
    ' "$ACTION" "$REPO" "$TAG_NAME" "$NEW_VERSION" "$PREVIOUS_VERSION" "${EXTENSION_NAME:-TabNav}" "$ZIP_NAME" "$ACTUAL_SHA" "$ABS_INSTALL_DIR" "$RELEASE_URL" "$NEXT_STEP"
  fi
else
  cat <<EOF

TabExtend ${TAG_NAME} (${ACTION}) ready!
  Extension name : ${EXTENSION_NAME:-TabNav}
  Version        : ${NEW_VERSION}${PREVIOUS_VERSION:+ (upgraded from ${PREVIOUS_VERSION})}
  SHA-256        : ${ACTUAL_SHA} (verified)
  Install folder : ${ABS_INSTALL_DIR}

Next step in Chrome:
  ${NEXT_STEP}
EOF
fi
