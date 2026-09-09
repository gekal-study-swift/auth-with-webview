import SwiftUI

/// ステップ 3: 結果確認。
struct ResultView: View {
    let model: AuthFlowModel

    var body: some View {
        FlowCard {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.green)
                Text("認証が完了しました").font(.headline)
                Text("電話番号の確認が取れました。")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)

            Divider()

            LabeledRow("電話番号", AuthLogic.mask(model.phoneNumber))
            LabeledRow("入力値", AuthLogic.format(model.phoneNumber))
            LabeledRow("認証時刻", (model.verifiedAt ?? .now).formatted(date: .numeric, time: .standard))

            Divider()

            LabeledRow("実行環境", "ネイティブ（SwiftUI）")
            Text("Web 版と違い、リロードで状態が消える経路がありません。")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button("最初からやり直す") {
                model.restart()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
    }
}
