import SwiftUI

struct TrafficLights: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(Color(hex: 0xFF5F57)).frame(width: 12, height: 12)
            Circle().fill(Color(hex: 0xFEBC2E)).frame(width: 12, height: 12)
            Circle().fill(Color(hex: 0x28C840)).frame(width: 12, height: 12)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

enum MoleButtonKind {
    case primary
    case secondary
    case quiet
    case danger
}

struct MoleButton: View {
    @Environment(\.molePalette) private var palette

    let title: String
    var icon: MoleSymbol?
    var kind: MoleButtonKind = .primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(mole: icon)
                        .font(MoleTokens.ui(13, weight: .semibold))
                }
                Text(title)
                    .font(MoleTokens.ui(13, weight: .semibold))
            }
            .padding(.horizontal, kind == .quiet ? 14 : 18)
            .frame(height: MoleTokens.buttonHeight)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                if kind == .secondary {
                    Capsule().stroke(palette.border, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch kind {
        case .primary: return palette.onBrand
        case .secondary: return palette.textPrimary
        case .quiet: return palette.brand
        case .danger: return palette.onDanger
        }
    }

    private var background: Color {
        switch kind {
        case .primary: return palette.brand
        case .secondary: return palette.raised
        case .quiet: return .clear
        case .danger: return palette.danger
        }
    }
}

struct MoleIconButton: View {
    @Environment(\.molePalette) private var palette

    var symbol: MoleSymbol = .ellipsis
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(mole: symbol)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textSecondary)
                .frame(width: MoleTokens.iconButton, height: MoleTokens.iconButton)
                .background(palette.canvas)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("More")
    }
}

struct MoleCheckbox: View {
    @Environment(\.molePalette) private var palette

    var isOn: Bool
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: MoleTokens.checkboxRadius, style: .continuous)
                    .fill(isOn ? palette.brand : Color.clear)
                    .overlay {
                        RoundedRectangle(cornerRadius: MoleTokens.checkboxRadius, style: .continuous)
                            .stroke(isOn ? palette.brand : palette.strongBorder, lineWidth: 1)
                    }
                if isOn {
                    Image(mole: .check)
                        .font(MoleTokens.ui(9, weight: .bold))
                        .foregroundStyle(palette.onBrand)
                }
            }
            .frame(width: MoleTokens.checkboxSize, height: MoleTokens.checkboxSize)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.45)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }
}

struct MoleSearchField: View {
    @Environment(\.molePalette) private var palette

    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(mole: .search)
                .font(MoleTokens.ui(12))
                .foregroundStyle(palette.textSecondary)
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(palette.textSecondary))
                .textFieldStyle(.plain)
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textPrimary)
        }
        .padding(.horizontal, 10)
        .frame(height: MoleTokens.searchHeight)
        .background(palette.raised)
        .clipShape(RoundedRectangle(cornerRadius: MoleTokens.fieldRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MoleTokens.fieldRadius, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        }
    }
}

struct BrandMark: View {
    @Environment(\.molePalette) private var palette

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(palette.brand)
                .frame(width: 22, height: 22)
            Text("M")
                .font(MoleTokens.ui(11, weight: .semibold))
                .foregroundStyle(palette.onBrand)
        }
    }
}
