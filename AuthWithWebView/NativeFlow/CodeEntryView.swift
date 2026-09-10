import SwiftUI

/// ステップ 2: ダミー SMS のコードを入力して検証する。
/// WebView 版の `code-step.tsx`（MUI）に寸法・色・エラー表示を合わせている。
struct CodeEntryView: View {
    @Environment(\.colorScheme) private var scheme
    let model: AuthFlowModel

    @State private var input = ""
    @State private var failed = false
    @FocusState private var focused: Bool

    private var dark: Bool { scheme == .dark }

    var body: some View {
        VStack(spacing: 16) { // MUI outer Stack spacing={2}
            MockSmsBanner(code: model.sentCode) {
                input = ""
                failed = false
                model.resend()
            }

            FlowCard {
                CardHeadline(
                    title: "認証コードを入力",
                    description: "\(AuthLogic.format(model.phoneNumber)) に送信した 6 桁のコードを入力してください。"
                )

                // TextField + helperText（MUI では helperText の高さを常に確保）
                VStack(alignment: .leading, spacing: 3) {
                    codeField
                    Text(failed ? "コードが一致しません。もう一度入力してください" : " ")
                        .font(.system(size: 12))
                        .foregroundStyle(failed ? Palette.errorMain(dark) : Palette.textSecondary(dark))
                        .padding(.leading, 14)
                }

                if failed {
                    FlowErrorAlert(
                        text: "入力されたコードは正しくありません。ダミー SMS に表示された 6 桁を入力してください。"
                    )
                }

                FlowButton(title: "認証する", enabled: input.count == AuthLogic.codeLength) {
                    focused = false
                    if !model.verify(input) { failed = true }
                }

                Button("電話番号を入力し直す") { model.backToPhone() }
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.primary(dark))
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MUI OutlinedInput 相当: 角丸 14 / 枠 1px（フォーカス・エラー時 2px）/ 入力 24pt mono・
    // 中央寄せ・tracking 12 / 上に載るフローティングラベル。
    private var codeField: some View {
        let borderColor = failed
            ? Palette.errorMain(dark)
            : (focused ? Palette.primary(dark) : Palette.outline(dark))
        let labelColor = failed
            ? Palette.errorMain(dark)
            : (focused ? Palette.primary(dark) : Palette.textSecondary(dark))

        return TextField("", text: $input)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .multilineTextAlignment(.center)
            .font(.system(size: 24, design: .monospaced))
            .tracking(12)
            .foregroundStyle(Color.primary)
            .focused($focused)
            .onChange(of: input) { _, value in
                let digits = String(value.filter(\.isNumber).prefix(AuthLogic.codeLength))
                if digits != input { input = digits }
                failed = false
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 14)
            .contentShape(RoundedRectangle(cornerRadius: 14))
            .onTapGesture { focused = true }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: (focused || failed) ? 2 : 1)
            )
            .overlay(alignment: .topLeading) {
                Text("6 桁の認証コード")
                    .font(.system(size: 12))
                    .foregroundStyle(labelColor)
                    .padding(.horizontal, 4)
                    .background(Palette.surface(dark))
                    .offset(x: 10, y: -6)
            }
    }
}
