import SwiftUI

/// ステップ 2: ダミー SMS のコードを入力して検証する。
struct CodeEntryView: View {
    let model: AuthFlowModel

    @State private var input = ""
    @State private var failed = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 16) {
            MockSmsBanner(code: model.sentCode) {
                input = ""
                failed = false
                model.resend()
            }

            FlowCard {
                Text("認証コードを入力").font(.headline)
                Text("\(AuthLogic.format(model.phoneNumber)) に送信した 6 桁のコードを入力してください。")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                TextField("000000", text: $input)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                    .font(.system(.title2, design: .monospaced))
                    .tracking(8)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                    .onChange(of: input) { _, value in
                        let digits = String(value.filter(\.isNumber).prefix(AuthLogic.codeLength))
                        if digits != input { input = digits }
                        failed = false
                    }

                if failed {
                    Text("コードが一致しません。もう一度入力してください")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button {
                    focused = false
                    if !model.verify(input) {
                        failed = true
                    }
                } label: {
                    Text("認証する").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(input.count != AuthLogic.codeLength)

                Button("電話番号を入力し直す") {
                    model.backToPhone()
                }
                .font(.footnote)
                .frame(maxWidth: .infinity)
            }
        }
    }
}
