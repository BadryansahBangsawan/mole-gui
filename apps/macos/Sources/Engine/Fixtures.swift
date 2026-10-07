import Foundation

enum MoleFixtures {
    static let overview = OverviewSnapshot(
        freeSpace: "156 GB free",
        lastScan: "Last scan 2 days ago · stale",
        lastScanStale: true,
        healthScore: "92",
        healthHint: "Good · snapshot, not live",
        reclaimable: "8.4 GB",
        reclaimableHint: "Measured · 12 categories ready",
        applications: "48",
        applicationsHint: "3 not used in 90 days",
        applicationsHintReview: true,
        recommendations: [
            OverviewRecommendation(
                id: "clean",
                title: "Review 8.4 GB of known-safe cleanup",
                icon: .sparkles,
                destination: .clean
            ),
            OverviewRecommendation(
                id: "projects",
                title: "3 old project artifacts need review",
                icon: .folderGit,
                destination: .projects
            ),
            OverviewRecommendation(
                id: "rescan",
                title: "Last scan is 2 days old — rescan from Clean",
                icon: .refresh,
                destination: .clean
            )
        ],
        activity: [
            OverviewActivity(
                id: "clean-1",
                command: "Clean",
                detail: "97 items · 4.5 GB measured · Completed",
                time: "2 days ago"
            ),
            OverviewActivity(
                id: "uninstall-1",
                command: "Uninstall",
                detail: "Photoshop 2024 · 12.8 GB · Moved to Trash",
                time: "5 days ago"
            ),
            OverviewActivity(
                id: "optimize-1",
                command: "Optimize",
                detail: "3 applied · 3 skipped · 1 unavailable",
                time: "1 week ago"
            )
        ]
    )

    static let historySessions: [HistorySessionRow] = [
        HistorySessionRow(
            id: "clean-1",
            command: "Clean",
            started: "4 Oct 2026 10:42",
            items: "97",
            size: "4.5 GB",
            outcome: "Completed",
            outcomeTone: .success
        ),
        HistorySessionRow(
            id: "uninstall-1",
            command: "Uninstall",
            started: "1 Oct 2026 18:05",
            items: "14",
            size: "12.8 GB",
            outcome: "Moved to Trash",
            outcomeTone: .success
        ),
        HistorySessionRow(
            id: "optimize-1",
            command: "Optimize",
            started: "28 Sep 2026 09:11",
            items: "—",
            size: "—",
            outcome: "Completed with issues",
            outcomeTone: .review
        ),
        HistorySessionRow(
            id: "purge-1",
            command: "Purge",
            started: "12 Sep 2026 16:40",
            items: "2",
            size: "6.0 GB",
            outcome: "Completed",
            outcomeTone: .success
        )
    ]

    /// Kit Audit labels Chrome/Safari as Trash. Live rows must use
    /// `history --json` `deletions[].mode` (`trash` / `permanent`).
    static let historyAudit: [HistoryAuditRow] = [
        HistoryAuditRow(
            id: "chrome-cache",
            timestamp: "4 Oct 2026 10:42",
            mode: "Trash",
            status: "Trashed",
            statusTone: .success,
            size: "1.2 GB",
            path: "~/Library/Caches/Google/Chrome"
        ),
        HistoryAuditRow(
            id: "safari-cache",
            timestamp: "4 Oct 2026 10:42",
            mode: "Trash",
            status: "Trashed",
            statusTone: .success,
            size: "890 MB",
            path: "~/Library/Caches/com.apple.Safari"
        ),
        HistoryAuditRow(
            id: "chrome-profile",
            timestamp: "4 Oct 2026 10:42",
            mode: "Trash",
            status: "Kept",
            statusTone: .review,
            size: "—",
            path: "~/Library/Caches/Google/Chrome/Default"
        ),
        HistoryAuditRow(
            id: "node-modules",
            timestamp: "2 Oct 2026 18:11",
            mode: "Permanent",
            status: "Removed",
            statusTone: .danger,
            size: "6.00 GB",
            path: "~/Projects/website/node_modules"
        ),
        HistoryAuditRow(
            id: "legacy-target",
            timestamp: "2 Oct 2026 18:11",
            mode: "Permanent",
            status: "Failed",
            statusTone: .danger,
            size: "120 MB",
            path: "~/Projects/legacy-tool/target"
        )
    ]

