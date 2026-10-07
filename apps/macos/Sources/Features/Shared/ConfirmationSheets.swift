import SwiftUI

/// Confirmation, progress, and result sheets. Callbacks only — deletion stays on `mo protocol`.
struct ConfirmTrashSheet: View {
    @Environment(\.molePalette) private var palette

    var itemCount: Int = 12
    var title: String = "Move 12 items to Trash?"
    var facts: String = "3.5 GB measured · Paths reviewed · 1 item requires administrator access"
    var bodyText: String = "Items can be restored from macOS Trash."
    var note: String = "Administrator access is requested only after this plan is confirmed."
    var paths: [String] = [
        "/Applications/Slack.app",
        "~/Library/Application Support/Slack",
        "~/Movies/old-export.mov"
    ]
    var onCancel: () -> Void = {}
    var onConfirm: () -> Void = {}

    var body: some View {
        ConfirmSheetChrome {
            sheetHeader(title: title, facts: facts, palette: palette)
            SafetyBanner(message: bodyText, tone: .success)
            pathList(paths, count: itemCount, palette: palette)
            if !note.isEmpty {
                Text(note)
                    .font(MoleTokens.ui(12))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            sheetActions {
                MoleButton(title: "Cancel", kind: .secondary, action: onCancel)
                MoleButton(title: "Move to Trash", kind: .primary, action: onConfirm)
            }
        }
    }
}

struct ConfirmRebuildableSheet: View {
    @Environment(\.molePalette) private var palette

    var itemCount: Int = 12
    var title: String = "Remove 12 rebuildable items permanently?"
    var facts: String = "3.5 GB measured · Paths reviewed · 1 item requires administrator access"
    var bodyText: String = "These caches and installers will not appear in Trash."
    var note: String = "Administrator access is requested only after this plan is confirmed."
    var paths: [String] = [
        "~/Library/Caches/Google/Chrome",
        "~/Library/Caches/com.apple.Safari",
        "~/Downloads/Photoshop_2024.dmg"
    ]
    var onCancel: () -> Void = {}
    var onConfirm: () -> Void = {}

    var body: some View {
        ConfirmSheetChrome {
            sheetHeader(title: title, facts: facts, palette: palette)
            SafetyBanner(message: bodyText, tone: .review)
            pathList(paths, count: itemCount, palette: palette)
            if !note.isEmpty {
                Text(note)
                    .font(MoleTokens.ui(12))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            sheetActions {
                MoleButton(title: "Cancel", kind: .secondary, action: onCancel)
                MoleButton(title: "Remove permanently", kind: .primary, action: onConfirm)
            }
        }
    }
}

struct ConfirmPermanentSheet: View {
    @Environment(\.molePalette) private var palette

    var itemCount: Int = 2
    var title: String = "Delete 2 project artifacts permanently?"
    var facts: String = "6.00 GB estimated · 2 paths reviewed · No administrator access needed"
    var bodyText: String = "These selected artifacts will be deleted permanently and cannot be restored from Trash."
    var paths: [String] = [
        "~/Projects/website/node_modules",
        "~/Projects/rust-app/target"
    ]
    var onCancel: () -> Void = {}
    var onConfirm: () -> Void = {}

    var body: some View {
        ConfirmSheetChrome {
            sheetHeader(title: title, facts: facts, palette: palette)
            SafetyBanner(message: bodyText, tone: .danger)
            pathList(paths, count: itemCount, palette: palette, showsToggle: false)
            sheetActions {
                MoleButton(title: "Cancel", kind: .secondary, action: onCancel)
                MoleButton(title: "Delete Permanently…", kind: .danger, action: onConfirm)
            }
        }
    }
}

struct ResultSummary: View {
    enum Kind {
        case trash
        case clean
        case cancelled
        case failed
    }

    @Environment(\.molePalette) private var palette

    var kind: Kind = .trash
    var title: String
    var freed: String
    var counts: String
    var detail: String
    var onViewHistory: () -> Void = {}
    var onPrimary: () -> Void = {}

    init(
        kind: Kind = .trash,
        title: String? = nil,
        freed: String? = nil,
        counts: String? = nil,
        detail: String? = nil,
        onViewHistory: @escaping () -> Void = {},
        onPrimary: @escaping () -> Void = {}
    ) {
        self.kind = kind
        self.title = title ?? kind.defaultTitle
        self.freed = freed ?? kind.defaultFreed
        self.counts = counts ?? kind.defaultCounts
        self.detail = detail ?? kind.defaultDetail
        self.onViewHistory = onViewHistory
        self.onPrimary = onPrimary
    }

