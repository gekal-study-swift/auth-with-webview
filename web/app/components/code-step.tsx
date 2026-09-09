'use client';

import { useState, type FormEvent } from 'react';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Link from '@mui/material/Link';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';

import { CODE_LENGTH, formatPhoneNumber, isCodeMatch } from '../auth';
import { MockSmsBanner } from './mock-sms-banner';
import { OtpInput } from './otp-input';

interface CodeStepProps {
  phoneNumber: string;
  sentCode: string;
  onResend: () => void;
  onVerified: () => void;
  onBack: () => void;
}

export function CodeStep({ phoneNumber, sentCode, onResend, onVerified, onBack }: CodeStepProps) {
  const [code, setCode] = useState('');
  const [failed, setFailed] = useState(false);

  const complete = code.length === CODE_LENGTH;

  // 入力は数字だけを受け付ける（貼り付けやハードウェアキーボードで英字が来ても落とす）。
  function handleChange(next: string) {
    setCode(next.replace(/\D/g, '').slice(0, CODE_LENGTH));
    setFailed(false);
  }

  function handleSubmit(event: FormEvent) {
    event.preventDefault();
    if (!complete) return;
    if (isCodeMatch(code, sentCode)) {
      setFailed(false);
      onVerified();
    } else {
      setFailed(true);
    }
  }

  return (
    <Stack spacing={2}>
      <MockSmsBanner
        code={sentCode}
        onResend={() => {
          setCode('');
          setFailed(false);
          onResend();
        }}
      />

      <Card>
        <CardContent component="form" onSubmit={handleSubmit}>
          <Stack spacing={2.5}>
            <Stack spacing={0.5}>
              <Typography variant="h2" component="h2">
                認証コードを入力
              </Typography>
              <Typography variant="body2" color="text.secondary">
                {formatPhoneNumber(phoneNumber)} に送信した 6 桁のコードを入力してください。
              </Typography>
            </Stack>

            <OtpInput length={CODE_LENGTH} value={code} onChange={handleChange} error={failed} />

            {failed && (
              <Alert severity="error" variant="outlined">
                入力されたコードは正しくありません。ダミー SMS に表示された 6 桁を入力してください。
              </Alert>
            )}

            <Button type="submit" variant="contained" size="large" disabled={!complete}>
              認証する
            </Button>

            <Typography variant="body2" sx={{ textAlign: 'center' }}>
              <Link component="button" type="button" underline="hover" onClick={onBack}>
                電話番号を入力し直す
              </Link>
            </Typography>
          </Stack>
        </CardContent>
      </Card>
    </Stack>
  );
}
