'use client';

import { useRouter } from 'next/navigation';
import { useAtom, useAtomValue, useSetAtom } from 'jotai';

import { generateDummyCode } from '../auth';
import { phoneNumberAtom, sentCodeAtom, verifiedAtAtom } from '../atoms';
import { useBridge } from '../bridge-provider';
import { CodeStep } from '../components/code-step';
import { FlowGuard } from '../components/flow-guard';

function VerifyInner() {
  const router = useRouter();
  const { notifyVerified } = useBridge();
  const phoneNumber = useAtomValue(phoneNumberAtom);
  const [sentCode, setSentCode] = useAtom(sentCodeAtom);
  const setVerifiedAt = useSetAtom(verifiedAtAtom);

  function resend() {
    const code = generateDummyCode();
    setSentCode(code);
    console.log(`[auth] ダミーコードを再生成しました: ${code}`);
  }

  function handleVerified() {
    const verifiedAt = new Date().toISOString();
    setVerifiedAt(verifiedAt);
    notifyVerified({ phoneNumber, verifiedAt });
    router.push('/result');
  }

  return (
    <CodeStep
      phoneNumber={phoneNumber}
      sentCode={sentCode}
      onResend={resend}
      onVerified={handleVerified}
      onBack={() => router.push('/')}
    />
  );
}

/** ステップ 2: 6 桁コードを入力する。成功したらネイティブへ通知し `/result` へ。 */
export default function VerifyPage() {
  return (
    <FlowGuard require="code">
      <VerifyInner />
    </FlowGuard>
  );
}