    static let status = StatusSnapshot(
        sampled: "Sampled 10:42",
        cores: "10 cores displayed",
        live: true,
        metrics: [
            StatusMetric(id: "cpu", kicker: "CPU", value: "18%", hint: "Load 1.42 · user 11% · sys 7%"),
            StatusMetric(id: "mem", kicker: "Memory", value: "12.4 GB free", hint: "Pressure normal · 32 GB installed"),
            StatusMetric(id: "disk", kicker: "Disk", value: "156 GB free", hint: "42% used · I/O 12 MB/s"),
            StatusMetric(id: "net", kicker: "Network", value: "0.4 ↓  0.1 ↑ MB/s", hint: "Proxy off · en0"),
            StatusMetric(id: "thermals", kicker: "Battery & thermals", value: "78%", hint: "41°C · fans 1,800 rpm · on power"),
            StatusMetric(id: "procs", kicker: "Processes", value: "412", hint: "0 zombies · 3 sustained CPU")
        ],
        processes: [
            StatusProcess(id: "ws", name: "WindowServer", cpu: "24%", sustained: "8 min", attribution: "Display composition · complete"),
            StatusProcess(id: "kt", name: "kernel_task", cpu: "11%", sustained: "8 min", attribution: "Thermal · complete"),
            StatusProcess(id: "node", name: "node", cpu: "9%", sustained: "12 min", attribution: "~/Projects/website · stale 40s")
        ],
        zombieLabel: "0 zombies",
        zombieNote: "Attribution complete · no stale marker"
    )

    static let settings: [SettingsSection] = [
        SettingsSection(id: "protection", title: "Protection", rows: [
            SettingsRow(id: "cleanup-paths", title: "Cleanup path patterns", value: "3 rules"),
            SettingsRow(id: "maintenance-exclusions", title: "Maintenance exclusions", value: "1 rule")
        ]),
        SettingsSection(id: "projects", title: "Project Locations", rows: [
            SettingsRow(id: "scan-roots", title: "Scan roots", value: "Defaults · ~/Projects, ~/GitHub, ~/dev")
        ]),
        SettingsSection(id: "auth", title: "Authentication", rows: [
            SettingsRow(id: "touchid", title: "Touch ID for sudo", value: "On")
        ]),
        SettingsSection(id: "cli", title: "CLI Integration", rows: [
            SettingsRow(id: "installed-cli", title: "Installed CLI", value: "/usr/local/bin/mo"),
            SettingsRow(id: "completion", title: "Shell completion", value: "zsh · preview before changing")
        ]),
        SettingsSection(id: "updates", title: "Updates", rows: [
            SettingsRow(id: "channel", title: "Channel", value: "Stable"),
            SettingsRow(id: "check", title: "Check for update", value: "Last checked today")
        ]),
        SettingsSection(id: "advanced", title: "Advanced", rows: [
            SettingsRow(id: "diagnostics", title: "Diagnostics", value: "~/Library/Logs/mole"),
            SettingsRow(id: "remove", title: "Remove Mole…", value: "", valueTone: .danger)
        ]),
        SettingsSection(id: "about", title: "About", rows: [
            SettingsRow(id: "version", title: "Mole GUI", value: "1.56.1 companion"),
            SettingsRow(id: "license", title: "License", value: "GPL-3.0"),
            SettingsRow(
                id: "cli-relationship",
                title: "CLI relationship",
                value: "Companion for mo. CLI stays the automation surface."
            ),
            SettingsRow(id: "project", title: "Project", value: "", links: ["GitHub", "Docs", "LICENSE"])
        ])
    ]

