import SwiftUI

/// ネイティブ版で使う色。`web/app/theme.ts` と MUI の既定値を実測して sRGB で固定してある。
/// レンダラ差を避けるため `Color(.sRGB, ...)` で指定する。
enum Palette {
    static func hex(_ v: UInt32) -> Color {
        Color(
            .sRGB,
            red: Double((v >> 16) & 0xFF) / 255,
            green: Double((v >> 8) & 0xFF) / 255,
            blue: Double(v & 0xFF) / 255
        )
    }

    // web/app/theme.ts
    static func primary(_ dark: Bool) -> Color { dark ? hex(0x5FD4_C0) : hex(0x0069_5F) }
    static func success(_ dark: Bool) -> Color { dark ? hex(0x7BD8_8F) : hex(0x2E7D_32) }
    static func background(_ dark: Bool) -> Color { dark ? hex(0x0E14_14) : hex(0xF2F6_F5) }
    static func surface(_ dark: Bool) -> Color { dark ? hex(0x161D_1D) : hex(0xFFFF_FF) }

    /// MUI の divider / outlined border 系（light 基準。dark はおよそ反転）。
    static func divider(_ dark: Bool) -> Color { (dark ? Color.white : Color.black).opacity(0.12) }
    static func outline(_ dark: Bool) -> Color { (dark ? Color.white : Color.black).opacity(0.23) }
    static func textSecondary(_ dark: Bool) -> Color { (dark ? Color.white : Color.black).opacity(dark ? 0.7 : 0.6) }
    static func stepUpcoming(_ dark: Bool) -> Color { (dark ? Color.white : Color.black).opacity(0.38) }
    static let connector = hex(0xBDBD_BD)

    // MUI Alert severity=error / info（outlined, light）。dark はおよそ明るめ。
    static func errorMain(_ dark: Bool) -> Color { dark ? hex(0xF4_4336) : hex(0xC628_28) }
    static func errorBorder(_ dark: Bool) -> Color { dark ? hex(0xE57_373) : hex(0xD153_53) }
    static func errorText(_ dark: Bool) -> Color { dark ? hex(0xF4_C7C7) : hex(0x5321_21) }
    static func infoIcon(_ dark: Bool) -> Color { dark ? hex(0x29B6_F6) : hex(0x0288_D1) }
    static func infoBorder(_ dark: Bool) -> Color { dark ? hex(0x4FC3_F7) : hex(0x03A9_F4) }
    static func infoText(_ dark: Bool) -> Color { dark ? hex(0xB8E7_FB) : hex(0x0143_61) }
}
