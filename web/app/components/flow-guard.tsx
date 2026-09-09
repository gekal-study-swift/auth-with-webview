'use client';

import { useEffect, useState, type ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { useAtomValue, useSetAtom } from 'jotai';
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';

import { phoneNumberAtom, resetFlowAtom, sentCodeAtom, verifiedAtAtom } from '../atoms';

/** そのステップに必要な前提。 */
type Requirement = 'code' | 'result';

/**
 * ステップページ（`/verify` `/result`）を包み、必要な状態が無ければ
 * 「セッションが切れました」ダイアログを出して最初の画面に戻す。
 *
 * 状態はメモリのみ（`atoms.ts`）。SPA 遷移では消えないので、
 * ここに来て状態が空 = フルリロードか直リンク、と判断できる。
 */
export function FlowGuard({ require: requirement, children }: { require: Requirement; children: ReactNode }) {
  const router = useRouter();
  const phoneNumber = useAtomValue(phoneNumberAtom);
  const sentCode = useAtomValue(sentCodeAtom);
  const verifiedAt = useAtomValue(verifiedAtAtom);
  const resetFlow = useSetAtom(resetFlowAtom);

  // プリレンダ／ハイドレーション時は atom が初期値になるため、判定はマウント後に行う
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  const satisfied = requirement === 'code' ? Boolean(phoneNumber && sentCode) : Boolean(phoneNumber && verifiedAt);

  if (!mounted) return null;

  if (!satisfied) {
    // onClose を渡さないので、背景クリックや Esc では閉じない（open はこちらで固定）
    return (
      <Dialog open aria-labelledby="flow-expired-title">
        <DialogTitle id="flow-expired-title">セッションが切れました</DialogTitle>
        <DialogContent>
          <DialogContentText variant="body2">
            安全のため、入力内容は端末に保存していません。画面の再読み込みなどで情報が失われたため、
            認証を最初からやり直してください。
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button
            variant="contained"
            onClick={() => {
              resetFlow();
              router.replace('/');
            }}
          >
            最初からやり直す
          </Button>
        </DialogActions>
      </Dialog>
    );
  }

  return <>{children}</>;
}
