import type { NextConfig } from 'next';

import { basePath } from './base-path';

/**
 * GitHub Pages で配信するため、静的エクスポート + basePath を指定する。
 * カスタムドメインでルート配信する場合は basePath は空のままでよい。
 */
const nextConfig: NextConfig = {
  output: 'export',
  basePath,
  assetPrefix: basePath || undefined,
  images: { unoptimized: true },
};

export default nextConfig;
