import Testing

@testable import AuthWithWebView

struct AuthLogicTests {
    @Test func normalize_stripsSeparatorsAndCountryCode() {
        #expect(AuthLogic.normalize("090-1234-5678") == "09012345678")
        #expect(AuthLogic.normalize("090 1234 5678") == "09012345678")
        #expect(AuthLogic.normalize("+81 90-1234-5678") == "09012345678")
        #expect(AuthLogic.normalize("03-1234-5678") == "0312345678")
    }

    @Test func isValid_acceptsJapaneseNumbersOnly() {
        #expect(AuthLogic.isValid("09012345678"))
        #expect(AuthLogic.isValid("0312345678"))
        #expect(AuthLogic.isValid("+81 90 1234 5678"))
        #expect(!AuthLogic.isValid("12345678901")) // 先頭が 0 でない
        #expect(!AuthLogic.isValid("090123456")) // 短い
        #expect(!AuthLogic.isValid("090123456789")) // 長い
        #expect(!AuthLogic.isValid(""))
    }

    @Test func format_matchesWebOutput() {
        #expect(AuthLogic.format("09012345678") == "090-1234-5678")
        #expect(AuthLogic.format("0312345678") == "03-1234-5678")
        #expect(AuthLogic.format("090123") == "090123") // 桁が揃わなければそのまま
    }

    @Test func mask_hidesTheMiddleGroup() {
        #expect(AuthLogic.mask("09012345678") == "090-****-5678")
        #expect(AuthLogic.mask("0312345678") == "03-****-5678")
    }

    @Test func generateDummyCode_isSixDigits() {
        let code = AuthLogic.generateDummyCode()
        let isAllDigits = code.allSatisfy(\.isNumber)
        #expect(code.count == 6)
        #expect(isAllDigits)
    }

    @Test func isMatch_requiresExactSixDigitMatch() {
        #expect(AuthLogic.isMatch("123456", "123456"))
        #expect(AuthLogic.isMatch("12 34 56", "123456")) // 数字以外は無視
        #expect(!AuthLogic.isMatch("12345", "123456")) // 桁不足
        #expect(!AuthLogic.isMatch("123457", "123456")) // 不一致
        #expect(!AuthLogic.isMatch("1234567", "123456")) // 桁超過
    }
}
