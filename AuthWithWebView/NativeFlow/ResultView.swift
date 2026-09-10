import SwiftUI

/// ステップ 3: 結果確認。
struct ResultView: View {
    @Environment(\.colorScheme) private var scheme
    let model: AuthFlowModel

    var body: some View {
        FlowCard {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Palette.success(scheme == .dark))
                Text("認証が完了しました")
                    .font(.system(size: 15.6, weight: .bold))
                    .tracking(-0.156)
                Text("電話番号の確認が取れました。")
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.textSecondary(scheme == .dark))
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
                .font(.system(size: 14))
                .foregroundStyle(Palette.textSecondary(scheme == .dark))
                .fixedSize(horizontal: false, vertical: true)

            FlowButton(title: "最初からやり直す", filled: false) {
                model.restart()
            }
        }
    }
}
