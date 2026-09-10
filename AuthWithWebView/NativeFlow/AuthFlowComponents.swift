import SwiftUI

/// MUI の `Card`(outlined) + `CardContent` に相当。実測: 角丸 14 / 枠 1px divider /
/// 内側パディング 16（下だけ 24）/ 子要素の間隔 20。
struct FlowCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            content
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface(scheme == .dark), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.divider(scheme == .dark), lineWidth: 1))
    }
}

/// MUI `Stepper`(alternativeLabel) に相当。実測: 円 24 / 数字 12pt 白 / ラベル 14pt
/// （現在まで太字 500・以降 400）/ コネクタ 1px #BDBDBD / 下マージン 24。
struct StepBar: View {
    @Environment(\.colorScheme) private var scheme
    let step: AuthStep

    private let labels = ["電話番号", "認証コード", "結果確認"]
    private var active: Int {
        switch step {
        case .phone: 0
        case .code: 1
        case .result: 2
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(0 ..< 3, id: \.self) { i in
                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(i <= active ? Palette.primary(scheme == .dark) : Palette.stepUpcoming(scheme == .dark))
                            .frame(width: 24, height: 24)
                        if i < active {
                            Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                        } else {
                            Text("\(i + 1)").font(.system(size: 12, weight: .medium)).foregroundStyle(.white)
                        }
                    }
                    Text(labels[i])
                        .font(.system(size: 14, weight: i <= active ? .medium : .regular))
                        .foregroundStyle(i <= active ? Color.primary : Palette.textSecondary(scheme == .dark))
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .overlay(alignment: .topLeading) {
            GeometryReader { geo in
                let cw = geo.size.width / 3
                ForEach(0 ..< 2, id: \.self) { i in
                    Rectangle()
                        .fill(Palette.connector)
                        .frame(width: max(cw - 24, 0), height: 1)
                        .position(x: cw * CGFloat(i + 1), y: 12)
                }
            }
        }
        .padding(.bottom, 24)
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

/// 各ステップのカード見出し（MUI variant="h2" 相当: 15.6pt / bold / letter-spacing -0.156）と
/// 説明文（body2 / 14pt / secondary）。間隔は MUI の Stack spacing={0.5} = 4。
struct CardHeadline: View {
    @Environment(\.colorScheme) private var scheme
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15.6, weight: .bold))
                .tracking(-0.156)
                .foregroundStyle(Color.primary)
            Text(description)
                .font(.system(size: 14))
                .foregroundStyle(Palette.textSecondary(scheme == .dark))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// MUI `Button` size="large"（テーマで角丸 999 / textTransform none / weight 600 / 影なし）。
struct FlowButton: View {
    @Environment(\.colorScheme) private var scheme
    let title: String
    var filled: Bool = true
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
        }
        .buttonStyle(.plain)
        .foregroundStyle(foreground)
        .background(background, in: .capsule)
        .overlay(filled ? nil : Capsule().stroke(Palette.primary(scheme == .dark).opacity(enabled ? 0.5 : 0.12), lineWidth: 1))
        .disabled(!enabled)
    }

    private var foreground: Color {
        if !filled { return enabled ? Palette.primary(scheme == .dark) : Color.primary.opacity(0.26) }
        return enabled ? .white : Color.primary.opacity(0.26)
    }

    private var background: Color {
        guard filled else { return .clear }
        return enabled ? Palette.primary(scheme == .dark) : Color.primary.opacity(0.12)
    }
}
