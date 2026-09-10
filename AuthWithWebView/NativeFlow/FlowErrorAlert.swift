import SwiftUI

/// MUI `Alert` severity="error" variant="outlined" に相当。実測:
/// - 枠 1px #D15353 / 文字 #532121 / 背景なし / 角丸 14 / パディング 縦 6・横 16
/// - アイコン 22pt #C62828、右マージン 12、上寄せ、メッセージは上下 8 パディング
/// - 本文 14pt / line-height 20
struct FlowErrorAlert: View {
    @Environment(\.colorScheme) private var scheme
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 22))
                .foregroundStyle(Palette.errorMain(scheme == .dark))
                .padding(.top, 1)
            Text(text)
                .font(.system(size: 14))
                .lineSpacing(20.02 - 14)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(Palette.errorText(scheme == .dark))
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.errorBorder(scheme == .dark), lineWidth: 1))
    }
}
