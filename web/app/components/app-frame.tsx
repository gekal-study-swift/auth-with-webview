'use client';

import { useEffect, type ReactNode } from 'react';
import Box from '@mui/material/Box';
import Container from '@mui/material/Container';
import Step from '@mui/material/Step';
import StepLabel from '@mui/material/StepLabel';
import Stepper from '@mui/material/Stepper';
import Typography from '@mui/material/Typography';
import { useColorScheme } from '@mui/material/styles';
import { usePathname } from 'next/navigation';

import { BridgeProvider, useBridge } from '../bridge-provider';
import { AppHeader } from './app-header';
import { ThemeGate } from './theme-gate';

const STEP_LABELS = ['電話番号', '認証コード', '結果確認'];
const STEP_INDEX: Record<string, number> = { '/': 0, '/verify': 1, '/result': 2 };

/** Web の配色をネイティブ側にも反映させる（初回マウント時と切り替え時の両方）。 */
function NativeThemeSync() {
  const { colorScheme } = useColorScheme();
  const { hydrated, supports, syncTheme } = useBridge();

  useEffect(() => {
    if (!hydrated || !colorScheme || !supports('setAppTheme')) return;
    syncTheme(colorScheme);
  }, [hydrated, colorScheme, supports, syncTheme]);

  return null;
}

/** 現在のパスからステップ位置を出すインジケータ。 */
function StepIndicator() {
  const pathname = usePathname();
  const key = pathname.replace(/\/+$/, '') || '/';
  const active = STEP_INDEX[key] ?? 0;

  return (
    <Stepper activeStep={active} alternativeLabel sx={{ mb: 3 }}>
      {STEP_LABELS.map((label) => (
        <Step key={label}>
          <StepLabel>{label}</StepLabel>
        </Step>
      ))}
    </Stepper>
  );
}

/**
 * 全ステップ共通の枠。ヘッダ・ステッパー・ブリッジ・テーマ同期をまとめ、
 * 中身（各ステップのページ）を差し込む。`layout.tsx` から使う。
 */
export function AppFrame({ children }: { children: ReactNode }) {
  return (
    <BridgeProvider>
      <NativeThemeSync />
      <ThemeGate>
        <Box sx={{ minHeight: '100dvh', bgcolor: 'background.default' }}>
          <AppHeader />
          <Container maxWidth="sm" component="main" sx={{ py: 3 }}>
            <StepIndicator />
            {children}
            <Typography variant="caption" color="text.disabled" component="p" sx={{ mt: 3, textAlign: 'center' }}>
              Next.js (静的エクスポート) + MUI / SMS 認証コードはダミーです
            </Typography>
          </Container>
        </Box>
      </ThemeGate>
    </BridgeProvider>
  );
}
