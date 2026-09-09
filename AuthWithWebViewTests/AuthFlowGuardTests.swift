import Foundation
import Testing

@testable import AuthWithWebView

struct AuthFlowGuardTests {
    @Test func phoneStep_isAlwaysAllowed() {
        #expect(AuthFlowGuard.canShow(.phone, phoneNumber: "", sentCode: "", verifiedAt: nil))
    }

    @Test func codeStep_needsPhoneAndSentCode() {
        #expect(!AuthFlowGuard.canShow(.code, phoneNumber: "", sentCode: "", verifiedAt: nil))
        #expect(!AuthFlowGuard.canShow(.code, phoneNumber: "09012345678", sentCode: "", verifiedAt: nil))
        #expect(AuthFlowGuard.canShow(.code, phoneNumber: "09012345678", sentCode: "123456", verifiedAt: nil))
    }

    @Test func resultStep_needsPhoneAndVerifiedAt() {
        #expect(!AuthFlowGuard.canShow(.result, phoneNumber: "09012345678", sentCode: "123456", verifiedAt: nil))
        #expect(AuthFlowGuard.canShow(.result, phoneNumber: "09012345678", sentCode: "123456", verifiedAt: Date()))
    }
}
