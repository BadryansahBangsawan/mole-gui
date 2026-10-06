import SwiftUI

/// Visual tokens from `docs/GUI_DESIGN_PLAN.md` / Pencil.
/// Pencil mocks use Inter + IBM Plex Mono; the native app maps to SF Pro + SF Mono.
enum MoleTokens {
    static let windowWidth: CGFloat = 1220
    static let windowHeight: CGFloat = 780
    static let minWindowWidth: CGFloat = 1080
    static let minWindowHeight: CGFloat = 700
    static let sidebarWidth: CGFloat = 232
    static let buttonHeight: CGFloat = 38
    static let capsuleRadius: CGFloat = 999

    enum Light {
        static let canvas = Color(hex: 0xFFFFFF)
        static let brand = Color(hex: 0x315C41)
        static let brandSoft = Color(hex: 0xE6F3EA)
        static let text = Color(hex: 0x122017)
        static let muted = Color(hex: 0x5C6B62)
        static let danger = Color(hex: 0xB42318)
        static let warning = Color(hex: 0xB54708)
    }

    enum Dark {
        static let canvas = Color(hex: 0x0B100D)
        static let brand = Color(hex: 0xB8E1C0)
        static let brandSoft = Color(hex: 0x1A2A20)
        static let text = Color(hex: 0xE8F0EA)
        static let muted = Color(hex: 0x93A399)
        static let danger = Color(hex: 0xFF6B6B)
        static let warning = Color(hex: 0xF6C177)
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
