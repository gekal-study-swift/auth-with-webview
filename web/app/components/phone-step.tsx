'use client';

import { useState, type FormEvent } from 'react';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import InputAdornment from '@mui/material/InputAdornment';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import SmsIcon from '@mui/icons-material/Sms';

import { isValidPhoneNumber } from '../auth';

interface PhoneStepProps {
  initialValue: string;
  onSubmit: (phoneNumber: string) => void;
}

export function PhoneStep({ initialValue, onSubmit }: PhoneStepProps) {
  const [value, setValue] = useState(initialValue);
  const [touched, setTouched] = useState(false);

  const valid = isValidPhoneNumber(value);
  const showError = touched && value.length > 0 && !valid;

  function handleSubmit(event: FormEvent) {
    event.preventDefault();
    setTouched(true);
    if (valid) {
      onSubmit(value);
    }
  }

  return (
    <Card>
      <CardContent component="form" onSubmit={handleSubmit}>
        <Stack spacing={2.5}>
          <Stack spacing={0.5}>
            <Typography variant="h2" component="h2">
              電話番号を入力
            </Typography>
            <Typography variant="body2" color="text.secondary">
              この番号に認証コードを送信します（このサンプルでは送信せず画面に表示します）。
            </Typography>
          </Stack>

          <TextField
            label="携帯電話番号"
            placeholder="090-1234-5678"
            type="tel"
            inputMode="tel"
            autoComplete="tel"
            value={value}
            onChange={(event) => setValue(event.target.value)}
            onBlur={() => setTouched(true)}
            error={showError}
            helperText={showError ? '日本の電話番号（10〜11 桁）を入力してください' : ' '}
            slotProps={{
              input: {
                startAdornment: (
                  <InputAdornment position="start">
                    <SmsIcon fontSize="small" />
                  </InputAdornment>
                ),
              },
            }}
          />

          <Button type="submit" variant="contained" size="large" disabled={!valid}>
            認証コードを送信
          </Button>
        </Stack>
      </CardContent>
    </Card>
  );
}
