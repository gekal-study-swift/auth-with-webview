import SwiftUI

/// ステップ 1: 電話番号を入力してダミーコードを生成する。
struct PhoneEntryView: View {
    @Environment(\.colorScheme) private var scheme
    let model: AuthFlowModel

    @State private var input = ""
    @FocusState private var focused: Bool

    private var dark: Bool { scheme == .dark }

    var body: some View {
        FlowCard {
            CardHeadline(
                title: "電話番号を入力",
                description: "この番号に認証コードを送信します（このサンプルでは送信せず画面に表示します）。"
            )

            VStack(alignment: .leading, spacing: 3) {
                TextField("", text: $input, prompt: Text("090-1234-5678").foregroundStyle(Palette.textSecondary(dark)))
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.primary)
                    .focused($focused)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 14)
                    .contentShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture { focused = true }
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                focused ? Palette.primary(dark) : Palette.outline(dark),
                                lineWidth: focused ? 2 : 1
                            )
                    )
                    .overlay(alignment: .topLeading) {
                        Text("携帯電話番号")
                            .font(.system(size: 12))
                            .foregroundStyle(focused ? Palette.primary(dark) : Palette.textSecondary(dark))
                            .padding(.horizontal, 4)
                            .background(Palette.surface(dark))
                            .offset(x: 10, y: -6)
                    }
                Text(" ").font(.system(size: 12)).padding(.leading, 14)
            }

            FlowButton(title: "認証コードを送信", enabled: AuthLogic.isValid(input)) {
                focused = false
                model.sendCode(to: input)
            }
        }
        .onAppear { input = model.phoneNumber }
    }
}
