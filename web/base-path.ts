/**
 * 配信元のパス。
 *
 * GitHub Pages のプロジェクトサイト（gekal-study-swift.github.io/auth-with-webview/）で
 * 配信するため、本番ビルドでは `BASE_PATH=/auth-with-webview` を指定する
 * （`.github/workflows/pages.yml` が設定）。ローカルの `next dev` は既定の空のまま
 * ルート（http://localhost:3000/）で配信し、iOS の Debug ビルドもそれを読み込む。
 *
 * `next.config.ts` と、アイコンなど自前で URL を組み立てるメタデータの両方から参照する。
 */
export const basePath = process.env.BASE_PATH ?? '';
