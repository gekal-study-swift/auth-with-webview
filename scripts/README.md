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
# 1. WebView が読み込む Web ページのローカルサーバーを起動（別シェルで動かしたまま）
pnpm --dir web install
pnpm --dir web dev            # http://localhost:3000

# 2. シミュレータに入れて起動
./scripts/simulator-install.sh --launch

# 3. ロジックのユニットテスト
./scripts/test.sh
```

`Debug` ビルドは `http://localhost:3000` を読み込む（`Supporting/Info.plist` の ATS 例外で
localhost の平文 HTTP を許可している）。`Release` ビルドは配信サイト
`https://gekal-study-swift.github.io/auth-with-webview/` を読み込むため、ローカルサーバーは不要。

実機の `Debug` で動かす場合は、`localhost` が実機自身を指してしまうため、
`AuthWithWebView/WebViewController.swift` の `targetURL` を Mac の LAN IP
（例: `http://192.168.1.10:3000/`）に書き換えるか、`Release` を使う。

## 署名

`DEVELOPMENT_TEAM` は未設定。シミュレータは署名不要でそのまま動く。
実機に入れるときは初回だけ Xcode でプロジェクトを開き、
ターゲット > Signing & Capabilities で Team を選ぶ（自動署名）。