    static let diskItems: [DiskItem] = [
        DiskItem(
            id: "library",
            name: "Library",
            size: "34.6 GB",
            path: "/Users/you/Library",
            scanStatus: "Complete",
            children: "—",
            modified: "—",
            protection: "Not protected"
        ),
        DiskItem(
            id: "documents",
            name: "Documents",
            size: "18.2 GB",
            path: "/Users/you/Documents",
            scanStatus: "Complete",
            children: "1,284 items",
            modified: "12 May 2026",
            protection: "Not protected"
        ),
        DiskItem(
            id: "movies",
            name: "Movies",
            size: "12.4 GB",
            path: "/Users/you/Movies",
            scanStatus: "Complete",
            children: "—",
            modified: "—",
            protection: "Not protected"
        ),
        DiskItem(
            id: "downloads",
            name: "Downloads",
            size: "8.2 GB+",
            sizeTone: .review,
            stateLabel: "Partial",
            stateTone: .review,
            path: "/Users/you/Downloads",
            scanStatus: "Partial",
            children: "—",
            modified: "—",
            protection: "Not protected"
        ),
        DiskItem(
            id: "desktop",
            name: "Desktop",
            size: "2.1 GB",
            path: "/Users/you/Desktop",
            scanStatus: "Complete",
            children: "—",
            modified: "—",
            protection: "Not protected"
        ),
        DiskItem(
            id: "dump",
            name: "dump.iso",
            size: "6.4 GB",
            path: "/Users/you/dump.iso",
            scanStatus: "Complete",
            children: "—",
            modified: "—",
            protection: "Not protected"
        ),
        DiskItem(
            id: "trash",
            name: ".Trash",
            size: "Unknown",
            stateLabel: "Unavailable",
            path: "/Users/you/.Trash",
            scanStatus: "Unavailable",
            children: "—",
            modified: "—",
            protection: "Not protected",
            selectable: true
        )
    ]

    static let cleanCategories: [CleanCategory] = [
        CleanCategory(
            id: "user-essentials",
            name: "User essentials",
            items: "14",
            size: "186 MB",
            state: "Ready",
            stateTone: .success,
            selected: false
        ),
        CleanCategory(
            id: "user-app-caches",
            name: "User app caches",
            items: "28",
            size: "1.7 GB",
            state: "Ready",
            stateTone: .success,
            selected: true
        ),
        CleanCategory(
            id: "browsers",
            name: "Browsers",
            items: "41",
            size: "1.2 GB",
            state: "Ready",
            stateTone: .success,
            selected: true
        ),
        CleanCategory(
            id: "developer-tools",
            name: "Developer tools",
            items: "16",
            size: "1.3 GB",
            sizeTone: .review,
            state: "App running",
            stateTone: .review,
            selected: false,
            enabled: false
        ),
        CleanCategory(
            id: "cloud-and-office",
            name: "Cloud and office",
            items: "9",
            size: "410 MB",
            state: "Ready",
            stateTone: .success,
            selected: false
        ),
        CleanCategory(
            id: "system-caches",
            name: "System caches and logs",
            items: "22",
            size: "890 MB+",
            sizeTone: .review,
            state: "Partial",
            stateTone: .review,
            selected: false
        ),
        CleanCategory(
            id: "orphaned-app-data",
            name: "Orphaned app data",
            items: "5",
            size: "240 MB",
            state: "Ready",
            stateTone: .success,
            selected: false
        ),
        CleanCategory(
            id: "installers",
            name: "Installers",
            items: "4",
            size: "600 MB",
            state: "Ready",
            stateTone: .success,
            selected: true
        )
    ]

    static let applications: [AppRow] = AppRow.kit
    static let projectGroups: [ProjectGroup] = ProjectGroup.kit
    static let maintenance: [MaintenanceSection] = MaintenanceView.kit
    static let scanLocations: [String] = [
        "~/Projects",
        "~/GitHub",
        "~/dev",
        "~/.codex/worktrees"
    ]
}
