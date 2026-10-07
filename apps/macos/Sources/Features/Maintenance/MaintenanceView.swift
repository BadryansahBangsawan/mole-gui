import SwiftUI

struct MaintenanceTask: Equatable, Identifiable {
    var id: String
    var name: String
    var effect: String
    var state: String
    var stateTone: MolePillTone
    var selected: Bool
    var enabled: Bool = true
}

struct MaintenanceSection: Equatable, Identifiable {
    var id: String
    var title: String
    var tasks: [MaintenanceTask]
}

struct MaintenanceView: View {
    @Environment(\.molePalette) private var palette

    var sections: [MaintenanceSection]
    var onToggle: (MaintenanceTask) -> Void
    var onReview: () -> Void

    private var tasks: [MaintenanceTask] { sections.flatMap(\.tasks) }
    private var selectedCount: Int { tasks.filter(\.selected).count }
    private var skippedCount: Int { tasks.filter { $0.state == "Skipped" }.count }
    private var unavailableCount: Int { tasks.filter { $0.state == "Unavailable" }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Maintenance")
                    .font(MoleTokens.ui(24, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("Bounded tasks with a plain-language effect. Nothing is promised as a speed-up.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(sections) { section in
                    Text(section.title)
                        .font(MoleTokens.ui(12, weight: .semibold))
                        .foregroundStyle(palette.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(section.tasks) { task in
                        taskRow(task)
                    }
                }
            }
            Spacer(minLength: 0)
            HStack {
                Text("\(selectedCount) selected · \(skippedCount) skipped · \(unavailableCount) unavailable")
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                MoleButton(title: "Review Maintenance…", kind: .primary, action: onReview)
            }
        }
        .padding(MoleTokens.bodyPadding)
        .background(palette.canvas)
    }

    private func taskRow(_ task: MaintenanceTask) -> some View {
        HStack(spacing: 12) {
            MoleCheckbox(isOn: task.selected, enabled: task.enabled, action: { onToggle(task) })
            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                Text(task.effect)
                    .font(MoleTokens.ui(12))
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            StatusPill(label: task.state, tone: task.stateTone)
        }
        .padding(.horizontal, 8)
        .frame(height: 56)
        .background(task.selected ? palette.selected : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .opacity(task.enabled ? 1 : 0.7)
    }
}

extension MaintenanceView {
    /// Kit copy (fM6mt). Needs admin and Unavailable are never Eligible.
    static let kit: [MaintenanceSection] = [
        MaintenanceSection(id: "search-finder", title: "Search and Finder", tasks: [
            MaintenanceTask(
                id: "system_maintenance",
                name: "DNS & Spotlight Check",
                effect: "Refresh DNS cache and verify Spotlight status",
                state: "Eligible",
                stateTone: .success,
                selected: true
            ),
            MaintenanceTask(
                id: "cache_refresh",
                name: "Finder Cache Refresh",
                effect: "Refresh QuickLook thumbnails and icon services",
                state: "Eligible",
                stateTone: .success,
                selected: true
            )
        ]),
        MaintenanceSection(id: "apps-data", title: "Apps and data", tasks: [
            MaintenanceTask(
                id: "sqlite_vacuum",
                name: "Database Optimization",
                effect: "Compress Mail, Safari, and Messages databases · Close Safari",
                state: "Skipped",
                stateTone: .review,
                selected: false
            ),
            MaintenanceTask(
                id: "saved_state_cleanup",
                name: "App State Cleanup",
                effect: "Remove saved application states older than 30 days",
                state: "Eligible",
                stateTone: .success,
                selected: true
            )
        ]),
        MaintenanceSection(id: "system", title: "System", tasks: [
            MaintenanceTask(
                id: "disk_permissions_repair",
                name: "Permission Repair",
                effect: "Fix user directory permission issues · Administrator access",
                state: "Needs admin",
                stateTone: .review,
                selected: true
            ),
            MaintenanceTask(
                id: "disk_verify",
                name: "Disk Health",
                effect: "Verify filesystem integrity · Set MOLE_ENABLE_DISK_VERIFY=1",
                state: "Unavailable",
                stateTone: .danger,
                selected: false,
                enabled: false
            )
        ])
    ]
}
