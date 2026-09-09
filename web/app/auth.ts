/**
 * 認証フローの純粋ロジック。UI から切り離してあるので単体で追える。
 *
 * SMS 送信は行わない。「送信」時に 6 桁のダミーコードを生成し、画面に表示する。
 */

export const CODE_LENGTH = 6;

/** 入力から数字だけを取り出す（ハイフン・空白・国番号の記号を落とす）。 */
export function normalizePhoneNumber(input: string): string {
  const digits = input.replace(/\D/g, '');
  // +81 / 0081 で始まる国際表記は日本の国内表記（先頭 0）に寄せる
  if (digits.startsWith('81') && digits.length >= 11) {
    return `0${digits.slice(2)}`;
  }
  return digits;
}

/** 日本の携帯・固定番号として妥当か。先頭 0 + 全体で 10〜11 桁。 */
export function isValidPhoneNumber(input: string): boolean {
  const normalized = normalizePhoneNumber(input);
  return /^0\d{9,10}$/.test(normalized);
}

/** 表示用に整形する（090-1234-5678 / 03-1234-5678）。 */
export function formatPhoneNumber(input: string): string {
  const n = normalizePhoneNumber(input);
  if (n.length === 11) return `${n.slice(0, 3)}-${n.slice(3, 7)}-${n.slice(7)}`;
  if (n.length === 10) return `${n.slice(0, 2)}-${n.slice(2, 6)}-${n.slice(6)}`;
  return n;
}

/** 結果画面向けに中央を伏せる（090-****-5678）。 */
export function maskPhoneNumber(input: string): string {
  const formatted = formatPhoneNumber(input);
  const parts = formatted.split('-');
  if (parts.length !== 3) return formatted;
  return `${parts[0]}-${'*'.repeat(parts[1].length)}-${parts[2]}`;
}

/** ダミーの 6 桁コードを生成する（先頭 0 も許容）。 */
export function generateDummyCode(): string {
  return Array.from({ length: CODE_LENGTH }, () => Math.floor(Math.random() * 10)).join('');
}

/** 入力コードが送信済みコードと一致するか。桁数を満たさないうちは false。 */
export function isCodeMatch(input: string, sentCode: string): boolean {
  const digits = input.replace(/\D/g, '');
  return digits.length === CODE_LENGTH && digits === sentCode;
}
