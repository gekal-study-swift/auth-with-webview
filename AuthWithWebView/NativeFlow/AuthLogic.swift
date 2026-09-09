import Foundation

/// 認証フローの純粋ロジック。`web/app/auth.ts` と同じ振る舞いを Swift で写したもの。
///
/// UI・OS に依存しないため Swift Testing で検証できる（`AuthLogicTests`）。
/// SMS は送信しない。「送信」時に 6 桁のダミーコードを生成して画面に表示する。
enum AuthLogic {
    static let codeLength = 6

    /// 入力から数字だけを取り出す。`+81` / `0081` の国際表記は国内表記（先頭 0）へ寄せる。
    static func normalize(_ input: String) -> String {
        let digits = input.filter(\.isNumber)
        if digits.hasPrefix("81"), digits.count >= 11 {
            return "0" + digits.dropFirst(2)
        }
        return digits
    }

    /// 日本の電話番号として妥当か。先頭 0 + 全体で 10〜11 桁。
    static func isValid(_ input: String) -> Bool {
        let normalized = normalize(input)
        return normalized.range(of: #"^0\d{9,10}$"#, options: .regularExpression) != nil
    }

    /// 表示用に整形する（090-1234-5678 / 03-1234-5678）。
    static func format(_ input: String) -> String {
        let n = normalize(input)
        switch n.count {
        case 11:
            return "\(n.prefix(3))-\(n.dropFirst(3).prefix(4))-\(n.dropFirst(7))"
        case 10:
            return "\(n.prefix(2))-\(n.dropFirst(2).prefix(4))-\(n.dropFirst(6))"
        default:
            return n
        }
    }

    /// 結果画面向けに中央を伏せる（090-****-5678）。
    static func mask(_ input: String) -> String {
        let formatted = format(input)
        let parts = formatted.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return formatted }
        return "\(parts[0])-\(String(repeating: "*", count: parts[1].count))-\(parts[2])"
    }

    /// ダミーの 6 桁コードを生成する（先頭 0 も許容）。
    static func generateDummyCode() -> String {
        (0 ..< codeLength).map { _ in String(Int.random(in: 0 ... 9)) }.joined()
    }

    /// 入力コードが送信済みコードと一致するか。桁数を満たさないうちは false。
    static func isMatch(_ input: String, _ sentCode: String) -> Bool {
        let digits = input.filter(\.isNumber)
        return digits.count == codeLength && digits == sentCode
    }
}
