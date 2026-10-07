namespace Mole.Engine;

public static class Fixtures
{
    public static readonly OverviewSnapshot Overview = new(
        FreeSpace: "156 GB free",
        LastScan: "Last scan 2 days ago",
        LastScanStale: true,
        HealthScore: "92",
        HealthHint: "Session snapshot · not a monitor",
        Reclaimable: "8.4 GB",
        ReclaimableHint: "Measured · 12 categories ready",
        Applications: "48",
        ApplicationsHint: "1 protected · 3 not recently used",
        Recommendations:
        [
            new("clean", "Review 8.4 GB of known-safe cleanup", MoleDestination.Clean),
            new("projects", "3 old project artifacts need review", MoleDestination.Projects),
            new("rescan", "Last scan is 2 days old — rescan from Clean", MoleDestination.Clean)
        ],
        Activity:
        [
            new("clean-1", "Clean", "97 removed permanently · 4.5 GB", "4 Oct 10:42"),
            new("uninstall-1", "Uninstall", "Photoshop leftovers reviewed", "1 Oct 18:11"),
            new("maint-1", "Maintenance", "4 applied · 2 skipped", "28 Sep 09:04")
        ]);

    public static readonly IReadOnlyList<CleanCategory> Clean = [
        new("user-temp", "User temp files", "28", "1.1 GB", "Ready", false),
        new("app-caches", "App caches", "41", "1.7 GB", "Ready", true),
        new("browsers", "Browsers", "36", "1.2 GB", "Ready", true),
        new("dev", "Developer tools", "16", "1.3 GB", "App running", false, false, true, true),
        new("office", "Office and cloud", "9", "420 MB", "Ready", false),
        new("win-caches", "Windows caches and logs", "14", "890 MB+", "Partial", false, true, true, true),
        new("orphaned", "Orphaned app data", "7", "310 MB", "Ready", false),
        new("installers", "Installers", "4", "600 MB", "Ready", true)
    ];

    public static readonly IReadOnlyList<AppRow> Applications = [
        new("photoshop", "Photoshop 2024", "4.2 GB", "2 mo", "P",
            @"C:\Program Files\Adobe\Adobe Photoshop 2024\Photoshop.exe",
            "Publisher · Adobe · Product {1E2A-PHOTOSHOP-2024}",
            "3 exact matches · 12.8 GB measured",
            "Shared data kept · 1 item",
            [
                @"C:\Program Files\Adobe\Adobe Photoshop 2024",
                @"C:\Users\you\AppData\Roaming\Adobe\Adobe Photoshop 2024",
                @"C:\Users\you\AppData\Roaming\Adobe\Adobe Photoshop 2024\Adobe Photoshop 2024 Prefs.psp"
            ],
            Checked: true, IsLarge: true, NotRecentlyUsed: true),
        new("intellij", "IntelliJ IDEA", "2.8 GB", "3 d", "I",
            @"C:\Program Files\JetBrains\IntelliJ IDEA\bin\idea64.exe", "", "", "", [],
            IsLarge: true),
        new("premiere", "Premiere Pro", "3.4 GB", "2 w", "R",
            @"C:\Program Files\Adobe\Adobe Premiere Pro 2024\Adobe Premiere Pro.exe", "", "", "", [],
            IsLarge: true, NotRecentlyUsed: true),
        new("slack", "Slack", "420 MB", "1 d", "S",
            @"C:\Users\you\AppData\Local\slack\slack.exe", "", "", "", []),
        new("vs", "Visual Studio", "8.1 GB", "5 d", "V",
            @"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe", "", "", "", [],
            IsLarge: true),
        new("edge", "Microsoft Edge", "890 MB", "today", "E",
            @"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", "", "", "", [],
            IsProtected: true, Enabled: false)
    ];

    public static readonly IReadOnlyList<DiskItem> Disk = [
        new("appdata", "AppData", "18.4 GB", @"C:\Users\you\AppData", "Complete", "—", "—", "Not protected"),
        new("documents", "Documents", "12.1 GB", @"C:\Users\you\Documents", "Complete", "418", "2 Oct 2026", "Not protected"),
        new("videos", "Videos", "9.6 GB", @"C:\Users\you\Videos", "Complete", "—", "—", "Not protected"),
        new("downloads", "Downloads", "8.2 GB+", @"C:\Users\you\Downloads", "Partial", "—", "—", "Not protected", Partial: true),
        new("desktop", "Desktop", "2.1 GB", @"C:\Users\you\Desktop", "Complete", "—", "—", "Not protected"),
        new("iso", "dump.iso", "4.7 GB", @"C:\Users\you\dump.iso", "Complete", "—", "—", "Not protected"),
        new("recycle", "$Recycle.Bin", "Unknown", @"C:\$Recycle.Bin", "Unavailable", "—", "—", "Not protected", Unavailable: true)
    ];

