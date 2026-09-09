# CLAUDE.md

## 概要

電話番号 → 6 桁コード → 結果確認、という SMS 認証の流れを、**同じフローの WebView 版と
ネイティブ版**で並べて見比べるサンプル。`ContentView` の `TabView` で切り替える。
- WebView 版: WKWebView + `web/`（Next.js）
- ネイティブ版: `AuthWithWebView/NativeFlow/`（SwiftUI）
SMS は送信せず、6 桁のダミーコードを生成して画面に表示する。

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
| エントリポイント | `AuthWithWebView/AuthWithWebViewApp.swift` → `ContentView`（`TabView`: WebView / ネイティブ） |
| 画面遷移（Web 版） | App Router のページ 3 つ（`/` `/verify` `/result`）。共通枠は `app/components/app-frame.tsx` |
| 画面遷移（ネイティブ版） | `NativeFlow/AuthFlowView.swift` が `AuthFlowModel.step`（`AuthStep`）で分岐 |
| フロー状態（Web 版） | `web/app/atoms.ts` の Jotai atom（**メモリのみ・永続化なし**）。リロードで消え、`app/components/flow-guard.tsx` がやり直しダイアログ |
| フロー状態（ネイティブ版） | `NativeFlow/AuthFlowModel.swift`（`@Observable`・**メモリのみ**）。通常は消えない。比較用に `discardState()` で消失を再現、`AuthFlowGuard` + アラートでやり直し |
| WebView 復旧（iOS） | `webViewWebContentProcessDidTerminate` で再読込。上限は `LoadStateReducer.onContentProcessTerminated` |
| JS ⇄ Native | `window.NativeAuth`（`setAppTheme` / `onVerified` / `getEnvInfo`）、Native→JS は `handleNativeAck` |
| 純粋ロジック（iOS） | `LoadStateReducer`、`LinkPolicy`、`AppTheme`、`AuthLogic`、`AuthFlowGuard` — Swift Testing で検証 |
| 純粋ロジック（Web） | `web/app/auth.ts` — `NativeFlow/AuthLogic.swift` と同じ振る舞いに揃える（片方直したら両方） |
| 永続化 | 配色のみ。`UserDefaults`（iOS）/ localStorage（MUI）。フロー状態はどちらの版も永続化しない |

## 実装上の注意点

- 配色の値は `web/app/theme.ts` と `AuthWithWebView/AppTheme.swift` の `WebPalette` で二重管理。
  片方を変えたら両方直す。
- 認証ロジックも `web/app/auth.ts` と `NativeFlow/AuthLogic.swift` で二重管理。テストで結果を突き合わせる。
- `NativeFlow/` は同期グループ `AuthWithWebView/` 配下なので pbxproj 変更なしで自動的にコンパイル対象になる。
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
