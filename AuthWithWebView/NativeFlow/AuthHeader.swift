import SwiftUI

/// ネイティブ版のヘッダー。WebView 版の `web/app/components/app-header.tsx`（MUI AppBar）と
/// 寸法・色・フォントを揃えている。実測値（devicePixelRatio 3 / iPhone のポイント）に合わせる:
///
/// - Toolbar: min-height 56 / 左右パディング 16 / 要素間 12
/// - ロック: 38×38 の円（CSS の border-radius 28px は 38px 上では円になる）、`#00695F`
/// - タイトル: 18.4pt / bold / letter-spacing -0.18、サブタイトル: 12pt / secondary
/// - チップ: 高さ 24 / ラベル 13pt semibold、下線 1px rgba(0,0,0,0.12)
struct AuthHeader: View {
    @Binding var appTheme: AppTheme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(primary)
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                )

            // MUI の <Stack sx={{ minWidth: 0, flexGrow: 1 }}> と同じく、残り幅をすべて取って
            // はみ出す行だけ省略する
            VStack(alignment: .leading, spacing: 0) {
                Text("SMS 認証サンプル")
                    .font(.system(size: 18.4, weight: .bold))
                    .tracking(-0.18)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                Text("電話番号 → 6 桁コード → 結果確認")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.primary.opacity(0.6))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // SwiftUI Text の行ボックスが WebKit より少し下に出るぶんを詰める
            .offset(y: -4)

            // WebView 版の「WebView」チップに対応する実装バッジ。7 文字で幅も揃える
            HStack(spacing: 4) {
                Image(systemName: "iphone").font(.system(size: 15))
                Text("SwiftUI").font(.system(size: 13, weight: .semibold))
            }
            .fixedSize()
            .padding(.horizontal, 9)
            .frame(height: 24)
            .foregroundStyle(.white)
            .background(success, in: .capsule)

            Button {
                // WebView 版のトグルと同じく、いま適用されている配色の逆を指定する
                appTheme = colorScheme == .dark ? .light : .dark
                ThemePreference.save(appTheme)
            } label: {
                Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 1 : 0.87))
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("カラーテーマを切り替える")
        }
        .frame(minHeight: 56)
        .padding(.horizontal, 16)
        .background {
            Rectangle().fill(background).opacity(0.8).background(.regularMaterial)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.primary.opacity(0.12)).frame(height: 1)
        }
    }

    // 色は web/app/theme.ts と厳密に合わせる（sRGB 指定でずれを防ぐ）
    private var primary: Color {
        colorScheme == .dark
            ? Color(.sRGB, red: 95 / 255, green: 212 / 255, blue: 192 / 255)
            : Color(.sRGB, red: 0, green: 105 / 255, blue: 95 / 255)
    }

    private var success: Color {
        colorScheme == .dark
            ? Color(.sRGB, red: 123 / 255, green: 216 / 255, blue: 143 / 255)
            : Color(.sRGB, red: 46 / 255, green: 125 / 255, blue: 50 / 255)
    }

    private var background: Color {
        colorScheme == .dark
            ? Color(.sRGB, red: 14 / 255, green: 20 / 255, blue: 20 / 255)
            : Color(.sRGB, red: 242 / 255, green: 246 / 255, blue: 245 / 255)
    }
}