    public static readonly IReadOnlyList<ProjectGroup> Projects = [
        new("website", @"C:\Users\you\Projects\website", "3.18 GB", [
            new("website-nm", "node_modules", "3.10 GB", "Old", true),
            new("website-dist", "dist", "80 MB", "Recent", false)
        ]),
        new("rust", @"C:\Users\you\Projects\rust-app", "2.90 GB", [
            new("rust-target", "target", "2.90 GB", "Old", true)
        ]),
        new("legacy", @"C:\Users\you\Projects\legacy-tool", "120 MB", [
            new("legacy-git", "nested-git", "120 MB", "Protected", false, false, true)
        ])
    ];

    public static readonly IReadOnlyList<MaintenanceSection> Maintenance = [
        new("search", "Search and Explorer", [
            new("search-check", "Windows Search check", "Verify indexer status and refresh the catalog if stale", "Ready", true),
            new("thumbs", "Thumbnail cache refresh", "Rebuild Explorer thumbnail and icon caches", "Ready", true)
        ]),
        new("apps", "Apps and data", [
            new("db", "Database optimization", "Compact local app databases; skips if those apps are running", "App running", false, false, true),
            new("toast", "Notification cleanup", "Clear old delivered notification history", "Ready", true)
        ]),
        new("system", "System", [
            new("dns", "DNS cache flush", "Flush DNS resolver cache. Requires elevation.", "Needs Hello", true, true, true),
            new("dism", "Component store health", "DISM StartComponentCleanup — skipped on battery", "On battery", false, false, true)
        ])
    ];

    public static readonly IReadOnlyList<HistorySession> History = [
        new("clean-1", "Clean", "4 Oct 2026 10:42", "97", "4.5 GB", "Completed"),
        new("uninstall-1", "Uninstall", "1 Oct 2026 18:11", "14", "890 MB", "Completed with skips"),
        new("maint-1", "Maintenance", "28 Sep 2026 09:04", "4", "—", "2 skipped"),
        new("purge-1", "Purge", "17 Sep 2026 21:04", "2", "6.00 GB", "Permanent")
    ];

    public static readonly IReadOnlyList<HistoryAuditRow> HistoryAudit = [
        new("chrome-cache", "4 Oct 2026 10:42", "Permanent", "Removed", "1.2 GB",
            @"C:\Users\you\AppData\Local\Google\Chrome\User Data\Default\Cache", ModePermanent: true),
        new("edge-cache", "4 Oct 2026 10:42", "Permanent", "Removed", "890 MB",
            @"C:\Users\you\AppData\Local\Microsoft\Edge\User Data\Default\Cache", ModePermanent: true),
        new("chrome-kept", "4 Oct 2026 10:42", "Permanent", "Kept", "—",
            @"C:\Users\you\AppData\Local\Google\Chrome\User Data\Default", true, false, true),
        new("photoshop", "1 Oct 2026 18:11", "Recycle", "Recycled", "890 MB",
            @"C:\Program Files\Adobe\Adobe Photoshop 2024"),
        new("node-modules", "17 Sep 2026 21:04", "Permanent", "Removed", "6.00 GB",
            @"C:\Users\you\Projects\website\node_modules", false, true, true)
    ];

    public static readonly IReadOnlyList<CleanReviewItem> CleanReview = [
        new("chrome", @"C:\Users\you\AppData\Local\Google\Chrome\User Data\Default\Cache", "1.2 GB", "Ready"),
        new("edge", @"C:\Users\you\AppData\Local\Microsoft\Edge\User Data\Default\Cache", "890 MB", "Protected",
            false, false, false, false, true),
        new("temp", @"C:\Users\you\AppData\Local\Temp", "640 MB", "Ready"),
        new("win-temp", @"C:\Windows\Temp", "210 MB+", "Partial", true, true, true, true),
        new("pip", @"C:\Users\you\AppData\Local\pip\Cache", "180 MB", "Ready")
    ];

    public static readonly IReadOnlyList<SettingsSection> Settings = [
        new("protection", "Protection", [
            new("paths", "Cleanup path patterns", "5 paths"),
            new("excl", "Maintenance exclusions", "2 tasks")
        ]),
        new("projects", "Project locations", [
            new("roots", "Scan roots", @"C:\Users\you\Projects · defaults + custom")
        ]),
        new("auth", "Authentication", [
            new("hello", "Windows Hello", "On · used only after a plan is confirmed")
        ]),
        new("cli", "CLI integration", [
            new("installed", "Installed CLI", @"C:\Users\you\AppData\Local\Mole\mo.exe"),
            new("completion", "Shell completion", "PowerShell profile · preview first")
        ]),
        new("updates", "Updates", [
            new("channel", "Channel", "Stable"),
            new("check", "Check for update", "Last checked today")
        ]),
        new("advanced", "Advanced", [
            new("diag", "Diagnostics", @"%LOCALAPPDATA%\Mole\logs"),
            new("remove", "Remove Mole…", "Uninstall preview", true)
        ]),
        new("about", "About", [
            new("gui", "Mole GUI", "Windows companion · 1.56.1"),
            new("license", "License", "GPL-3.0"),
            new("rel", "CLI relationship", "Companion UI. CLI remains the automation surface.")
        ])
    ];
}
