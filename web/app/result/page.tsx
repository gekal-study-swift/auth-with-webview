'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

import { clearAuthSession, getAuthSession, type AuthSession } from '../auth-session';
import { ResultStep } from '../components/result-step';

/** ステップ 3: 結果確認。「最初からやり直す」で状態を消して `/` へ。 */
export default function ResultPage() {
  const router = useRouter();
  const [session, setSession] = useState<AuthSession | null>(null);

  useEffect(() => {
    const current = getAuthSession();
    if (!current.phoneNumber || !current.verifiedAt) {
      router.replace('/');
      return;
    }
    setSession(current);
  }, [router]);

  if (!session?.phoneNumber || !session.verifiedAt) return null;

  function restart() {
    clearAuthSession();
    router.push('/');
  }

  return <ResultStep phoneNumber={session.phoneNumber} verifiedAt={session.verifiedAt} onRestart={restart} />;
}
