import SwiftUI

enum MolePillTone {
    case neutral
    case success
    case review
    case danger
    case selectedCanvas
}

struct StatusPill: View {
    @Environment(\.molePalette) private var palette

    var label: String
    var icon: MoleSymbol?
    var tone: MolePillTone = .neutral

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(mole: icon)
                    .font(MoleTokens.ui(10, weight: .semibold))
            }
            Text(label)
                .font(MoleTokens.ui(12, weight: .medium))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .frame(height: MoleTokens.pillHeight)
        .background(background)
        .clipShape(Capsule())
    }

    private var foreground: Color {
        switch tone {
        case .neutral: return palette.textPrimary
        case .success: return palette.success
        case .review: return palette.review
        case .danger: return palette.danger
        case .selectedCanvas: return palette.success
        }
    }

    private var background: Color {
        switch tone {
        case .neutral: return palette.raised
        case .success: return palette.successFill
        case .review: return palette.reviewFill
        case .danger: return palette.dangerFill
        case .selectedCanvas: return palette.canvas
        }
    }
}

struct SummaryPanel: View {
    @Environment(\.molePalette) private var palette

    var kicker: String
    var value: String
    var hint: String
    var hintTone: MolePillTone = .neutral

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(kicker)
                .font(MoleTokens.ui(12, weight: .medium))
                .foregroundStyle(palette.textSecondary)
            Text(value)
                .font(MoleTokens.ui(32, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            Text(hint)
                .font(MoleTokens.ui(12))
                .foregroundStyle(hintTone == .review ? palette.review : palette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(palette.raised)
        .clipShape(RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        }
    }
}

struct RecommendationRow: View {
    @Environment(\.molePalette) private var palette

    var title: String
    var icon: MoleSymbol
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(mole: icon)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.brand)
                Text(title)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(mole: .chevronRight)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(palette.canvas)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ActivityRow: View {
    @Environment(\.molePalette) private var palette

    var command: String
    var detail: String
    var time: String

    var body: some View {
        HStack(spacing: 16) {
            Text(command)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 88, alignment: .leading)
            Text(detail)
                .font(MoleTokens.ui(12))
                .foregroundStyle(palette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            Text(time)
                .font(MoleTokens.ui(12))
                .foregroundStyle(palette.textSecondary)
        }
        .padding(.horizontal, 4)
        .frame(height: MoleTokens.activityRowHeight)
    }
}

struct CandidateRow: View {
    @Environment(\.molePalette) private var palette

    var name: String
    var items: String
    var size: String
    var sizeTone: MolePillTone = .neutral
    var stateLabel: String
    var stateTone: MolePillTone
    var isOn: Bool
    var enabled: Bool = true
    var toggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            MoleCheckbox(isOn: isOn, enabled: enabled, action: toggle)
            Text(name)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(items)
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textSecondary)
                .frame(width: 64, alignment: .trailing)
            Text(size)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(sizeTone == .review ? palette.review : palette.textPrimary)
                .frame(width: 88, alignment: .trailing)
            StatusPill(label: stateLabel, tone: stateTone)
        }
        .padding(.horizontal, 8)
        .frame(height: MoleTokens.candidateRowHeight)
        .background(isOn ? palette.selected : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .opacity(enabled ? 1 : 0.7)
    }
}

struct SafetyBanner: View {
    @Environment(\.molePalette) private var palette

    var message: String
    var tone: MolePillTone = .review

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(mole: .warning)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(foreground)
            Text(message)
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        }
    }

    private var foreground: Color {
        switch tone {
        case .danger: return palette.danger
        case .success: return palette.success
        default: return palette.review
        }
    }

    private var background: Color {
        switch tone {
        case .danger: return palette.dangerFill
        case .success: return palette.successFill
        default: return palette.reviewFill
        }
    }
}

struct NavItem: View {
    @Environment(\.molePalette) private var palette

    var title: String
    var symbol: MoleSymbol
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(mole: symbol)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .frame(width: 16, height: 16)
                    .foregroundStyle(selected ? palette.brand : palette.textSecondary)
                Text(title)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(selected ? palette.brand : palette.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(height: MoleTokens.navItemHeight)
            .background(selected ? palette.selected : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: MoleTokens.navRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: MoleTokens.navRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
