import Foundation

/// リンクをどこで開くか。
enum Navigation: Equatable {
    /// WebView 内でそのまま読み込む。
    case inWebView

    /// SFSafariViewController（アプリ内ブラウザ）でアプリの上に重ねて開く。
    /// URL バーが出るので外部サイトだと分かり、閉じれば元の画面に戻れる。
    case safariViewController

    /// 端末のアプリ（電話・メールなど）に渡す。
    case externalApp
}

/// リンクの遷移先を決めるロジック。
///
/// UIKit に依存しないため、シミュレータや実機なしのユニットテストで検証できる。
/// 認証フローは配信元ホスト内で完結するため、それ以外へ出るリンク（利用規約など）は
/// WebView 内で開かず、URL の見えるアプリ内ブラウザか端末のアプリに振り分ける。
enum LinkPolicy {
    private static let webSchemes: Set<String> = ["http", "https"]

    /// - Parameters:
    ///   - scheme: リンクのスキーム
    ///   - host: リンクのホスト
    ///   - targetHost: 配信元のホスト
    ///
    /// 配信元と同じホストの http(s) だけ WebView 内で読み込む。
    /// 外部サイトを WebView 内で開くと、URL が見えないまま別サイトを表示することになり、
    /// 戻る手段もない。SFSafariViewController なら URL バーで接続先が分かり、閉じれば戻れる。
    static func resolve(scheme: String?, host: String?, targetHost: String?) -> Navigation {
        guard let scheme = scheme?.lowercased(), webSchemes.contains(scheme) else {
            return .externalApp
        }
        guard let targetHost, host?.lowercased() == targetHost.lowercased() else {
            return .safariViewController
        }
        return .inWebView
    }

    /// WebView から渡された URL をブラウザ表示に使ってよいか。
    /// `javascript:` や `file:` などを開かせないよう、http(s) だけを許可する。
    static func isBrowsableURL(scheme: String?) -> Bool {
        guard let scheme = scheme?.lowercased() else { return false }
        return webSchemes.contains(scheme)
    }
}
