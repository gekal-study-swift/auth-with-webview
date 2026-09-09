'use client';

import { atom } from 'jotai';
import { atomWithReset, RESET } from 'jotai/utils';

/**
 * 認証フローで持ち回す状態。**メモリのみ**（永続化しない）。
 *
 * 電話番号や認証コードは機微情報のため sessionStorage / localStorage には残さない。
 * 画面遷移（`router.push`）や戻る/進むでは保持されるが、**フルリロードや WebView の
 * 再生成で消える**。消えたことは各ステップページの `FlowGuard` が検知し、
 * ダイアログでやり直しを促す。
 */
export const phoneNumberAtom = atomWithReset('');
export const sentCodeAtom = atomWithReset('');
export const verifiedAtAtom = atomWithReset('');

/** 3 つの atom をまとめて初期値に戻す（「最初からやり直す」用）。 */
export const resetFlowAtom = atom(null, (_get, set) => {
  set(phoneNumberAtom, RESET);
  set(sentCodeAtom, RESET);
  set(verifiedAtAtom, RESET);
});
