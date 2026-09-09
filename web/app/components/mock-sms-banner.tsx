'use client';

import Alert from '@mui/material/Alert';
import AlertTitle from '@mui/material/AlertTitle';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import SmsIcon from '@mui/icons-material/Sms';

import { monoFontFamily } from '../theme';

interface MockSmsBannerProps {
  code: string;
  onResend: () => void;
}

/**
 * ダミーの SMS を模した通知。実際の SMS は送信されないため、
 * 送信されたことにした 6 桁コードをここに表示する。
 */
export function MockSmsBanner({ code, onResend }: MockSmsBannerProps) {
  return (
    <Alert
      icon={<SmsIcon />}
      severity="info"
      variant="outlined"
      sx={{ alignItems: 'flex-start' }}
      action={
        <Button color="inherit" size="small" onClick={onResend}>
          再送
        </Button>
      }
    >
      <AlertTitle sx={{ mb: 0.5 }}>ダミー SMS（実際には送信されません）</AlertTitle>
      <Stack spacing={0.5}>
        <span>認証コードはこちらです。次の画面で入力してください。</span>
        <Box
          sx={{
            fontFamily: monoFontFamily,
            fontSize: '1.75rem',
            fontWeight: 700,
            letterSpacing: '0.4em',
            pl: '0.4em',
          }}
        >
          {code}
        </Box>
      </Stack>
    </Alert>
  );
}
