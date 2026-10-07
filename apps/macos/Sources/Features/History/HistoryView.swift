import SwiftUI

enum HistoryTab: String, CaseIterable, Identifiable {
    case sessions = "Sessions"
    case audit = "Deletion Audit"

    var id: String { rawValue }
}

struct HistorySessionRow: Equatable, Identifiable {
    var id: String
    var command: String
    var started: String
    var items: String
    var size: String
    var outcome: String
    var outcomeTone: MolePillTone
}

struct HistoryAuditRow: Equatable, Identifiable {
    var id: String
    var timestamp: String
    var mode: String
    var status: String
    var statusTone: MolePillTone
    var size: String
    var path: String
}

struct HistoryView: View {
    @Environment(\.molePalette) private var palette

    var tab: HistoryTab
    var sessions: [HistorySessionRow]
    var audit: [HistoryAuditRow]
    var selectedSessionID: String?
    var selectedAuditID: String?
    var onTab: (HistoryTab) -> Void
    var onSelectSession: (HistorySessionRow) -> Void
    var onSelectAudit: (HistoryAuditRow) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(tab == .sessions ? "History" : "Deletion audit")
                .font(MoleTokens.ui(24, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            tabs
            if tab == .sessions {
                sessionTable
            } else {
                auditTable
            }
            Text(
                tab == .sessions
                    ? "History is read-only. Clearing logs is not available in the first release."
                    : "Read-only audit. Trashed items can be restored from macOS Trash. Permanent removals cannot."
            )
            .font(MoleTokens.ui(12))
            .foregroundStyle(palette.textSecondary)
            Spacer(minLength: 0)
        }
        .padding(MoleTokens.bodyPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(palette.canvas)
    }

    private var tabs: some View {
        HStack(spacing: 8) {
            ForEach(HistoryTab.allCases) { item in
                Button {
                    onTab(item)
                } label: {
                    Text(item.rawValue)
                        .font(MoleTokens.ui(13, weight: .medium))
                        .foregroundStyle(tab == item ? palette.brand : palette.textSecondary)
                        .padding(.horizontal, 14)
                        .frame(height: 32)
                        .background(tab == item ? palette.selected : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var sessionTable: some View {
        VStack(spacing: 0) {
            sessionHeader
            ForEach(sessions) { row in
                sessionRow(row, selected: row.id == selectedSessionID)
                    .onTapGesture { onSelectSession(row) }
            }
        }
    }

    private var sessionHeader: some View {
        HStack(spacing: 16) {
            headerCell("Command", width: 160)
            headerCell("Started", width: 160)
            headerCell("Items", width: 80)
            headerCell("Size", width: 100)
            headerCell("Outcome", width: nil)
        }
        .padding(.horizontal, 8)
        .frame(height: 36)
    }

    private func sessionRow(_ row: HistorySessionRow, selected: Bool) -> some View {
        HStack(spacing: 16) {
            Text(row.command)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 160, alignment: .leading)
            Text(row.started)
                .font(MoleTokens.ui(12))
                .foregroundStyle(palette.textSecondary)
                .frame(width: 160, alignment: .leading)
            Text(row.items)
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 80, alignment: .leading)
            Text(row.size)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 100, alignment: .leading)
            StatusPill(label: row.outcome, tone: selected ? .selectedCanvas : row.outcomeTone)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .background(selected ? palette.selected : Color.clear)
        .overlay {
            if selected {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(palette.border, lineWidth: 1)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var auditTable: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                headerCell("Timestamp", width: 150)
                headerCell("Mode", width: 110)
                headerCell("Status", width: 120)
                headerCell("Size", width: 80)
                headerCell("Path", width: nil)
            }
            .padding(.horizontal, 8)
            .frame(height: 36)
            ForEach(audit) { row in
                auditRow(row, selected: row.id == selectedAuditID)
                    .onTapGesture { onSelectAudit(row) }
            }
        }
    }

    private func auditRow(_ row: HistoryAuditRow, selected: Bool) -> some View {
        HStack(spacing: 16) {
            Text(row.timestamp)
                .font(MoleTokens.ui(12))
                .foregroundStyle(palette.textSecondary)
                .frame(width: 150, alignment: .leading)
            Text(row.mode)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 110, alignment: .leading)
            StatusPill(label: row.status, tone: selected ? .selectedCanvas : row.statusTone)
                .frame(width: 120, alignment: .leading)
            Text(row.size)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 80, alignment: .leading)
            Text(row.path)
                .font(MoleTokens.mono(12))
                .foregroundStyle(palette.textSecondary)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .background(selected ? palette.selected : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func headerCell(_ title: String, width: CGFloat?) -> some View {
        Text(title)
            .font(MoleTokens.ui(12, weight: .medium))
            .foregroundStyle(palette.textSecondary)
            .frame(width: width, alignment: .leading)
    }
}
