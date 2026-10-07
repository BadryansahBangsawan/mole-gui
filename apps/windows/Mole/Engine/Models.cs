namespace Mole.Engine;

public enum MoleDestination
{
    Overview,
    Clean,
    Applications,
    DiskExplorer,
    Projects,
    Maintenance,
    History,
    Settings,
    FirstRun
}

public sealed record Recommendation(string Id, string Title, MoleDestination Destination);

public sealed record ActivityRow(string Id, string Command, string Detail, string Time);

public sealed record OverviewSnapshot(
    string FreeSpace,
    string LastScan,
    bool LastScanStale,
    string HealthScore,
    string HealthHint,
    string Reclaimable,
    string ReclaimableHint,
    string Applications,
    string ApplicationsHint,
    IReadOnlyList<Recommendation> Recommendations,
    IReadOnlyList<ActivityRow> Activity);

public sealed record CleanCategory(
    string Id,
    string Name,
    string Items,
    string Size,
    string State,
    bool Selected,
    bool Enabled = true,
    bool SizeReview = false,
    bool StateReview = false,
    bool StateDanger = false);

public sealed record AppRow(
    string Id,
    string Name,
    string Size,
    string LastUsed,
    string Letter,
    string Path,
    string Publisher,
    string RelatedExact,
    string SharedKept,
    IReadOnlyList<string> RelatedPaths,
    bool IsProtected = false,
    bool Enabled = true,
    bool Checked = false,
    bool IsLarge = false,
    bool NotRecentlyUsed = false);

public sealed record DiskItem(
    string Id,
    string Name,
    string Size,
    string Path,
    string ScanStatus,
    string Children,
    string Modified,
    string Protection,
    bool Partial = false,
    bool Unavailable = false);

public sealed record ProjectArtifact(
    string Id,
    string Name,
    string Size,
    string Age,
    bool Selected,
    bool Enabled = true,
    bool Protected = false);

public sealed record ProjectGroup(string Id, string Path, string Size, IReadOnlyList<ProjectArtifact> Artifacts);

public sealed record MaintenanceTask(
    string Id,
    string Name,
    string Effect,
    string State,
    bool Selected,
    bool Enabled = true,
    bool Review = false,
    bool Danger = false);

public sealed record MaintenanceSection(string Id, string Title, IReadOnlyList<MaintenanceTask> Tasks);

public sealed record HistorySession(
    string Id,
    string Command,
    string Started,
    string Items,
    string Size,
    string Outcome);

public sealed record HistoryAuditRow(
    string Id,
    string Timestamp,
    string Mode,
    string Status,
    string Size,
    string Path,
    bool StatusReview = false,
    bool StatusDanger = false,
    bool ModePermanent = false);

public sealed record CleanReviewItem(
    string Id,
    string Path,
    string Size,
    string State,
    bool Selected = true,
    bool Enabled = true,
    bool SizeReview = false,
    bool StateReview = false,
    bool Protected = false);

public sealed record SettingsRow(string Id, string Title, string Value, bool Danger = false);

public sealed record SettingsSection(string Id, string Title, IReadOnlyList<SettingsRow> Rows);
