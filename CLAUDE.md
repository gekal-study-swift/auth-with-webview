# CLAUDE.md

## 概要

電話番号 → 6 桁コード → 結果確認、という SMS 認証の流れを WKWebView 上の Next.js ページで動かす
サンプル。`webview-interaction-sample` と同じ構成（iOS シェル + `web/`）。SMS は送信せず、
6 桁のダミーコードを生成して画面に表示する。

## ビルド・テスト

| 目的 | コマンド |
| --- | --- |
| Web 開発サーバー | `pnpm --dir web dev`（`http://localhost:3000`、Debug ビルドが読み込む） |
| Web 静的ビルド | `pnpm --dir web build`（`web/out`） |
| シミュレータへ | `./scripts/simulator-install.sh --launch` |
| 実機へ | `./scripts/device-install.sh --launch`（初回は Xcode で Signing の Team 設定） |
| ユニットテスト | `./scripts/test.sh` |

## アーキテクチャ

| 種別 | 実体 |
| --- | --- |
| エントリポイント | `AuthWithWebView/AuthWithWebViewApp.swift` → `ContentView` |
| 画面遷移（iOS） | 無し。`ContentView` は WebView を全面表示するだけ。フローは `web/` 側が持つ |
| 画面遷移（Web） | `web/app/components/auth-flow.tsx` の `Phase` ステートマシン（`phone` / `code` / `result`） |
| JS ⇄ Native | `window.NativeAuth`（`setAppTheme` / `onVerified` / `getEnvInfo`）、Native→JS は `handleNativeAck` |
| 純粋ロジック（iOS） | `LoadStateReducer`、`LinkPolicy`、`AppTheme` — Swift Testing で検証 |
| 純粋ロジック（Web） | `web/app/auth.ts` — 電話番号の検証・整形、コード生成・照合 |
| 永続化 | 配色のみ。`UserDefaults`（iOS）/ localStorage（MUI） |

## 実装上の注意点

- 配色の値は `web/app/theme.ts` と `AuthWithWebView/AppTheme.swift` の `WebPalette` で二重管理。
  片方を変えたら両方直す。
- `WebViewController.targetURL` は既定で `Debug` / `Release` とも配信サイト
  `https://gekal-study-swift.github.io/auth-with-webview/`（Debug は `?vconsole=1` 付き）。
  ローカルの `web/` を見るときだけ `Debug` 行を `http://localhost:3000/` に差し替える。
  localhost の平文 HTTP は `Supporting/Info.plist` の ATS 例外で許可している。
- 公開 URL はプロジェクトサイト（パスにリポジトリ名が入る）。CI は `BASE_PATH=/auth-with-webview`
  を指定して `basePath` 付きでビルドする。`pnpm --dir web dev` は空のままルートで配信。
- `Supporting/Info.plist` は同期グループ (`AuthWithWebView/`) の外に置くこと。中に入れると
  Copy Bundle Resources に二重登録されてビルドが失敗する。
- `DEVELOPMENT_TEAM` は未設定。シミュレータは動く。実機は Xcode で Team を設定する。
- 画面や機能を足したら README のファイル表と、この表も更新する。
