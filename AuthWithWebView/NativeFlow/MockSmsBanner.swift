import SwiftUI

/// ダミーの SMS を模した通知。Web 版の `mock-sms-banner.tsx` に相当。
/// 実際の SMS は送信されないため、生成した 6 桁コードをここに表示する。
struct MockSmsBanner: View {
    let code: String
    let onResend: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("ダミー SMS（実際には送信されません）", systemImage: "message.fill")
                    .font(.subheadline.bold())
                Spacer()
                Button("再送", action: onResend).font(.footnote)
            }
            Text("認証コードはこちらです。次の画面で入力してください。")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(code)
                .font(.system(.largeTitle, design: .monospaced).bold())
                .tracking(8)
                .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.08), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.4)))
    }
}
