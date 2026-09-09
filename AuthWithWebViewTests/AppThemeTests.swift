import Foundation
import Testing

@testable import AuthWithWebView

struct AppThemeTests {
    @Test func from_parsesKnownValues() {
        #expect(AppTheme.from("light") == .light)
        #expect(AppTheme.from("dark") == .dark)
        #expect(AppTheme.from("system") == .system)
        // 大文字や前後の差異も吸収する
        #expect(AppTheme.from("DARK") == .dark)
    }

    @Test func from_fallsBackToSystemForUnknownOrNil() {
        #expect(AppTheme.from(nil) == .system)
        #expect(AppTheme.from("") == .system)
        #expect(AppTheme.from("sepia") == .system)
    }

    @Test func themePreference_roundTripsThroughUserDefaults() {
        let defaults = UserDefaults.standard
        defer { defaults.removeObject(forKey: "appTheme") }

        ThemePreference.save(.dark)
        #expect(ThemePreference.load() == .dark)

        ThemePreference.save(.light)
        #expect(ThemePreference.load() == .light)
    }
}
