#!/usr/bin/env bash
#
# 接続中の実機（iPhone/iPad）にアプリをビルドして署名・インストールする。
# Xcode 15 以降の `xcrun devicectl` を使用する。
#
# 使い方:
#   scripts/device-install.sh [--device <名前 or UDID>] [--launch] [--configuration Debug|Release]
#
# 例:
#   scripts/device-install.sh                       # 接続中の1台にインストール
#   scripts/device-install.sh --launch              # インストール後に起動
#   scripts/device-install.sh --device "Gekal の iPhone" --launch
#
# 前提:
#   - 実機が USB / ネットワークで接続され、開発者モードが有効なこと
#   - Xcode プロジェクトに署名チーム（DEVELOPMENT_TEAM）が設定済み（自動署名）。
#     未設定なので、初回は Xcode でプロジェクトを開き Signing にチームを設定する。
#   - Debug ビルドは http://localhost:3000 を読み込む。実機で動かすなら Release
#     （配信サイトを読む）を使うか、Mac の LAN IP を指す URL に書き換える。
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELF="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# ── プロジェクト設定 ──────────────────────────────────────────────────────
PROJECT="AuthWithWebView.xcodeproj"
SCHEME="AuthWithWebView"
BUNDLE_ID="cn.gekal.ios.AuthWithWebView"
DERIVED_DATA=".build/DerivedData"

CONFIGURATION="Debug"
DEVICE_QUERY=""
LAUNCH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      DEVICE_QUERY="${2:-}"
      if [[ -z "$DEVICE_QUERY" ]]; then
        echo "❌ --device には端末名または UDID を指定してください" >&2
        exit 1
      fi
      shift 2
      ;;
    --configuration)
      CONFIGURATION="${2:-Debug}"
      shift 2
      ;;
    --launch)
      LAUNCH=true
      shift
      ;;
    -h|--help)
      sed -n '2,20p' "$SELF" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "❌ 不明な引数: $1" >&2
      exit 1
      ;;
  esac
done

DEVICES_JSON="$(mktemp)"
trap 'rm -f "$DEVICES_JSON"' EXIT
xcrun devicectl list devices --json-output "$DEVICES_JSON" >/dev/null 2>&1 || {
  echo "❌ devicectl の実行に失敗しました。Xcode 15 以降が必要です。" >&2
  exit 1
}

# 接続中の iOS 実機を解決する。選択結果を "UDID\t名前" で返す
RESOLVED="$(python3 - "$DEVICES_JSON" "$DEVICE_QUERY" <<'PY'
import json, sys

path, query = sys.argv[1], sys.argv[2]
data = json.load(open(path))
devices = data.get("result", {}).get("devices", [])

connected = []
for d in devices:
    platform = d.get("hardwareProperties", {}).get("platform")
    state = d.get("connectionProperties", {}).get("tunnelState")
    name = d.get("deviceProperties", {}).get("name", "")
    udid = d.get("identifier", "")
    if platform in ("iOS", "iPadOS") and state == "connected":
        connected.append((udid, name))

if query:
    matches = [(u, n) for (u, n) in connected if query in (u, n)]
    if not matches:
        sys.stderr.write(f"指定された端末が見つかりません: {query}\n")
        sys.exit(1)
    u, n = matches[0]
    print(f"{u}\t{n}")
    sys.exit(0)

if not connected:
    sys.stderr.write("接続中の iOS 実機がありません。USB 接続と開発者モードを確認してください。\n")
    sys.exit(1)
if len(connected) > 1:
    sys.stderr.write("複数の端末が接続されています。--device <名前 or UDID> で指定してください:\n")
    for u, n in connected:
        sys.stderr.write(f"  - {n} ({u})\n")
    sys.exit(1)

u, n = connected[0]
print(f"{u}\t{n}")
PY
)" || exit 1

UDID="${RESOLVED%%$'\t'*}"
DEVICE_NAME="${RESOLVED#*$'\t'}"

echo "▶ ビルドします（$CONFIGURATION / 実機向け）..."
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "platform=iOS,id=$UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  -allowProvisioningUpdates \
  -quiet

APP_PATH="$DERIVED_DATA/Build/Products/$CONFIGURATION-iphoneos/$SCHEME.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "❌ ビルド生成物が見つかりません: $APP_PATH" >&2
  echo "   署名エラーの場合は Xcode でプロジェクトを開き、Signing & Capabilities で" >&2
  echo "   Team を設定してから再実行してください。" >&2
  exit 1
fi

echo "▶ インストールします: $DEVICE_NAME ($UDID)"
xcrun devicectl device install app --device "$UDID" "$APP_PATH"
echo "✅ インストール完了 ($DEVICE_NAME)"

if [[ "$LAUNCH" == true ]]; then
  echo "▶ アプリを起動します: $BUNDLE_ID"
  if xcrun devicectl device process launch --device "$UDID" --terminate-existing "$BUNDLE_ID" >/dev/null 2>&1; then
    echo "✅ 起動しました"
  else
    echo "⚠️  インストールは完了しましたが、起動に失敗しました。" >&2
    echo "    端末のロックを解除し、設定 > 一般 > VPN とデバイス管理 で開発元を信頼してください。" >&2
  fi
fi
