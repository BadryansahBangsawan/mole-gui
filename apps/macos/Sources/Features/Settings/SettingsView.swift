import SwiftUI

struct SettingsRow: Equatable, Identifiable {
    var id: String
    var title: String
    var value: String
    var valueTone: MolePillTone = .neutral
    var links: [String] = []
}

struct SettingsSection: Equatable, Identifiable {
    var id: String
    var title: String
    var rows: [SettingsRow]
}

private enum SettingsDetail: String, Identifiable {
    case authentication
    case cli
    case updates
    case advanced
    case protect
    case scan

    var id: String { rawValue }

    static func matching(_ row: SettingsRow) -> SettingsDetail? {
        switch row.id {
        case "touchid": return .authentication
        case "installed-cli", "completion": return .cli
        case "channel", "check": return .updates
        case "diagnostics", "remove": return .advanced
        case "cleanup-paths", "maintenance-exclusions": return .protect
        case "scan-roots": return .scan
        default: return nil
        }
    }
}

struct SettingsView: View {
    @Environment(\.molePalette) private var palette

    var sections: [SettingsSection]
    var onRow: (SettingsRow) -> Void

    @State private var detail: SettingsDetail?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(MoleTokens.ui(12, weight: .medium))
                            .foregroundStyle(palette.textSecondary)
                        VStack(spacing: 0) {
                            ForEach(section.rows) { row in
                                Button {
                                    onRow(row)
                                    detail = SettingsDetail.matching(row)
                                } label: {
                                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                                        Text(row.title)
                                            .font(MoleTokens.ui(13, weight: .medium))
                                            .foregroundStyle(row.valueTone == .danger ? palette.danger : palette.textPrimary)
                                        Spacer()
                                        if row.links.isEmpty {
                                            Text(row.value)
                                                .font(row.id == "cli-relationship" ? MoleTokens.ui(12) : MoleTokens.ui(13))
                                                .foregroundStyle(palette.textSecondary)
                                                .multilineTextAlignment(.trailing)
                                        } else {
                                            HStack(spacing: 12) {
                                                ForEach(row.links, id: \.self) { link in
                                                    Text(link)
                                                        .font(MoleTokens.ui(13))
                                                        .foregroundStyle(palette.brand)
                                                }
                                            }
                                        }
                                        if row.links.isEmpty {
                                            Image(mole: .chevronRight)
                                                .font(MoleTokens.ui(12, weight: .medium))
                                                .foregroundStyle(palette.textSecondary)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(palette.raised)
                        .clipShape(RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous)
                                .stroke(palette.border, lineWidth: 1)
                        }
                    }
                }
            }
            .padding(MoleTokens.bodyPadding)
        }
        .background(palette.canvas)
        .overlay {
            if let detail {
                sheet(for: detail)
            }
        }
    }

    @ViewBuilder
    private func sheet(for detail: SettingsDetail) -> some View {
        switch detail {
        case .authentication:
            SettingsAuthenticationSheet(onDone: { self.detail = nil })
        case .cli:
            SettingsCLISheet(onDone: { self.detail = nil })
        case .updates:
            SettingsUpdatesSheet(
                onNotNow: { self.detail = nil },
                onCheck: { self.detail = nil }
            )
        case .advanced:
            SettingsAdvancedSheet(
                onCopyDiagnostics: { self.detail = nil },
                onDone: { self.detail = nil }
            )
        case .protect:
            ProtectPathsSheet(
                onCancel: { self.detail = nil },
                onSave: { self.detail = nil }
            )
        case .scan:
            ScanLocationsSheet(onSave: { self.detail = nil })
        }
    }
}
