import SwiftUI

enum ApplicationsFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case large = "Large"
    case notRecentlyUsed = "Not recently used"
    case protected = "Protected"

    var id: String { rawValue }
}

struct AppRow: Equatable, Identifiable {
    var id: String
    var name: String
    var version: String
    var size: String
    var lastUsed: String
    var letter: String
    var path: String
    var bundleID: String
    var relatedExact: String
    var sharedKept: String
    var relatedPaths: [String]
    var isProtected: Bool = false
    var enabled: Bool = true
    var checked: Bool = false
    var isLarge: Bool = false
    var notRecentlyUsed: Bool = false
}

struct ApplicationsView: View {
    @Environment(\.molePalette) private var palette

    var apps: [AppRow]
    var search: String
    var selectedID: String?
    var filter: ApplicationsFilter
    var onSearch: (String) -> Void
    var onFilter: (ApplicationsFilter) -> Void
    var onSelect: (AppRow) -> Void
    var onToggle: (AppRow) -> Void
    var onReviewUninstall: (AppRow) -> Void

    private var visibleApps: [AppRow] {
        apps.filter { app in
            let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
            if !query.isEmpty, !app.name.localizedCaseInsensitiveContains(query) {
                return false
            }
            switch filter {
            case .all: return true
            case .large: return app.isLarge
            case .notRecentlyUsed: return app.notRecentlyUsed
            case .protected: return app.isProtected
            }
        }
    }

    private var selectedApp: AppRow? {
        apps.first(where: { $0.id == selectedID })
    }

    var body: some View {
        HStack(spacing: 0) {
            listPane
            Rectangle().fill(palette.border).frame(width: 1)
            inspector
                .frame(width: 280)
        }
        .background(palette.canvas)
    }

