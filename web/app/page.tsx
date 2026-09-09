'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

import { generateDummyCode, normalizePhoneNumber } from './auth';
import { getAuthSession, updateAuthSession } from './auth-session';
import { PhoneStep } from './components/phone-step';

/** ステップ 1: 電話番号を入力してダミーコードを生成し、`/verify` へ進む。 */
export default function PhonePage() {
  const router = useRouter();
  const [initialValue, setInitialValue] = useState('');
  const [ready, setReady] = useState(false);

  // 「電話番号を入力し直す」で戻ってきたときは前回の値を初期表示する
  useEffect(() => {
    setInitialValue(getAuthSession().phoneNumber ?? '');
    setReady(true);
  }, []);

  function handleSubmit(input: string) {
    const code = generateDummyCode();
    updateAuthSession({
      phoneNumber: normalizePhoneNumber(input),
      sentCode: code,
      verifiedAt: undefined,
    });
    console.log(`[auth] ダミーコードを生成しました: ${code}`);
    router.push('/verify');
  }

  if (!ready) return null;

  return <PhoneStep initialValue={initialValue} onSubmit={handleSubmit} />;
}
