'use client';

import { useRouter } from 'next/navigation';
import { useAtomValue, useSetAtom } from 'jotai';

import { phoneNumberAtom, resetFlowAtom, verifiedAtAtom } from '../atoms';
import { ResultStep } from '../components/result-step';
import { FlowGuard } from '../components/flow-guard';

function ResultInner() {
  const router = useRouter();
  const phoneNumber = useAtomValue(phoneNumberAtom);
  const verifiedAt = useAtomValue(verifiedAtAtom);
  const resetFlow = useSetAtom(resetFlowAtom);

  function restart() {
    resetFlow();
    router.push('/');
  }

  return <ResultStep phoneNumber={phoneNumber} verifiedAt={verifiedAt} onRestart={restart} />;
}

/** ステップ 3: 結果確認。「最初からやり直す」で状態を消して `/` へ。 */
export default function ResultPage() {
  return (
    <FlowGuard require="result">
      <ResultInner />
    </FlowGuard>
  );
}
