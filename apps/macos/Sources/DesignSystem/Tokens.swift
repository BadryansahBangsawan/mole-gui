import SwiftUI

/// Visual tokens from the Pencil kit. Mocks use Inter + IBM Plex Mono;
/// the native app maps those to SF Pro + SF Mono.
enum MoleTokens {
    static let windowWidth: CGFloat = 1220
    static let windowHeight: CGFloat = 780
    static let minWindowWidth: CGFloat = 1080
    static let minWindowHeight: CGFloat = 700
    static let sidebarWidth: CGFloat = 232
    static let buttonHeight: CGFloat = 38
    static let toolbarHeight: CGFloat = 52
    static let trafficRowHeight: CGFloat = 52
    static let navItemHeight: CGFloat = 32
    static let iconButton: CGFloat = 32
    static let searchHeight: CGFloat = 32
    static let pillHeight: CGFloat = 22
    static let candidateRowHeight: CGFloat = 48
    static let activityRowHeight: CGFloat = 48
    static let capsuleRadius: CGFloat = 999
    static let panelRadius: CGFloat = 14
    static let fieldRadius: CGFloat = 12
    static let navRadius: CGFloat = 8
    static let checkboxRadius: CGFloat = 4
    static let checkboxSize: CGFloat = 16
    static let bodyPadding: CGFloat = 28
    static let bodyGap: CGFloat = 24
    static let narrowPadding: CGFloat = 20

    struct Palette {
        let canvas: Color
        let raised: Color
        let hover: Color
        let selected: Color
        let border: Color
        let strongBorder: Color
        let textPrimary: Color
        let textSecondary: Color
        let brand: Color
        let onBrand: Color
        let brandHover: Color
        let success: Color
        let review: Color
        let danger: Color
        let reviewFill: Color
        let dangerFill: Color
        let successFill: Color
        let onDanger: Color
    }

    static let light = Palette(
        canvas: Color(hex: 0xFFFFFF),
        raised: Color(hex: 0xF5F7F4),
        hover: Color(hex: 0xEDF2EC),
        selected: Color(hex: 0xE7F2E9),
        border: Color(hex: 0xDCE5DD),
        strongBorder: Color(hex: 0xB8C8BA),
        textPrimary: Color(hex: 0x162019),
        textSecondary: Color(hex: 0x53635A),
        brand: Color(hex: 0x315C41),
        onBrand: Color(hex: 0xFFFFFF),
        brandHover: Color(hex: 0x254A34),
        success: Color(hex: 0x1D7047),
        review: Color(hex: 0x8A5A0A),
        danger: Color(hex: 0xB42318),
        reviewFill: Color(hex: 0xF8EED9),
        dangerFill: Color(hex: 0xFCEBE9),
        successFill: Color(hex: 0xE6F4EC),
        onDanger: Color(hex: 0xFFFFFF)
    )

    static let dark = Palette(
        canvas: Color(hex: 0x0B100D),
        raised: Color(hex: 0x17211A),
        hover: Color(hex: 0x1D2B21),
        selected: Color(hex: 0x203B29),
        border: Color(hex: 0x2E4032),
        strongBorder: Color(hex: 0x506553),
        textPrimary: Color(hex: 0xF2F7F1),
        textSecondary: Color(hex: 0xAABCAF),
        brand: Color(hex: 0xB8E1C0),
        onBrand: Color(hex: 0x0B100D),
        brandHover: Color(hex: 0xD4F0DA),
        success: Color(hex: 0x86D7A2),
        review: Color(hex: 0xF0CA83),
        danger: Color(hex: 0xFFB4A8),
        reviewFill: Color(hex: 0x3A2E16),
        dangerFill: Color(hex: 0x3A1C18),
        successFill: Color(hex: 0x163226),
        onDanger: Color(hex: 0x0B100D)
    )

    static func palette(_ scheme: ColorScheme) -> Palette {
        scheme == .dark ? dark : light
    }

    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

private struct MolePaletteKey: EnvironmentKey {
    static let defaultValue = MoleTokens.light
}

extension EnvironmentValues {
    var molePalette: MoleTokens.Palette {
        get { self[MolePaletteKey.self] }
        set { self[MolePaletteKey.self] = newValue }
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

enum MoleSymbol {
    case layoutDashboard
    case sparkles
    case appWindow
    case hardDrive
    case folderGit
    case wrench
    case history
    case settings
    case activity
    case ellipsis
    case heartPulse
    case chevronRight
    case refresh
    case check
    case search
    case warning
    case close
    case minus
    case square

    var systemName: String {
        switch self {
        case .layoutDashboard: return "square.grid.2x2"
        case .sparkles: return "sparkles"
        case .appWindow: return "macwindow"
        case .hardDrive: return "internaldrive"
        case .folderGit: return "folder"
        case .wrench: return "wrench"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape"
        case .activity: return "waveform.path.ecg"
        case .ellipsis: return "ellipsis"
        case .heartPulse: return "heart.fill"
        case .chevronRight: return "chevron.right"
        case .refresh: return "arrow.clockwise"
        case .check: return "checkmark"
        case .search: return "magnifyingglass"
        case .warning: return "exclamationmark.triangle.fill"
        case .close: return "xmark"
        case .minus: return "minus"
        case .square: return "square"
        }
    }
}

extension Image {
    init(mole symbol: MoleSymbol) {
        self.init(systemName: symbol.systemName)
    }
}
