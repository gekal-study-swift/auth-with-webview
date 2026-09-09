# 状態管理

認証フロー（`/` → `/verify` → `/result`）で持ち回す状態の扱い。WebView 版とネイティブ版で
**同じ方針**にしてあり、差が出るのは「リロードで状態が消えるか」だけ。

| | WebView 版 | ネイティブ版 |
| --- | --- | --- |
| 状態の置き場 | Jotai atom（`web/app/atoms.ts`、メモリのみ） | `@Observable AuthFlowModel`（`NativeFlow/`、メモリのみ） |
| ステップ間の保持 | ページ遷移・戻る/進むで保持 | `@State` 所有なので画面が生きている限り保持 |
| リロードで消えるか | **消える**（フルリロード・WebView 再生成） | 通常は消えない。比較用に `discardState()` で再現 |
| 消えたときの扱い | `FlowGuard` → 「セッションが切れました」ダイアログ → `/` | `AuthFlowGuard` → 同じダイアログ → ステップ 1 |
| ガード判定 | `flow-guard.tsx` の `satisfied` | `AuthFlowGuard.canShow(_:phoneNumber:sentCode:verifiedAt:)`（純粋・テスト対象） |

以下は WebView 版の詳細。

## 方針

電話番号・認証コードは**機微情報**として扱い、`sessionStorage` / `localStorage` / URL には残さない。
代わりに **Jotai の atom（メモリのみ・永続化なし）** で持つ。

| 何を | どこで | 寿命 |
| --- | --- | --- |
| `phoneNumber` / `sentCode` / `verifiedAt` | `web/app/atoms.ts`（`atomWithReset`、Jotai デフォルトストア） | SPA 遷移・戻る/進むで保持。**フルリロード・WebView 再生成で消える** |
| 入力中の値・エラー表示 | 各ステップコンポーネントの `useState` | その画面限り |
| `connected` / `envInfo` / `nativeAck` | `bridge-provider.tsx`（Context、`layout` に常駐） | セッション中 |
| 配色 | MUI `useColorScheme` → `localStorage`（非機微） | 端末に永続。ネイティブへ `setAppTheme` で同期 |

## 消えたときの扱い

`/verify` `/result` は `FlowGuard`（`web/app/components/flow-guard.tsx`）で包む。
マウント後に必要な atom が空なら、**フルリロードか直リンク**と判断し、閉じられないダイアログ
「セッションが切れました」を出す。「最初からやり直す」で atom を reset して `/` へ。

- SPA 遷移では atom は消えないので、「ステップ画面に居て atom が空 = リロード等」と断定できる。
- プリレンダ／ハイドレーション時は atom が初期値のため、判定は `mounted` フラグで初回描画後に行う（`FlowGuard` 内）。

## リロードの発生源

| 発生源 | 挙動 |
| --- | --- |
| ブラウザの再読み込み・プルリフレッシュ | atom 消失 → ダイアログ |
| iOS のエラー画面「再試行」（`webView.load`） | 同上 |
| **WebView コンテンツプロセスの強制終了**（メモリ逼迫） | `WebViewController.webViewWebContentProcessDidTerminate` が読み込み直す。再読込ループ防止に `LoadStateReducer.onContentProcessTerminated(retryCount:limit:)` で上限 3 回、超えたらエラー画面 |
| アプリ再起動 | 新しい WebView。atom も当然空 → 入口から |

## なぜこの方針か

- **端末に痕跡を残さない**（ディスク、DevTools の Application タブ、次回起動への漏れ）ことを優先。
- 代償は「リロード＝やり直し」。認証フローは短く、UX 上のダイアログで受け止められる範囲。
- 減らせるのは永続リスクであって、XSS でページ内スクリプトから読まれるリスクは保存先に依らない。
  そこが脅威なら CSP・入力の即時サーバー送信など別対策が要る。

## 途中復帰まで残したくなったら

- `atoms.ts` を `atomWithStorage(..., sessionStorage)` に変える（Jotai のまま永続化）。
  ただし機微情報を保存することになる点は要検討。
- あるいは認証コードと認証済みフラグを**サーバー側セッション**に置く（本番はこれが正解。
  `output: 'export'` をやめて Route Handler が必要）。
