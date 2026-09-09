'use client';

import { useState, type FormEvent } from 'react';
import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Link from '@mui/material/Link';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';

import { CODE_LENGTH, formatPhoneNumber, isCodeMatch } from '../auth';
import { monoFontFamily } from '../theme';
import { MockSmsBanner } from './mock-sms-banner';

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

            <TextField
              label="6 桁の認証コード"
              placeholder="000000"
              // type=tel は iOS/Android とも電話ダイヤルパッド（数字のみ）を出す。
              // このキーボードには予測変換・辞書・自動修正のバーが無いため、
              // WKWebView 上でも入力が勝手に別の文字へ変わらない。MUI は type を input へ転送する。
              type="tel"
              value={code}
              onChange={(event) => handleChange(event.target.value)}
              error={failed}
              helperText={failed ? 'コードが一致しません。もう一度入力してください' : ' '}
              slotProps={{
                htmlInput: {
                  inputMode: 'numeric',
                  pattern: '[0-9]*',
                  // SMS 由来のコード自動入力（iOS の「メッセージから」）は残す。
                  autoComplete: 'one-time-code',
                  // 一方で、キーボードの辞書・予測変換・自動修正・自動大文字化は止める。
                  autoCorrect: 'off',
                  autoCapitalize: 'off',
                  spellCheck: false,
                  maxLength: CODE_LENGTH,
                  'aria-label': '6 桁の認証コード（数字のみ）',
                  style: {
                    fontFamily: monoFontFamily,
                    fontSize: '1.5rem',
                    letterSpacing: '0.5em',
                    textAlign: 'center',
                  },
                },
              }}
            />

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
