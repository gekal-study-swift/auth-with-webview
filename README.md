# auth-with-webview

電話番号 → 6 桁コード → 結果確認、という SMS 認証の流れを **WKWebView 上の Web ページ**で動かす
サンプルです。[`webview-interaction-sample`](https://github.com/gekal) と同じ構成
（iOS シェル + Next.js の Web ページ）で、題材を「JS ⇄ Native ブリッジのデモ」から
「認証フロー」に置き換えています。

**SMS は送信しません。** 「認証コードを送信」を押すと 6 桁のダミーコードを生成し、
ダミー SMS として画面に表示します。それを入力すると認証成功になります。

## 画面の流れ

| # | 画面 | 内容 |
| --- | --- | --- |
| 1 | 電話番号を入力 | 日本の電話番号（10〜11 桁）を検証。送信でダミーコードを生成 |
| 2 | 認証コードを入力 | ダミー SMS に 6 桁を表示。一致すれば成功、違えばエラー。再送・入力し直し可 |
| 3 | 結果確認 | 電話番号（一部マスク）・認証時刻・ネイティブ連携の状況を表示 |

WebView 上で開くと、認証成功時にネイティブへ通知し、**触覚フィードバック + トースト**で応答が返ります。
ブラウザで開いた場合はネイティブ連携をスキップし、Web だけで完結します。

## 構成

| パス | 内容 |
| --- | --- |
| `AuthWithWebView/` | iOS アプリ本体（WKWebView シェル） |
| `AuthWithWebViewTests/` | UIKit に依存しないロジックのユニットテスト（Swift Testing） |
| `Supporting/Info.plist` | localhost の平文 HTTP を許可する ATS 例外（Debug 用） |
| `web/` | WebView に表示する Next.js + MUI のページ（静的エクスポート） |
| `scripts/` | シミュレータ / 実機へのインストールとテスト実行 |
| `.github/workflows/pages.yml` | `web/` をビルドして GitHub Pages へデプロイ |

### iOS 側のファイル

| ファイル | 役割 |
| --- | --- |
| `AuthWithWebViewApp.swift` | `@main`。`ContentView` を表示するだけ |
| `ContentView.swift` | 配色の状態を持ち、`preferredColorScheme` で画面全体に適用する |
| `WebViewContainer.swift` | SwiftUI から `WebViewController` を使うためのラッパー |
| `WebViewController.swift` | WKWebView の生成、`window.NativeAuth` ブリッジ、遷移の振り分け、読み込み状態 |
| `AppTheme.swift` | 配色の種類・保存、Web (`web/app/theme.ts`) と揃えた色 |
| `LoadState.swift` | 読み込み状態の遷移ロジック（純粋関数・テスト対象） |
| `LinkPolicy.swift` | リンクをどこで開くかの判定（純粋関数・テスト対象） |
| `Toast.swift` | 操作を妨げない短いメッセージ表示 |

`LoadState.swift` と `LinkPolicy.swift` は UIKit に依存しないため、シミュレータや実機なしで検証できます。

## ブリッジ API

Web ページは `window.NativeAuth` を呼び出します（型定義は `web/types/bridge.d.ts`）。

| メソッド | 向き | 内容 |
| --- | --- | --- |
| `setAppTheme(theme)` | JS → Native | Web で選んだ配色をネイティブへ同期（`'light'` / `'dark'` / `'system'`） |
| `onVerified(payloadJson)` | JS → Native | 認証成功を通知。ネイティブは触覚フィードバック + トーストで応答 |
| `getEnvInfo()` | JS → Native（同期戻り値） | プラットフォーム・アプリ情報を JSON 文字列で返す |
| `handleNativeAck(message)` | Native → JS | `onVerified` の受領確認。結果確認画面に表示される |

`postMessage()` は値を返せないため、同期で値を返す `getEnvInfo` だけ注入時に値を持たせています。

## ビルド & 実行

```shell
# WebView が読み込む Web ページのローカルサーバー（別シェルで動かしたまま）
pnpm --dir web install
pnpm --dir web dev                       # http://localhost:3000

# シミュレータへインストールして起動
./scripts/simulator-install.sh --launch

# 実機へ（初回は Xcode で Signing の Team 設定が必要）
./scripts/device-install.sh --launch
```

生の `xcodebuild` を使う場合:

```shell
xcodebuild build -project AuthWithWebView.xcodeproj -scheme AuthWithWebView \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

- 既定では `Debug` / `Release` とも配信中の `https://gekal-study-swift.github.io/auth-with-webview/`
  を読み込みます（実機でもシミュレータでもそのまま動く）。`Debug` は端末上でログを見るため
  `?vconsole=1` を付けています。
- ローカルの `web/` を確認するときは、別シェルで `pnpm --dir web dev` を動かしてから
  `WebViewController.swift` の `Debug` 行を `http://localhost:3000/` に差し替えます
  （localhost の平文 HTTP は `Supporting/Info.plist` の ATS 例外で許可済み。
  実機では `localhost` が実機自身を指すため Mac の LAN IP にする）。
- Deployment Target は iOS 26.0、Swift 5.0、Bundle ID は `cn.gekal.ios.AuthWithWebView`。

## テスト

```shell
./scripts/test.sh          # ロジックのユニットテスト（Swift Testing）
```

| ファイル | 内容 |
| --- | --- |
| `LoadStateTests.swift` | 読み込み状態の遷移（`about:blank` の除外、キャンセルとエラーの区別、サブフレームの HTTP エラー） |
| `LinkPolicyTests.swift` | 同一ホストか外部かの判定、ブラウザ表示に使えるスキームの制限 |
| `AppThemeTests.swift` | 配色文字列の解釈と `UserDefaults` への保存 |

## Web 画面

```shell
pnpm --dir web install
pnpm --dir web dev             # 開発サーバー
pnpm --dir web build          # 静的サイトを web/out に生成
```

GitHub Pages のプロジェクトサイト `https://gekal-study-swift.github.io/auth-with-webview/` で配信します。
`main` への push 時に GitHub Actions（`.github/workflows/pages.yml`）がビルドしてデプロイし、
Pull Request ではビルドまで行います。プロジェクトサイトはリポジトリ名がパスに入るため、
CI では `BASE_PATH=/auth-with-webview` を指定して `basePath` 付きでビルドします
（ローカルの `pnpm --dir web dev` は空のままルートで配信）。

### Web 側のファイル

| パス | 役割 |
| --- | --- |
| `app/page.tsx` / `components/auth-flow.tsx` | 3 画面のステートマシン（電話番号 → コード → 結果） |
| `app/auth.ts` | 電話番号の正規化・検証・整形、ダミーコード生成・照合（純粋関数） |
| `app/bridge-provider.tsx` | `window.NativeAuth` の検出とネイティブ呼び出し |
| `app/components/phone-step.tsx` / `code-step.tsx` / `result-step.tsx` | 各画面 |
| `app/components/mock-sms-banner.tsx` | ダミー SMS（生成したコードを表示） |
| `app/theme.ts` | MUI テーマ。色は `AuthWithWebView/AppTheme.swift` の `WebPalette` と同じ値 |

## 配色

`web/app/theme.ts` の色を `AppTheme.swift` の `WebPalette` に写し、セーフエリアの余白と
WebView の背景を同じ色にして継ぎ目なく見せています。配色の真実の源は WebView 側
（MUI が localStorage に保存）で、ネイティブは `setAppTheme` で受け取って `UserDefaults` に
ミラーし、次回起動時のちらつきを防ぎます。

| 用途 | Light | Dark |
| --- | --- | --- |
| 背景 | `#F2F6F5` | `#0E1414` |
| サーフェス | `#FFFFFF` | `#161D1D` |
| プライマリ | `#00695F` | `#5FD4C0` |
