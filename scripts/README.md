# scripts

開発用スクリプト。どこから実行してもリポジトリルートへ `cd` してから動く。
派生データは `.build/`（gitignore 済み）に出力する。

| スクリプト | 役割 |
| --- | --- |
| `simulator-install.sh` | シミュレータへビルド＆インストール（`--launch` で起動、`--simulator <名前>` で機種指定） |
| `device-install.sh` | 接続中の実機へビルド＆署名＆インストール（`--launch` / `--device` / `--configuration`） |
| `test.sh` | テスト実行。`unit`（既定・Swift Testing）または `all` |

いずれも `-h` / `--help` で使い方を表示する。

## よく使う流れ

```shell
# シミュレータに入れて起動（配信中の Web ページを読み込む。サーバー不要）
./scripts/simulator-install.sh --launch

# 実機に入れて起動（初回は Xcode で Signing の Team 設定が必要）
./scripts/device-install.sh --launch

# ロジックのユニットテスト
./scripts/test.sh
```

既定では `Debug` / `Release` とも配信サイト
`https://gekal-study-swift.github.io/auth-with-webview/` を読み込むため、ローカルサーバーは不要。
`Debug` は端末上でログを見るため `?vconsole=1` を付けている。

### ローカルの web/ を確認する場合

別シェルでローカルサーバーを起動し、`WebViewController.swift` の `Debug` 行を差し替える。

```shell
pnpm --dir web install
pnpm --dir web dev            # http://localhost:3000
```

`AuthWithWebView/WebViewController.swift` の `targetURL`（`#if DEBUG` 側）を
`http://localhost:3000/` にする。localhost の平文 HTTP は `Supporting/Info.plist` の
ATS 例外で許可済み。実機では `localhost` が実機自身を指すため、Mac の LAN IP
（例: `http://192.168.1.10:3000/`）にする。

## 署名

`DEVELOPMENT_TEAM` は未設定。シミュレータは署名不要でそのまま動く。
実機に入れるときは初回だけ Xcode でプロジェクトを開き、
ターゲット > Signing & Capabilities で Team を選ぶ（自動署名）。
