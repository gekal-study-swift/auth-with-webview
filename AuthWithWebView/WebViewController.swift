import SafariServices
import UIKit
import WebKit

/// 認証フローの Web ページ (web/) を WKWebView で表示し、JS ⇄ Native を橋渡しする。
///
/// Web ページは `window.NativeAuth` を呼ぶ。iOS では `WKUserScript` で同名の API を注入し、
/// `WKScriptMessageHandler` でネイティブに渡す。
final class WebViewController: UIViewController {
    /// 読み込むページ。Debug はローカルの `pnpm --dir web dev`、Release は配信中のサイト。
    #if DEBUG
    private static let targetURL = URL(string: "http://localhost:3000/")!
    #else
    private static let targetURL = URL(string: "https://auth-with-webview.ios.demo.gekal.cn/")!
    #endif

    /// 配信元のホスト。これ以外の http(s) はアプリ内ブラウザ (SFSafariViewController) で開く。
    private static let targetHost = targetURL.host

    /// WebView で選ばれた配色を SwiftUI 側に伝える。
    var onAppThemeChanged: ((AppTheme) -> Void)?

    private var webView: WKWebView!
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorView = UIStackView()
    private let errorDetailLabel = UILabel()

    /// アプリ自身が読み込ませた URL（初回・再試行・空ページ）。リンク遷移と区別する。
    private var appRequestedURL: URL?

