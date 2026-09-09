import SwiftUI

/// ネイティブ版のヘッダー。WebView 版の `web/app/components/app-header.tsx`（MUI AppBar）に
/// 見た目を合わせている。左からロックアイコン・タイトル/サブタイトル・実装バッジ・配色トグル。
struct AuthHeader: View {
    @Binding var appTheme: AppTheme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(WebPalette.primaryColor)
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: "lock.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text("SMS 認証サンプル")
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(1)
                Text("電話番号 → 6 桁コード → 結果確認")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            // WebView 版の「WebView / ブラウザ」チップに対応する実装バッジ
            HStack(spacing: 4) {
                Image(systemName: "iphone").font(.caption2)
                Text("ネイティブ").font(.caption2.weight(.semibold))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(WebPalette.successColor, in: .capsule)

            Button {
                // WebView 版のトグルと同じく、いま適用されている配色の逆を指定する
                appTheme = colorScheme == .dark ? .light : .dark
                ThemePreference.save(appTheme)
            } label: {
                Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("カラーテーマを切り替える")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
    }
}
