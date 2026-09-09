import SwiftUI

/// ステップ 1: 電話番号を入力してダミーコードを生成する。
struct PhoneEntryView: View {
    let model: AuthFlowModel

    @State private var input = ""
    @FocusState private var focused: Bool

    var body: some View {
        FlowCard {
            Text("電話番号を入力").font(.headline)
            Text("この番号に認証コードを送信します（このサンプルでは送信せず画面に表示します）。")
                .font(.callout)
                .foregroundStyle(.secondary)

            TextField("090-1234-5678", text: $input)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .textFieldStyle(.roundedBorder)
                .focused($focused)

            Button {
                focused = false
                model.sendCode(to: input)
            } label: {
                Text("認証コードを送信").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!AuthLogic.isValid(input))
        }
        .onAppear { input = model.phoneNumber } // 「入力し直す」で戻ってきたときに復元
    }
}
