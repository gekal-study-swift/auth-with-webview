'use client';

import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

import { useBridge } from '../bridge-provider';
import { formatPhoneNumber, maskPhoneNumber } from '../auth';

interface ResultStepProps {
  phoneNumber: string;
  verifiedAt: string;
  onRestart: () => void;
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <Stack direction="row" spacing={2} sx={{ justifyContent: 'space-between' }}>
      <Typography variant="body2" color="text.secondary">
        {label}
      </Typography>
      <Typography variant="body2" sx={{ fontWeight: 600, textAlign: 'right' }}>
        {value}
      </Typography>
    </Stack>
  );
}

export function ResultStep({ phoneNumber, verifiedAt, onRestart }: ResultStepProps) {
  const { connected, envInfo, nativeAck } = useBridge();

  return (
    <Card>
      <CardContent>
        <Stack spacing={2.5}>
          <Stack spacing={1} sx={{ alignItems: 'center', textAlign: 'center', py: 1 }}>
            <CheckCircleIcon color="success" sx={{ fontSize: 56 }} />
            <Typography variant="h2" component="h2">
              認証が完了しました
            </Typography>
            <Typography variant="body2" color="text.secondary">
              電話番号の確認が取れました。
            </Typography>
          </Stack>

          <Divider />

          <Stack spacing={1.25}>
            <Row label="電話番号" value={maskPhoneNumber(phoneNumber)} />
            <Row label="入力値" value={formatPhoneNumber(phoneNumber)} />
            <Row label="認証時刻" value={new Date(verifiedAt).toLocaleString('ja-JP')} />
          </Stack>

          <Divider />

          <Stack spacing={1.25}>
            <Typography variant="subtitle2">ネイティブ連携</Typography>
            {connected ? (
              <>
                <Row label="実行環境" value="WKWebView" />
                {envInfo && (
                  <>
                    <Row label="プラットフォーム" value={`${envInfo.platform} ${envInfo.systemVersion}`} />
                    <Row label="アプリ" value={`${envInfo.bundleIdentifier} (${envInfo.appVersion})`} />
                  </>
                )}
                <Box
                  sx={{
                    p: 1.25,
                    borderRadius: 2,
                    bgcolor: 'action.hover',
                    fontSize: 13,
                    color: nativeAck ? 'success.main' : 'text.secondary',
                  }}
                >
                  {nativeAck ?? 'ネイティブへ通知しました（応答待ち）'}
                </Box>
              </>
            ) : (
              <Typography variant="body2" color="text.secondary">
                ブラウザで表示中のため、ネイティブへの通知は行われません。iOS アプリ内で開くと
                触覚フィードバックとトーストで結果が返ります。
              </Typography>
            )}
          </Stack>

          <Button variant="outlined" size="large" onClick={onRestart}>
            最初からやり直す
          </Button>
        </Stack>
      </CardContent>
    </Card>
  );
}
