import type { NextConfig } from 'next';

import { basePath } from './base-path';

/**
 * GitHub Pages で配信するため、静的エクスポート + basePath を指定する。
 * カスタムドメインでルート配信する場合は basePath は空のままでよい。
 */
const nextConfig: NextConfig = {
  output: 'export',
  // ステップごとに /verify /result のページを持つため、静的ホスティングで
  // 確実に配信できる `<route>/index.html` 形式で書き出す。
  trailingSlash: true,
  basePath,
  assetPrefix: basePath || undefined,
  images: { unoptimized: true },
};

export default nextConfig;
