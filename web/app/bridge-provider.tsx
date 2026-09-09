'use client';

import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';

type NativeMethod = keyof NativeAuthInterface;
type CallableBridge = Record<string, ((...args: unknown[]) => unknown) | undefined>;

/** 認証成功時にネイティブへ渡すペイロード。 */
export interface VerifiedPayload {
  phoneNumber: string;
  verifiedAt: string;
}

interface BridgeContextValue {
  /** ハイドレーション完了後に true。SSR との差分を避けるため描画分岐に使う。 */
  hydrated: boolean;
  /** `window.NativeAuth` が存在するか（= WebView 上で動いているか）。 */
  connected: boolean;
  /** `getEnvInfo()` で取得した実行環境の情報。ブラウザ表示中は null。 */
  envInfo: EnvInfo | null;
  /** ネイティブが特定のメソッドを提供しているか。 */
  supports: (method: NativeMethod) => boolean;
  /** 配色をネイティブへ同期する。 */
  syncTheme: (theme: 'light' | 'dark' | 'system') => void;
  /** 認証成功をネイティブへ通知する。 */
  notifyVerified: (payload: VerifiedPayload) => void;
  /** `onVerified` の後にネイティブから届いた受領メッセージ。未受領なら null。 */
  nativeAck: string | null;
}

const BridgeContext = createContext<BridgeContextValue | null>(null);

function readBridge(): CallableBridge | undefined {
  return window.NativeAuth as CallableBridge | undefined;
}

function callNative(method: NativeMethod, args: unknown[] = []): unknown {
  const bridge = readBridge();
  const fn = bridge?.[method];
  if (typeof fn !== 'function') {
    console.warn(`[NativeAuth] ${method}() はこの環境にありません（ブラウザ表示中）`);
    return undefined;
  }
  try {
    const result = fn.apply(bridge, args);
    console.log(`[NativeAuth] ${method}(${args.map((a) => JSON.stringify(a)).join(', ')})`);
    return result;
  } catch (error) {
    console.error(`[NativeAuth] ${method}() の呼び出しに失敗`, error);
    return undefined;
  }
}

export function BridgeProvider({ children }: { children: ReactNode }) {
  const [hydrated, setHydrated] = useState(false);
  const [connected, setConnected] = useState(false);
  const [envInfo, setEnvInfo] = useState<EnvInfo | null>(null);
  const [nativeAck, setNativeAck] = useState<string | null>(null);
  const ackRef = useRef<(message: string) => void>(() => {});

  ackRef.current = (message: string) => {
    setNativeAck(message);
    console.log(`[NativeAuth] handleNativeAck('${message}')`);
  };

  useEffect(() => {
    window.handleNativeAck = (message: string) => ackRef.current(message);

    const bridge = readBridge();
    setHydrated(true);
    setConnected(Boolean(bridge));

    if (typeof bridge?.getEnvInfo === 'function') {
      try {
        setEnvInfo(JSON.parse(bridge.getEnvInfo() as string) as EnvInfo);
      } catch (error) {
        console.error('[NativeAuth] getEnvInfo() の JSON 解析に失敗', error);
      }
    }

    return () => {
      delete window.handleNativeAck;
    };
  }, []);

  const supports = useCallback((method: NativeMethod) => typeof readBridge()?.[method] === 'function', []);
  const syncTheme = useCallback((theme: 'light' | 'dark' | 'system') => {
    callNative('setAppTheme', [theme]);
  }, []);
  const notifyVerified = useCallback((payload: VerifiedPayload) => {
    callNative('onVerified', [JSON.stringify(payload)]);
  }, []);

  const value = useMemo<BridgeContextValue>(
    () => ({ hydrated, connected, envInfo, supports, syncTheme, notifyVerified, nativeAck }),
    [hydrated, connected, envInfo, supports, syncTheme, notifyVerified, nativeAck],
  );

  return <BridgeContext.Provider value={value}>{children}</BridgeContext.Provider>;
}

export function useBridge() {
  const context = useContext(BridgeContext);
  if (!context) {
    throw new Error('useBridge must be used within a BridgeProvider');
  }
  return context;
}