    var body: some View {
        ConfirmSheetChrome {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(freed)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                Text(counts)
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textPrimary)
                Text(detail)
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            sheetActions {
                MoleButton(title: "View History", kind: .secondary, action: onViewHistory)
                MoleButton(title: primaryTitle, kind: .primary, action: onPrimary)
            }
        }
    }

    private var primaryTitle: String {
        switch kind {
        case .trash: return "Show in Trash"
        case .clean, .cancelled: return "Done"
        case .failed: return "Copy Diagnostics"
        }
    }
}

struct OperationProgressEvent: Identifiable, Equatable {
    var id: String
    var name: String
    var status: String
}

struct OperationProgress: View {
    @Environment(\.molePalette) private var palette

    var title: String = "Cleaning caches…"
    var family: String = "Browsers · 2 of 3 families · 0:42 elapsed"
    var note: String = "Total work is unknown, so no percentage is shown."
    var events: [OperationProgressEvent] = [
        OperationProgressEvent(id: "user-app-caches", name: "User app caches", status: "Removed permanently"),
        OperationProgressEvent(id: "browsers", name: "Browsers", status: "Working…"),
        OperationProgressEvent(id: "installers", name: "Installers", status: "Waiting")
    ]
    var cancelNote: String = "Cancel stops new work and reports what already completed."
    var onCancel: () -> Void = {}

    var body: some View {
        ConfirmSheetChrome(width: 520) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(family)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                Text(note)
                    .font(MoleTokens.ui(12))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ProgressView()
                .progressViewStyle(.linear)
                .tint(palette.brand)
                .accessibilityLabel(note)
            VStack(spacing: 0) {
                ForEach(events) { event in
                    HStack {
                        Text(event.name)
                            .font(MoleTokens.ui(13, weight: .medium))
                            .foregroundStyle(palette.textPrimary)
                        Spacer(minLength: 8)
                        Text(event.status)
                            .font(MoleTokens.ui(13))
                            .foregroundStyle(statusColor(event.status))
                    }
                    .frame(height: MoleTokens.activityRowHeight)
                }
            }
            Text(cancelNote)
                .font(MoleTokens.ui(12))
                .foregroundStyle(palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            sheetActions {
                MoleButton(title: "Cancel", kind: .secondary, action: onCancel)
            }
        }
    }

    private func statusColor(_ status: String) -> Color {
        if status == "Removed permanently" || status == "Moved to Trash" {
            return palette.success
        }
        if status == "Working…" {
            return palette.brand
        }
        return palette.textSecondary
    }
}

private struct ConfirmSheetChrome<Content: View>: View {
    @Environment(\.molePalette) private var palette

    var width: CGFloat = 480
    var content: Content

    init(width: CGFloat = 480, @ViewBuilder content: () -> Content) {
        self.width = width
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(24)
        .frame(width: width, alignment: .leading)
        .background(palette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        }
    }
}

private func sheetHeader(title: String, facts: String, palette: MoleTokens.Palette) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(MoleTokens.ui(20, weight: .semibold))
            .foregroundStyle(palette.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
        Text(facts)
            .font(MoleTokens.ui(13))
            .foregroundStyle(palette.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private func pathList(
    _ paths: [String],
    count: Int,
    palette: MoleTokens.Palette,
    showsToggle: Bool = true
) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        if showsToggle, count > 0 {
            Text("View all \(count) paths")
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.brand)
        }
        ForEach(paths, id: \.self) { path in
            Text(path)
                .font(MoleTokens.mono(12))
                .foregroundStyle(palette.textPrimary)
                .lineLimit(1)
        }
    }
}

private func sheetActions<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
    HStack(spacing: 12) {
        Spacer(minLength: 0)
        content()
    }
}

private extension ResultSummary.Kind {
    var defaultTitle: String {
        switch self {
        case .trash, .clean: return "Cleanup complete"
        case .cancelled: return "Cleanup cancelled"
        case .failed: return "Cleanup failed"
        }
    }

    var defaultFreed: String {
        switch self {
        case .trash, .clean: return "4.5 GB actually freed"
        case .cancelled: return "1.2 GB actually freed"
        case .failed: return "0 B actually freed"
        }
    }

    var defaultCounts: String {
        switch self {
        case .trash: return "97 moved to Trash · 3 skipped · 0 failed"
        case .clean: return "97 removed permanently · 3 skipped · 0 failed"
        case .cancelled: return "12 removed permanently · 3 skipped · remaining items unchanged"
        case .failed: return "0 removed · 2 skipped · 1 failed"
        }
    }

    var defaultDetail: String {
        switch self {
        case .trash, .clean:
            return "Chrome is running, so its profile caches were kept."
        case .cancelled:
            return "Cancel stopped new work. Already-removed items are not restored."
        case .failed:
            return "Identity changed for ~/Library/Caches/Google/Chrome. The plan expired; nothing was deleted."
        }
    }
}
