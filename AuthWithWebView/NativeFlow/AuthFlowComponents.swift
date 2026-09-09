import SwiftUI

/// カード風のまとまり。Web 版の MUI `Card` に相当する見た目。
struct FlowCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WebPalette.surfaceColor, in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.separator))
    }
}

/// ステップ表示。Web 版の MUI `Stepper` に相当。
struct StepBar: View {
    let step: AuthStep

    private let labels = ["電話番号", "認証コード", "結果確認"]
    private var activeIndex: Int {
        switch step {
        case .phone: 0
        case .code: 1
        case .result: 2
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(labels.indices, id: \.self) { index in
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(index <= activeIndex ? WebPalette.primaryColor : Color(.systemGray4))
                            .frame(width: 26, height: 26)
                        if index < activeIndex {
                            Image(systemName: "checkmark").font(.caption2.bold()).foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)").font(.caption2.bold()).foregroundStyle(.white)
                        }
                    }
                    Text(labels[index])
                        .font(.caption2)
                        .foregroundStyle(index == activeIndex ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)

                if index < labels.count - 1 {
                    Rectangle().fill(Color(.systemGray4))
                        .frame(height: 1)
                        .offset(y: 13)
                }
            }
        }
        .padding(.vertical, 12)
    }
}

/// 「ラベル ─ 値」の 1 行。結果画面で使う。
struct LabeledRow: View {
    let label: String
    let value: String

    init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).font(.callout).foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value).font(.callout).fontWeight(.semibold).multilineTextAlignment(.trailing)
        }
    }
}
