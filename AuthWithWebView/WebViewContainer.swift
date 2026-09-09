import SwiftUI

/// SwiftUI から `WebViewController` を使うためのラッパー。
struct WebViewContainer: UIViewControllerRepresentable {
    let onAppThemeChanged: (AppTheme) -> Void

    func makeUIViewController(context: Context) -> WebViewController {
        let controller = WebViewController()
        controller.onAppThemeChanged = onAppThemeChanged
        return controller
    }

    // makeUIViewController は一度しか実行されないため、最新のクロージャを渡し直す。
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
        uiViewController.onAppThemeChanged = onAppThemeChanged
    }
}
