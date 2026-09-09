import SwiftUI

struct ContentView: View {
    // 前回の選択を初期値にして、WebView が読み込まれるまでのちらつきを防ぐ。
    // 選択の真実の源は WebView 側（MUI が localStorage に保存）で、
    // 読み込み後に setAppTheme で上書きされる。
    @State private var appTheme = ThemePreference.load()

    var body: some View {
        // 同じ認証フローを WebView 版とネイティブ版で並べ、動作を見比べられるようにする。
        TabView {
            Tab("WebView", systemImage: "globe") {
                WebViewContainer(
                    onAppThemeChanged: { theme in
                        appTheme = theme
                        ThemePreference.save(theme)
                    }
                )
                .ignoresSafeArea()
            }

            Tab("ネイティブ", systemImage: "iphone") {
                AuthFlowView(appTheme: $appTheme)
            }
        }
        .tint(WebPalette.primaryColor)
        // ステータスバーとホームインジケータ周辺の配色もアプリの選択に追従させる。
        // 適用は SwiftUI の preferredColorScheme に一本化する。
        .preferredColorScheme(appTheme.colorScheme)
    }
}
