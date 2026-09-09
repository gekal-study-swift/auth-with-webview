'use client';

import { useRouter } from 'next/navigation';
import { useAtom, useSetAtom } from 'jotai';
import { RESET } from 'jotai/utils';

import { generateDummyCode, normalizePhoneNumber } from './auth';
import { phoneNumberAtom, sentCodeAtom, verifiedAtAtom } from './atoms';
import { PhoneStep } from './components/phone-step';

/** ステップ 1: 電話番号を入力してダミーコードを生成し、`/verify` へ進む。 */
export default function PhonePage() {
  const router = useRouter();
  const [phoneNumber, setPhoneNumber] = useAtom(phoneNumberAtom);
  const setSentCode = useSetAtom(sentCodeAtom);
  const setVerifiedAt = useSetAtom(verifiedAtAtom);

  function handleSubmit(input: string) {
    const code = generateDummyCode();
    setPhoneNumber(normalizePhoneNumber(input));
    setSentCode(code);
    setVerifiedAt(RESET);
    console.log(`[auth] ダミーコードを生成しました: ${code}`);
    router.push('/verify');
  }

  // 「電話番号を入力し直す」で戻ってきたときは前回の値を初期表示する（メモリに残っていれば）
  return <PhoneStep initialValue={phoneNumber} onSubmit={handleSubmit} />;
}