    private var listPane: some View {
        VStack(alignment: .leading, spacing: 12) {
            filters
            VStack(spacing: 0) {
                header
                ForEach(visibleApps) { app in
                    appRow(app)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 16)
        .padding(.leading, 20)
        .padding(.trailing, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var filters: some View {
        HStack(spacing: 8) {
            ForEach(ApplicationsFilter.allCases) { item in
                let selected = filter == item
                Button {
                    onFilter(item)
                } label: {
                    Text(item.rawValue)
                        .font(MoleTokens.ui(12, weight: .medium))
                        .foregroundStyle(selected ? palette.brand : palette.textSecondary)
                        .padding(.horizontal, 12)
                        .frame(height: 28)
                        .background(selected ? palette.selected : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Color.clear.frame(width: 16, height: 16)
            Color.clear.frame(width: 32, height: 16)
            Text("Name")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Size")
                .frame(width: 72, alignment: .trailing)
            Text("Last used")
                .frame(width: 88, alignment: .trailing)
        }
        .font(MoleTokens.ui(12, weight: .medium))
        .foregroundStyle(palette.textSecondary)
        .padding(.horizontal, 8)
        .frame(height: 32)
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.border).frame(height: 1)
        }
    }

    private func appRow(_ app: AppRow) -> some View {
        let selected = app.id == selectedID
        return HStack(spacing: 12) {
            MoleCheckbox(
                isOn: app.checked,
                enabled: app.enabled,
                action: { onToggle(app) }
            )
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.raised)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(palette.border, lineWidth: 1)
                    }
                Text(app.letter)
                    .font(MoleTokens.ui(12, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
            }
            .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(app.name)
                        .font(MoleTokens.ui(13, weight: .medium))
                        .foregroundStyle(palette.textPrimary)
                        .lineLimit(1)
                    if app.isProtected {
                        StatusPill(label: "Protected", tone: .neutral)
                    }
                }
                Text(app.version)
                    .font(MoleTokens.ui(12))
                    .foregroundStyle(palette.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(app.size)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 72, alignment: .trailing)
            Text(app.lastUsed)
                .font(MoleTokens.ui(12))
                .foregroundStyle(palette.textSecondary)
                .frame(width: 88, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .frame(height: 56)
        .background(selected ? palette.selected : Color.clear)
        .opacity(app.enabled ? 1 : 0.7)
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.border).frame(height: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture { onSelect(app) }
    }

    @ViewBuilder
    private var inspector: some View {
        if let app = selectedApp {
            VStack(alignment: .leading, spacing: 16) {
                Text(app.name)
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(app.path)
                    .font(MoleTokens.mono(11))
                    .foregroundStyle(palette.textSecondary)
                    .textSelection(.enabled)
                Text(app.bundleID)
                    .font(MoleTokens.mono(11))
                    .foregroundStyle(palette.textSecondary)
                    .textSelection(.enabled)
                if !app.relatedExact.isEmpty || !app.relatedPaths.isEmpty {
                    relatedFiles(app)
                }
                Spacer(minLength: 0)
                HStack {
                    Spacer(minLength: 0)
                    MoleButton(title: "Review Uninstall…", kind: .primary) {
                        onReviewUninstall(app)
                    }
                    .disabled(!app.enabled)
                    .opacity(app.enabled ? 1 : 0.45)
                }
            }
            .padding(24)
        } else {
            Text("Select an app")
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func relatedFiles(_ app: AppRow) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Related files")
                .font(MoleTokens.ui(13, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            if !app.relatedExact.isEmpty {
                Text(app.relatedExact)
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textPrimary)
            }
            if !app.sharedKept.isEmpty {
                Text(app.sharedKept)
                    .font(MoleTokens.ui(12))
                    .foregroundStyle(palette.review)
            }
            ForEach(app.relatedPaths, id: \.self) { path in
                Text(path)
                    .font(MoleTokens.mono(11))
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(palette.raised)
        .clipShape(RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        }
    }
}

extension AppRow {
    static let kit: [AppRow] = [
        AppRow(
            id: "photoshop",
            name: "Photoshop 2024",
            version: "25.1",
            size: "4.2 GB",
            lastUsed: "2mo ago",
            letter: "P",
            path: "/Applications/Adobe Photoshop 2024/Adobe Photoshop 2024.app",
            bundleID: "com.adobe.Photoshop",
            relatedExact: "3 exact matches · 12.8 GB measured",
            sharedKept: "Shared data kept · 1 item",
            relatedPaths: [
                "…/Adobe Photoshop 2024.app",
                "~/Library/Application Support/Adobe/Adobe Photoshop 2024",
                "~/Library/Preferences/com.adobe.Photoshop.plist"
            ],
            checked: true,
            isLarge: true,
            notRecentlyUsed: true
        ),
        AppRow(
            id: "intellij",
            name: "IntelliJ IDEA",
            version: "2024.3",
            size: "2.8 GB",
            lastUsed: "3d ago",
            letter: "I",
            path: "/Applications/IntelliJ IDEA.app",
            bundleID: "com.jetbrains.intellij",
            relatedExact: "",
            sharedKept: "",
            relatedPaths: [],
            isLarge: true
        ),
        AppRow(
            id: "premiere",
            name: "Premiere Pro",
            version: "24.5",
            size: "3.4 GB",
            lastUsed: "2w ago",
            letter: "Pr",
            path: "/Applications/Adobe Premiere Pro 2024/Adobe Premiere Pro 2024.app",
            bundleID: "com.adobe.PremierePro",
            relatedExact: "",
            sharedKept: "",
            relatedPaths: [],
            isLarge: true,
            notRecentlyUsed: true
        ),
        AppRow(
            id: "slack",
            name: "Slack",
            version: "4.41",
            size: "420 MB",
            lastUsed: "1d ago",
            letter: "S",
            path: "/Applications/Slack.app",
            bundleID: "com.tinyspeck.slackmacgap",
            relatedExact: "",
            sharedKept: "",
            relatedPaths: []
        ),
        AppRow(
            id: "xcode",
            name: "Xcode",
            version: "16.2",
            size: "12.1 GB",
            lastUsed: "5d ago",
            letter: "X",
            path: "/Applications/Xcode.app",
            bundleID: "com.apple.dt.Xcode",
            relatedExact: "",
            sharedKept: "",
            relatedPaths: [],
            isLarge: true
        ),
        AppRow(
            id: "safari",
            name: "Safari",
            version: "18.3",
            size: "142 MB",
            lastUsed: "1h ago",
            letter: "Sf",
            path: "/Applications/Safari.app",
            bundleID: "com.apple.Safari",
            relatedExact: "",
            sharedKept: "",
            relatedPaths: [],
            isProtected: true,
            enabled: false
        )
    ]
}
