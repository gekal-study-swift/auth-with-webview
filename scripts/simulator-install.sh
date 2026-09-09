#!/usr/bin/env bash
#
# iOS シミュレータにアプリをビルドしてインストールする。
#
# 使い方:
#   scripts/simulator-install.sh [--simulator <名前>] [--launch]
#
# 例:
#   scripts/simulator-install.sh                          # 既定のシミュレータにインストール
#   scripts/simulator-install.sh --launch                 # インストール後にアプリを起動
#   scripts/simulator-install.sh --simulator "iPhone 16 Pro" --launch
#
# Debug ビルドは http://localhost:3000 を読み込むため、別シェルで
# `pnpm --dir web dev` を起動しておくこと（web/README ではなくルート README 参照）。
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
SIM_NAME="iPhone 16 Pro"

LAUNCH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --simulator)
      SIM_NAME="${2:-}"
      if [[ -z "$SIM_NAME" ]]; then
        echo "❌ --simulator にはシミュレータ名を指定してください" >&2
        exit 1
      fi
      shift 2
      ;;
    --launch)
      LAUNCH=true
      shift
      ;;
    -h|--help)
      sed -n '2,15p' "$SELF" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "❌ 不明な引数: $1" >&2
      exit 1
      ;;
  esac
done

command -v xcodebuild >/dev/null 2>&1 || {
  echo "❌ xcodebuild が見つかりません。Xcode をインストールし、" >&2
  echo "   sudo xcode-select -s /Applications/Xcode.app で選択してください。" >&2
  exit 1
}

# 同名シミュレータが複数の OS バージョンに存在するため、UDID に解決する
# （起動済みのものを優先し、無ければ OS バージョンが最新のものを選ぶ）
UDID=$(xcrun simctl list devices available -j | python3 -c "
import json, sys
data = json.load(sys.stdin)
candidates = []
for runtime, devices in data['devices'].items():
    if 'iOS' not in runtime:
        continue
    for d in devices:
        if d['name'] == '$SIM_NAME':
            candidates.append((d['state'] == 'Booted', runtime, d['udid']))
if not candidates:
    sys.exit(1)
candidates.sort(reverse=True)
print(candidates[0][2])
") || {
  echo "❌ シミュレータ '$SIM_NAME' が見つかりません。" >&2
  echo "   利用可能な一覧: xcrun simctl list devices available" >&2
  exit 1
}

echo "▶ シミュレータを起動します: $SIM_NAME ($UDID)"
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator

echo "▶ ビルドします..."
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  -quiet

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/$SCHEME.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "❌ ビルド生成物が見つかりません: $APP_PATH" >&2
  exit 1
fi

echo "▶ インストールします: $APP_PATH"
xcrun simctl install "$UDID" "$APP_PATH"
echo "✅ インストール完了 ($SIM_NAME)"

if [[ "$LAUNCH" == true ]]; then
  echo "▶ アプリを起動します: $BUNDLE_ID"
  xcrun simctl launch "$UDID" "$BUNDLE_ID" >/dev/null
  echo "✅ 起動しました"
fi
