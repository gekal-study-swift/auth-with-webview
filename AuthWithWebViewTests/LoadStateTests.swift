import Foundation
import Testing

@testable import AuthWithWebView

struct LoadStateTests {
    @Test func onPageStarted_ignoresBlankURL() {
        #expect(LoadStateReducer.onPageStarted(.loaded, url: LoadStateReducer.blankURL) == .loaded)
        #expect(LoadStateReducer.onPageStarted(.loaded, url: URL(string: "https://example.com/")) == .loading)
    }

    @Test func onPageFinished_movesToLoadedOnlyFromLoading() {
        let real = URL(string: "https://example.com/")
        #expect(LoadStateReducer.onPageFinished(.loading, url: real) == .loaded)
        #expect(LoadStateReducer.onPageFinished(.error(detail: "x"), url: real) == .error(detail: "x"))
        #expect(LoadStateReducer.onPageFinished(.loading, url: LoadStateReducer.blankURL) == .loading)
    }

    @Test func onNavigationFailed_keepsStateOnCancellation() {
        let cancelled = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled)
        #expect(LoadStateReducer.onNavigationFailed(.loaded, error: cancelled) == .loaded)

        let policyChange = NSError(domain: "WebKitErrorDomain", code: 102)
        #expect(LoadStateReducer.onNavigationFailed(.loading, error: policyChange) == .loading)
    }

    @Test func onNavigationFailed_movesToErrorOnRealFailure() {
        let offline = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        if case .error = LoadStateReducer.onNavigationFailed(.loading, error: offline) {
            // 期待どおり
        } else {
            Issue.record("通信エラーでは .error に遷移するべき")
        }
    }

    @Test func onHTTPError_onlyForMainFrame() {
        if case .error = LoadStateReducer.onHTTPError(.loading, isForMainFrame: true, statusCode: 500) {
            // 期待どおり
        } else {
            Issue.record("メインフレームの HTTP 500 は .error に遷移するべき")
        }
        #expect(LoadStateReducer.onHTTPError(.loaded, isForMainFrame: false, statusCode: 404) == .loaded)
    }

    @Test func onContentProcessTerminated_reloadsUpToLimitThenErrors() {
        #expect(LoadStateReducer.onContentProcessTerminated(retryCount: 1, limit: 3) == .loading)
        #expect(LoadStateReducer.onContentProcessTerminated(retryCount: 3, limit: 3) == .loading)

        if case .error = LoadStateReducer.onContentProcessTerminated(retryCount: 4, limit: 3) {
            // 期待どおり：上限を超えたらエラー画面
        } else {
            Issue.record("再読込の上限を超えたら .error に遷移するべき")
        }
    }
}
