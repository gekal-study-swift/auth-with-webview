#!/usr/bin/env bash
#
# テストを実行する。
#
# 使い方:
#   scripts/test.sh [unit|all] [--simulator <名前>]
#
# 例:
#   scripts/test.sh              # ユニットテストのみ（Swift Testing）
#   scripts/test.sh all          # UI テスト込みの全テスト
#   scripts/test.sh unit --simulator "iPhone 16 Pro"
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELF="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# ── プロジェクト設定 ──────────────────────────────────────────────────────
PROJECT="AuthWithWebView.xcodeproj"
SCHEME="AuthWithWebView"
UNIT_TEST_TARGET="AuthWithWebViewTests"
SIM_NAME="iPhone 16 Pro"

SCOPE="unit"

while [[ $# -gt 0 ]]; do
  case "$1" in
    unit|all)
      SCOPE="$1"
      shift
      ;;
    --simulator)
      SIM_NAME="${2:-}"
      if [[ -z "$SIM_NAME" ]]; then
        echo "❌ --simulator にはシミュレータ名を指定してください" >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      sed -n '2,12p' "$SELF" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "❌ 不明な引数: $1" >&2
      exit 1
      ;;
  esac
done

# 同名シミュレータが複数ランタイムに存在するため、名前ではなく UDID に解決してから渡す
# （起動済みを優先し、無ければ OS バージョンが最新のもの）。
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

ARGS=(
  test
  -project "$PROJECT"
  -scheme "$SCHEME"
  -destination "platform=iOS Simulator,id=$UDID"
)
# 現状 UI テストターゲットは無いため unit / all の差はないが、将来足したとき用に分けておく
if [[ "$SCOPE" == "unit" ]]; then
  ARGS+=(-only-testing:"$UNIT_TEST_TARGET")
fi

echo "▶ テストを実行します (${SCOPE} / $SIM_NAME [$UDID])..."
xcodebuild "${ARGS[@]}"
echo "✅ テスト完了"
