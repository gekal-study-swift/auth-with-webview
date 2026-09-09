import Testing

@testable import AuthWithWebView

struct LinkPolicyTests {
    private let targetHost = "auth-with-webview.ios.demo.gekal.cn"

    @Test func resolve_sameHostHTTPS_staysInWebView() {
        #expect(LinkPolicy.resolve(scheme: "https", host: targetHost, targetHost: targetHost) == .inWebView)
        // 大文字小文字は無視する
        #expect(LinkPolicy.resolve(scheme: "HTTPS", host: targetHost.uppercased(), targetHost: targetHost) == .inWebView)
    }

    @Test func resolve_otherHostHTTPS_opensInAppBrowser() {
        #expect(LinkPolicy.resolve(scheme: "https", host: "example.com", targetHost: targetHost) == .safariViewController)
    }

    @Test func resolve_nonWebScheme_goesToExternalApp() {
        #expect(LinkPolicy.resolve(scheme: "tel", host: nil, targetHost: targetHost) == .externalApp)
        #expect(LinkPolicy.resolve(scheme: "mailto", host: nil, targetHost: targetHost) == .externalApp)
        #expect(LinkPolicy.resolve(scheme: nil, host: nil, targetHost: targetHost) == .externalApp)
    }

    @Test func isBrowsableURL_allowsOnlyHTTPScheme() {
        #expect(LinkPolicy.isBrowsableURL(scheme: "https"))
        #expect(LinkPolicy.isBrowsableURL(scheme: "http"))
        #expect(!LinkPolicy.isBrowsableURL(scheme: "javascript"))
        #expect(!LinkPolicy.isBrowsableURL(scheme: "file"))
        #expect(!LinkPolicy.isBrowsableURL(scheme: nil))
    }
}
