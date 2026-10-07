import SwiftUI

struct EmptyStateCard: View {
    @Environment(\.molePalette) private var palette

    var title: String
    var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(MoleTokens.ui(16, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            Text(message)
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
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

enum MoleEmptyState {
    static let notScanned = EmptyStateCard(
        title: "Not scanned",
        message: "No current evidence. Scan to see reclaimable space."
    )
    static let nothingFound = EmptyStateCard(
        title: "Nothing found",
        message: "No eligible cleanup candidates in this scan."
    )
    static let permissionMissing = EmptyStateCard(
        title: "Permission missing",
        message: "Full Disk Access is off. Protected folders stay Unknown."
    )
    static let noHistory = EmptyStateCard(
        title: "No history",
        message: "No Mole operations recorded yet."
    )
}

struct ScanInProgressView: View {
    @Environment(\.molePalette) private var palette

    var family: String = "Developer tools"
    var elapsed: String = "0:42"
    var checked: String = "3 families checked"
    var onCancel: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scanning…")
                .font(MoleTokens.ui(24, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            Text("Current family: \(family)")
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
            Text("Elapsed \(elapsed) · \(checked)")
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textSecondary)
            Text("No destructive action is available until this scan completes. A cancelled scan cannot publish an executable plan.")
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            HStack {
                Spacer()
                MoleButton(title: "Cancel Scan", kind: .secondary, action: onCancel)
            }
        }
        .padding(MoleTokens.bodyPadding)
        .background(palette.canvas)
    }
}
