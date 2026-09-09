'use client';

/**
 * ステップ（ページ）をまたいで持ち回す認証フローの状態。
 *
 * ページ遷移で持ち越すため sessionStorage に置く。タブを閉じれば消える。
 * 電話番号を URL に載せない（クエリに個人情報を出さない）ための置き場でもある。
 */
export interface AuthSession {
  /** 正規化済みの電話番号。 */
  phoneNumber?: string;
  /** 「送信」したことにしたダミーの 6 桁コード。 */
  sentCode?: string;
  /** 認証が完了した時刻（ISO 文字列）。 */
  verifiedAt?: string;
}

const KEY = 'auth-session';

export function getAuthSession(): AuthSession {
  if (typeof window === 'undefined') return {};
  try {
    return JSON.parse(window.sessionStorage.getItem(KEY) ?? '{}') as AuthSession;
  } catch {
    return {};
  }
}

export function updateAuthSession(patch: Partial<AuthSession>): void {
  if (typeof window === 'undefined') return;
  try {
    window.sessionStorage.setItem(KEY, JSON.stringify({ ...getAuthSession(), ...patch }));
  } catch {
    // プライベートブラウズなどで sessionStorage が使えなくても致命的ではない
  }
}

export function clearAuthSession(): void {
  if (typeof window === 'undefined') return;
  try {
    window.sessionStorage.removeItem(KEY);
  } catch {
    // no-op
  }
}
