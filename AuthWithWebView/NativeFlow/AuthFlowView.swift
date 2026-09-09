import SwiftUI

/// ネイティブ版の認証フロー。WebView 版（`web/`）と同じ 3 ステップを SwiftUI で実装したもの。
/// ヘッダー・ステッパー・カード・配色を WebView 版に揃えている。
///
/// 状態は ``AuthFlowModel``（メモリのみ）が持つ。Web 版の Jotai atom と同じ方針で、
/// 電話番号・コードは永続化しない。必要な状態が無ければ「セッションが切れました」
/// アラートを出してやり直させる（Web 版の `FlowGuard` と対）。
struct AuthFlowView: View {
    @Binding var appTheme: AppTheme
    @State private var model = AuthFlowModel()

    var body: some View {
        VStack(spacing: 0) {
            AuthHeader(appTheme: $appTheme)

            ScrollView {
                VStack(spacing: 0) {
                    StepBar(step: model.step)

                    switch model.step {
                    case .phone:
                        PhoneEntryView(model: model)
                    case .code:
                        CodeEntryView(model: model)
                    case .result:
                        ResultView(model: model)
                    }

                    Text("SwiftUI ネイティブ実装 / SMS 認証コードはダミーです")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 24)

                    if model.step != .phone {
                        // 比較用: WebView のリロードで状態が消えるのと同じ状況を起こす
                        Button("状態を破棄（WebView のリロード相当）") {
                            model.discardState()
                        }
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WebPalette.backgroundColor)
        .alert("セッションが切れました", isPresented: $model.showExpiredAlert) {
            Button("最初からやり直す") { model.restart() }
        } message: {
            Text("安全のため、入力内容は端末に保存していません。認証を最初からやり直してください。")
        }
    }
}
