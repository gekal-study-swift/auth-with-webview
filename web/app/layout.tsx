import type { Metadata, Viewport } from 'next';
import type { ReactNode } from 'react';
import CssBaseline from '@mui/material/CssBaseline';
import InitColorSchemeScript from '@mui/material/InitColorSchemeScript';
import { ThemeProvider } from '@mui/material/styles';
import { AppRouterCacheProvider } from '@mui/material-nextjs/v16-appRouter';

import { basePath } from '../base-path';
import { BootStyle } from './boot-style';
import { AppFrame } from './components/app-frame';
import theme from './theme';
import { VConsoleLoader } from './vconsole-loader';

export const metadata: Metadata = {
  title: 'SMS 認証サンプル',
  description: '電話番号 → 6 桁コード → 結果確認の流れを WebView で動かすサンプル',
  icons: {
    icon: [
      { url: `${basePath}/icon.svg`, type: 'image/svg+xml', sizes: 'any' },
      { url: `${basePath}/favicon.ico`, type: 'image/x-icon', sizes: '16x16 32x32 48x48' },
    ],
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#f2f6f5' },
    { media: '(prefers-color-scheme: dark)', color: '#0e1414' },
  ],
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ja" suppressHydrationWarning>
      <head>
        <BootStyle />
      </head>
      <body>
        <InitColorSchemeScript attribute="class" defaultMode="system" />
        <AppRouterCacheProvider options={{ key: 'mui' }}>
          <ThemeProvider theme={theme} defaultMode="system">
            <CssBaseline />
            <AppFrame>{children}</AppFrame>
            <VConsoleLoader />
          </ThemeProvider>
        </AppRouterCacheProvider>
      </body>
    </html>
  );
}