    private var state: LoadState = .loading {
        didSet {
            guard state != oldValue else { return }
            render()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureWebView()
        load(Self.targetURL)
    }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "nativeAuth")
    }

    private func configureView() {
        // セーフエリアの余白を Web コンテンツと同じ色にして、継ぎ目なく見せる
        view.backgroundColor = WebPalette.background

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)

        let title = UILabel()
        title.text = "ページを読み込めませんでした"
        title.textColor = .systemRed
        title.font = .preferredFont(forTextStyle: .headline)
        title.textAlignment = .center

        let message = UILabel()
        message.text = "通信状況を確認してから再試行してください。"
        message.textAlignment = .center
        message.numberOfLines = 0

        errorDetailLabel.font = .preferredFont(forTextStyle: .caption1)
        errorDetailLabel.textColor = .secondaryLabel
        errorDetailLabel.textAlignment = .center
        errorDetailLabel.numberOfLines = 0

        let retryButton = UIButton(type: .system)
        retryButton.configuration = .filled()
        retryButton.configuration?.title = "再試行"
        retryButton.addTarget(self, action: #selector(retry), for: .touchUpInside)

        errorView.axis = .vertical
        errorView.alignment = .center
        errorView.spacing = 12
        errorView.translatesAutoresizingMaskIntoConstraints = false
        [title, message, errorDetailLabel, retryButton].forEach(errorView.addArrangedSubview)
        errorView.isHidden = true
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            errorView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])
    }

    private func configureWebView() {
        let controller = WKUserContentController()
        controller.add(WeakScriptMessageHandler(self), name: "nativeAuth")
        controller.addUserScript(WKUserScript(
            source: bridgeScript(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        ))

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        configuration.websiteDataStore = .default()

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isInspectable = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        // 読み込み完了までの白い一瞬と、行き過ぎスクロール時の白い帯を防ぐ
        webView.backgroundColor = WebPalette.background
        webView.scrollView.backgroundColor = WebPalette.background
        view.insertSubview(webView, at: 0)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    /// WebView に注入するブリッジ。Web ページは `window.NativeAuth` を呼ぶ。
    ///
    /// `postMessage()` は値を返せないため、同期で値を返す `getEnvInfo` は JS 側に値を持たせる。
    private func bridgeScript() -> String {
        """
        (() => {
          const post = (method, args = []) => {
            window.webkit.messageHandlers.nativeAuth.postMessage({ method, args });
          };

          window.NativeAuth = {
            setAppTheme: theme => post('setAppTheme', [theme]),
            onVerified: payloadJson => post('onVerified', [payloadJson]),
            getEnvInfo: () => \(javaScriptStringLiteral(envInfoJSON))
          };
        })();
        """
    }

    /// 実行環境の情報。Web の結果確認画面に表示する。
    private var envInfoJSON: String {
        jsonString([
            "platform": UIDevice.current.systemName,
            "systemVersion": UIDevice.current.systemVersion,
            "appVersion": appVersion,
            "bundleIdentifier": Bundle.main.bundleIdentifier ?? "",
        ])
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func jsonString(_ value: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: value),
              let string = String(data: data, encoding: .utf8) else { return "{}" }
        return string
    }

    /// 文字列を JavaScript のリテラルに変換する（`"..."` を含む形で返す）。
    private func javaScriptStringLiteral(_ string: String) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: [string]),
              let array = String(data: data, encoding: .utf8) else { return "'{}'" }
        return String(array.dropFirst().dropLast())
    }

    private func load(_ url: URL) {
        appRequestedURL = url
        state = LoadStateReducer.onLoadRequested()
        webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
    }

    @objc private func retry() { load(Self.targetURL) }

    private func render() {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            errorView.isHidden = true
            webView.isHidden = false

        case .loaded:
            loadingIndicator.stopAnimating()
            errorView.isHidden = true
            webView.isHidden = false

        case .error(let detail):
            loadingIndicator.stopAnimating()
            errorDetailLabel.text = detail
            errorView.isHidden = false
            webView.isHidden = true
            // エラー画面を出すときは WebView を空にして、失敗したページを残さない
            webView.load(URLRequest(url: LoadStateReducer.blankURL))
        }
    }

    private func handleBridgeMessage(_ body: Any) {
        guard let payload = body as? [String: Any], let method = payload["method"] as? String else { return }
        let args = payload["args"] as? [Any] ?? []

        switch method {
        case "setAppTheme":
            onAppThemeChanged?(AppTheme.from(args.first as? String))

        case "onVerified":
            handleVerified(payloadJSON: args.first as? String)

        default:
            break
        }
    }

    /// Web から認証成功の通知を受けたときの応答。触覚フィードバックとトーストで返す。
    private func handleVerified(payloadJSON: String?) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)

        var phoneNumber: String?
        if let data = payloadJSON?.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            phoneNumber = object["phoneNumber"] as? String
        }

        let message = phoneNumber.map { "認証が完了しました（\($0)）" } ?? "認証が完了しました"
        showToast(message: message, duration: Toast.longDuration)

        // Web 側に受領を返す（結果確認画面に表示される）
        evaluate("window.handleNativeAck?.(\(javaScriptStringLiteral("ネイティブが認証完了を受け取りました")))")
    }

    private func evaluate(_ script: String) { webView.evaluateJavaScript(script) }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handleBridgeMessage(message.body)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        state = LoadStateReducer.onPageStarted(state, url: webView.url)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        state = LoadStateReducer.onPageFinished(state, url: webView.url)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        state = LoadStateReducer.onNavigationFailed(state, error: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        state = LoadStateReducer.onNavigationFailed(state, error: error)
    }

    /// 配信元と同じホストの http(s) だけ WebView 内で読み込む。
    /// それ以外の http(s) はアプリ内ブラウザ、`tel:` などは端末のアプリに渡す。
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }

        if url == appRequestedURL || url == LoadStateReducer.blankURL {
            decisionHandler(.allow)
            return
        }

        switch LinkPolicy.resolve(scheme: url.scheme, host: url.host, targetHost: Self.targetHost) {
        case .inWebView:
            decisionHandler(.allow)

        case .safariViewController:
            decisionHandler(.cancel)
            openInAppBrowser(url)

        case .externalApp:
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
        }
    }

    /// HTTP エラーは `didFail` に来ないため、レスポンスを見てエラー画面に切り替える。
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        guard navigationResponse.isForMainFrame,
              let response = navigationResponse.response as? HTTPURLResponse,
              response.statusCode >= 400
        else {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
        state = LoadStateReducer.onHTTPError(
            state,
            isForMainFrame: navigationResponse.isForMainFrame,
            statusCode: response.statusCode
        )
    }

    private func openInAppBrowser(_ url: URL) {
        guard LinkPolicy.isBrowsableURL(scheme: url.scheme) else { return }
        let safari = SFSafariViewController(url: url)
        safari.preferredBarTintColor = WebPalette.surface
        safari.preferredControlTintColor = WebPalette.primary
        present(safari, animated: true)
    }
}

extension WebViewController: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // window.open() は decidePolicyFor を通らないため、ここで受け取ってアプリ内ブラウザに流す
        if let url = navigationAction.request.url {
            openInAppBrowser(url)
        }
        return nil
    }
}

/// メッセージハンドラの保持による循環参照を避けるための弱参照ラッパー。
private final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(_ delegate: WKScriptMessageHandler) { self.delegate = delegate }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
