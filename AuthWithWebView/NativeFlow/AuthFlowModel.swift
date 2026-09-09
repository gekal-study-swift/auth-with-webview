import Foundation

/// フローのステップ。Web 版のルート（`/` `/verify` `/result`）に対応する。
enum AuthStep {
    case phone
    case code
    case result
}

/// そのステップを表示してよいかの判定。Web 版の `FlowGuard`（`require: 'code' | 'result'`）と同じ。
///
/// UI に依存しないため Swift Testing で検証できる（`AuthFlowGuardTests`）。
enum AuthFlowGuard {
    static func canShow(_ step: AuthStep, phoneNumber: String, sentCode: String, verifiedAt: Date?) -> Bool {
        switch step {
        case .phone:
            return true
        case .code:
            return !phoneNumber.isEmpty && !sentCode.isEmpty
        case .result:
            return !phoneNumber.isEmpty && verifiedAt != nil
        }
    }
}

/// 認証フローの状態。**メモリのみ**（永続化しない）。
///
/// Web 版が Jotai の atom（`web/app/atoms.ts`）でやっているのと同じ方針。
/// 電話番号・コードは機微情報として `UserDefaults` などに残さない。
/// ネイティブでは画面のリロードが無いため通常は状態が消えないが、
/// 比較用に ``discardState()`` で「WebView リロード相当」の消失を起こせる。
@MainActor
@Observable
final class AuthFlowModel {
    private(set) var step: AuthStep = .phone
    private(set) var phoneNumber = ""
    private(set) var sentCode = ""
    private(set) var verifiedAt: Date?

    /// ガードに引っかかったときにやり直しダイアログを出すためのフラグ。
    var showExpiredAlert = false

    /// 電話番号を確定し、ダミーコードを生成してコード入力へ進む。
    func sendCode(to input: String) {
        phoneNumber = AuthLogic.normalize(input)
        sentCode = AuthLogic.generateDummyCode()
        verifiedAt = nil
        step = .code
    }

    /// ダミーコードを作り直す（再送）。
    func resend() {
        sentCode = AuthLogic.generateDummyCode()
    }

    /// コードを検証する。一致したら結果へ進み true、違えば false。
    func verify(_ input: String) -> Bool {
        guard AuthLogic.isMatch(input, sentCode) else { return false }
        verifiedAt = Date()
        step = .result
        return true
    }

    /// 電話番号だけ残してステップ 1 へ戻る（「電話番号を入力し直す」）。
    func backToPhone() {
        sentCode = ""
        verifiedAt = nil
        step = .phone
    }

    /// すべて初期化する（「最初からやり直す」）。
    func restart() {
        step = .phone
        phoneNumber = ""
        sentCode = ""
        verifiedAt = nil
        showExpiredAlert = false
    }

    /// 比較用：WebView のリロードで Jotai atom が消えるのと同じ状況を作る。
    /// フィールドだけ空にしてステップは変えないので、``enforceGuard()`` が拾ってダイアログを出す。
    func discardState() {
        phoneNumber = ""
        sentCode = ""
        verifiedAt = nil
        enforceGuard()
    }

    /// 現在のステップに必要な状態が無ければステップ 1 へ戻し、ダイアログを出す。
    func enforceGuard() {
        guard !AuthFlowGuard.canShow(step, phoneNumber: phoneNumber, sentCode: sentCode, verifiedAt: verifiedAt)
        else { return }
        step = .phone
        showExpiredAlert = true
    }
}
