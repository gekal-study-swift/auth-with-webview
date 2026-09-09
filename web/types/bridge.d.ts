/**
 * ネイティブ（WKWebView）から注入される JavaScript ブリッジと、
 * ネイティブ側が `evaluateJavaScript` で呼び出すグローバル関数の型定義。
 *
 * @see AuthWithWebView/WebViewController.swift
 */

declare global {
  /**
   * ブラウザで開いた場合はメソッドが存在しないため、すべて optional として定義し
   * 実行時にチェックする。
   */
  interface NativeAuthInterface {
    /** ネイティブ側の配色を Web と揃える。`'light'` / `'dark'` / `'system'`。 */
    setAppTheme?: (theme: 'light' | 'dark' | 'system') => void;
    /** 認証成功をネイティブに通知する。ネイティブは触覚フィードバック + トーストで応答する。 */
    onVerified?: (payloadJson: string) => void;
    /** 実行環境の情報を JSON 文字列で同期的に返す。 */
    getEnvInfo?: () => string;
  }

  /** `getEnvInfo()` が返す JSON をパースした形。 */
  interface EnvInfo {
    platform: string;
    systemVersion: string;
    appVersion: string;
    bundleIdentifier: string;
  }

  interface Window {
    /** JS -> Native。WKWebView 側で `window.NativeAuth` として注入される。 */
    NativeAuth?: NativeAuthInterface;
    /** Native -> JS。`onVerified` の受領確認としてネイティブから呼ばれる。 */
    handleNativeAck?: (message: string) => void;
  }
}

export {};
