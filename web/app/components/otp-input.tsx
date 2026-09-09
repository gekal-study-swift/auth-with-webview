'use client';

import { useRef, type ClipboardEvent, type FocusEvent, type KeyboardEvent } from 'react';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';

import { monoFontFamily } from '../theme';

interface OtpInputProps {
  length: number;
  /** 現在の入力値（`length` 文字以下の数字文字列）。 */
  value: string;
  onChange: (next: string) => void;
  error?: boolean;
}

/**
 * 1 文字ずつの入力ボックスを並べた認証コード入力。
 *
 * 1 マス 1 文字なので、iOS の予測変換・テキスト置換（「7」→「7days」など）や
 * 自動修正が働く余地が無い。数字キーボード（type="tel"）も維持する。
 * SMS 由来のコード自動入力（autocomplete="one-time-code"）は各マスに付ける。
 */
export function OtpInput({ length, value, onChange, error }: OtpInputProps) {
  const refs = useRef<(HTMLInputElement | null)[]>([]);

  const focus = (index: number) => {
    const clamped = Math.max(0, Math.min(index, length - 1));
    refs.current[clamped]?.focus();
    refs.current[clamped]?.select();
  };

  const setDigits = (next: string, focusIndex: number) => {
    onChange(next.replace(/\D/g, '').slice(0, length));
    focus(focusIndex);
  };

  const handleChange = (index: number, raw: string) => {
    const digits = raw.replace(/\D/g, '');

    if (digits.length === 0) {
      // このマスを消す
      setDigits(value.slice(0, index) + value.slice(index + 1), index);
      return;
    }
    if (digits.length === 1) {
      const nextValue = value.slice(0, index) + digits + value.slice(index + 1);
      setDigits(nextValue, index + 1);
      return;
    }
    // 貼り付け・自動入力でまとめて入ってきた場合は index から順に流し込む
    const nextValue = value.slice(0, index) + digits;
    setDigits(nextValue, index + digits.length);
  };

  const handleKeyDown = (index: number, event: KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Backspace' && !value[index] && index > 0) {
      event.preventDefault();
      setDigits(value.slice(0, index - 1) + value.slice(index), index - 1);
    } else if (event.key === 'ArrowLeft' && index > 0) {
      event.preventDefault();
      focus(index - 1);
    } else if (event.key === 'ArrowRight' && index < length - 1) {
      event.preventDefault();
      focus(index + 1);
    }
  };

  const handlePaste = (event: ClipboardEvent<HTMLInputElement>) => {
    const digits = event.clipboardData.getData('text').replace(/\D/g, '');
    if (!digits) return;
    event.preventDefault();
    setDigits(digits.slice(0, length), digits.length);
  };

  return (
    <Stack direction="row" spacing={1} sx={{ justifyContent: 'center' }}>
      {Array.from({ length }, (_, index) => (
        <TextField
          key={index}
          type="tel"
          value={value[index] ?? ''}
          onChange={(event) => handleChange(index, event.target.value)}
          error={error}
          slotProps={{
            htmlInput: {
              inputMode: 'numeric',
              pattern: '[0-9]*',
              maxLength: 1,
              autoComplete: 'one-time-code',
              autoCorrect: 'off',
              autoCapitalize: 'off',
              spellCheck: false,
              'aria-label': `認証コード ${index + 1} 桁目`,
              onKeyDown: (event: KeyboardEvent<HTMLInputElement>) => handleKeyDown(index, event),
              onPaste: handlePaste,
              onFocus: (event: FocusEvent<HTMLInputElement>) => event.currentTarget.select(),
              style: {
                textAlign: 'center',
                fontFamily: monoFontFamily,
                fontSize: '1.4rem',
                padding: '12px 0',
              },
            },
          }}
          sx={{ width: { xs: 44, sm: 52 } }}
        />
      ))}
    </Stack>
  );
}
