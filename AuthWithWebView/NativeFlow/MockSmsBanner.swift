import SwiftUI

/// ダミー SMS。WebView 版の `mock-sms-banner.tsx`（MUI `Alert` severity="info" variant="outlined"、
/// icon は SmsIcon）に合わせる。実測:
/// - 枠 1px #03A9F4 / 文字 #014361 / 背景なし / 角丸 14 / パディング 縦 6・横 16
/// - アイコン 22–24pt #0288D1、右マージン 12、上寄せ
/// - タイトル 16pt / weight 500、本文 14pt、コード 28pt / bold / mono / tracking 11.2
struct MockSmsBanner: View {
    @Environment(\.colorScheme) private var scheme
    let code: String
    let onResend: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "message.fill")
                .font(.system(size: 21))
                .foregroundStyle(Palette.infoIcon(scheme == .dark))
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text("ダミー SMS（実際には送信されません）")
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 8)
                    Button("再送", action: onResend)
                        .font(.system(size: 13))
                        .buttonStyle(.plain)
                }
                Text("認証コードはこちらです。次の画面で入力してください。")
                    .font(.system(size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                Text(code)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .tracking(11.2)
                    .padding(.top, 2)
            }
        }
        .foregroundStyle(Palette.infoText(scheme == .dark))
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.infoBorder(scheme == .dark), lineWidth: 1))
    }
}
