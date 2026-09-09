import SwiftUI
import UIKit

/// アプリの配色。既定は ``system``（端末のダークモード設定に追従）。
enum AppTheme: String {
    case system
    case light
    case dark

    /// WebView から渡される文字列を変換する。未知の値は ``system`` にフォールバックする。
    static func from(_ value: String?) -> AppTheme {
        guard let value else { return .system }
        return AppTheme(rawValue: value.lowercased()) ?? .system
    }

    /// ``system`` は nil を返し、端末の設定に委ねる。
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

/// 配色を次回起動まで保持する。
///
/// 配色を選ぶのは WebView 側（MUI が localStorage に保存する）で、そちらが真実の源。
/// ここに保存するのは、起動直後に WebView が読み込まれるまでの間、
/// セーフエリアの余白と Web コンテンツの色が食い違ってちらつくのを防ぐためのミラー。
enum ThemePreference {
    private static let key = "appTheme"

    static func load() -> AppTheme {
        AppTheme.from(UserDefaults.standard.string(forKey: key))
    }

    static func save(_ theme: AppTheme) {
        UserDefaults.standard.set(theme.rawValue, forKey: key)
    }
}

/// WebView に表示する Web コンテンツ (web/app/theme.ts) と同じ配色。
/// セーフエリアの余白と WebView の背景を継ぎ目なく見せるために揃えている。
enum WebPalette {
    /// web/app/theme.ts の background.default
    static let background = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hex: 0x0E14_14) : UIColor(hex: 0xF2F6_F5)
    }

    /// web/app/theme.ts の background.paper
    static let surface = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hex: 0x161D_1D) : UIColor(hex: 0xFFFF_FF)
    }

    /// web/app/theme.ts の primary.main
    static let primary = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hex: 0x5FD4_C0) : UIColor(hex: 0x0069_5F)
    }

    // ネイティブ版のフロー画面（NativeFlow/）でも同じ色を使う。
    static var backgroundColor: Color { Color(background) }
    static var surfaceColor: Color { Color(surface) }
    static var primaryColor: Color { Color(primary) }
}

private extension UIColor {
    /// web/app/theme.ts の値をそのまま書き写せるようにする。
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
