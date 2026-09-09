'use client';

import { useEffect, useState } from 'react';
import Box from '@mui/material/Box';
import Container from '@mui/material/Container';
import Step from '@mui/material/Step';
import StepLabel from '@mui/material/StepLabel';
import Stepper from '@mui/material/Stepper';
import Typography from '@mui/material/Typography';
import { useColorScheme } from '@mui/material/styles';

import { BridgeProvider, useBridge } from '../bridge-provider';
import { generateDummyCode, normalizePhoneNumber } from '../auth';
import { AppHeader } from './app-header';
import { CodeStep } from './code-step';
import { PhoneStep } from './phone-step';
import { ResultStep } from './result-step';
import { ThemeGate } from './theme-gate';

type Phase = 'phone' | 'code' | 'result';

const STEP_LABELS = ['電話番号', '認証コード', '結果確認'];
const PHASE_INDEX: Record<Phase, number> = { phone: 0, code: 1, result: 2 };

/** Web の配色をネイティブ側にも反映させる（初回マウント時と切り替え時の両方）。 */
function NativeThemeSync() {
  const { colorScheme } = useColorScheme();
  const { hydrated, supports, syncTheme } = useBridge();

  useEffect(() => {
    if (!hydrated || !colorScheme || !supports('setAppTheme')) return;
    syncTheme(colorScheme);
  }, [hydrated, colorScheme, supports, syncTheme]);

  return null;
}

function Flow() {
  const { notifyVerified } = useBridge();

  const [phase, setPhase] = useState<Phase>('phone');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [sentCode, setSentCode] = useState('');
  const [verifiedAt, setVerifiedAt] = useState('');

  function sendCode(input: string) {
    const code = generateDummyCode();
    setSentCode(code);
    setPhoneNumber(normalizePhoneNumber(input));
    setPhase('code');
    console.log(`[auth] ダミーコードを生成しました: ${code}`);
  }

  function handleVerified() {
    const at = new Date().toISOString();
    setVerifiedAt(at);
    setPhase('result');
    notifyVerified({ phoneNumber, verifiedAt: at });
  }

  function restart() {
    setPhase('phone');
    setSentCode('');
    setVerifiedAt('');
  }

  return (
    <Box sx={{ minHeight: '100dvh', bgcolor: 'background.default' }}>
      <AppHeader />
      <Container maxWidth="sm" component="main" sx={{ py: 3 }}>
        <Stepper activeStep={PHASE_INDEX[phase]} alternativeLabel sx={{ mb: 3 }}>
          {STEP_LABELS.map((label) => (
            <Step key={label}>
              <StepLabel>{label}</StepLabel>
            </Step>
          ))}
        </Stepper>

        {phase === 'phone' && <PhoneStep initialValue={phoneNumber} onSubmit={sendCode} />}
        {phase === 'code' && (
          <CodeStep
            phoneNumber={phoneNumber}
            sentCode={sentCode}
            onResend={() => sendCode(phoneNumber)}
            onVerified={handleVerified}
            onBack={() => setPhase('phone')}
          />
        )}
        {phase === 'result' && <ResultStep phoneNumber={phoneNumber} verifiedAt={verifiedAt} onRestart={restart} />}

        <Typography variant="caption" color="text.disabled" component="p" sx={{ mt: 3, textAlign: 'center' }}>
          Next.js (静的エクスポート) + MUI / SMS 認証コードはダミーです
        </Typography>
      </Container>
    </Box>
  );
}

export function AuthFlow() {
  return (
    <BridgeProvider>
      <NativeThemeSync />
      <ThemeGate>
        <Flow />
      </ThemeGate>
    </BridgeProvider>
  );
}
