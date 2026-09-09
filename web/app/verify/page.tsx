'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

import { generateDummyCode } from '../auth';
import { getAuthSession, updateAuthSession, type AuthSession } from '../auth-session';
import { useBridge } from '../bridge-provider';
import { CodeStep } from '../components/code-step';

/** ステップ 2: 6 桁コードを入力する。成功したらネイティブへ通知し `/result` へ。 */
export default function VerifyPage() {
  const router = useRouter();
  const { notifyVerified } = useBridge();
  const [session, setSession] = useState<AuthSession | null>(null);

  // 直リンクやリロードで前提の状態が無ければ最初の画面へ戻す
  useEffect(() => {
    const current = getAuthSession();
    if (!current.phoneNumber || !current.sentCode) {
      router.replace('/');
      return;
    }
    setSession(current);
  }, [router]);

  if (!session?.phoneNumber || !session.sentCode) return null;

  const phoneNumber = session.phoneNumber;

  function resend() {
    const code = generateDummyCode();
    updateAuthSession({ sentCode: code });
    setSession((prev) => (prev ? { ...prev, sentCode: code } : prev));
    console.log(`[auth] ダミーコードを再生成しました: ${code}`);
  }

  function handleVerified() {
    const verifiedAt = new Date().toISOString();
    updateAuthSession({ verifiedAt });
    notifyVerified({ phoneNumber, verifiedAt });
    router.push('/result');
  }

  return (
    <CodeStep
      phoneNumber={phoneNumber}
      sentCode={session.sentCode}
      onResend={resend}
      onVerified={handleVerified}
      onBack={() => router.push('/')}
    />
  );
}
