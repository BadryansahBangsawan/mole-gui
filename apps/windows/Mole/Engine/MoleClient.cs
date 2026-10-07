namespace Mole.Engine;

/// <summary>
/// Windows has no mo protocol engine. Fixtures are for visual QA only.
/// Never parse TUI. Never invent deletion rules. Execute is not implemented.
/// </summary>
public sealed class MoleClient
{
    public Task<OverviewSnapshot> LoadOverviewAsync() =>
        Task.FromResult(Fixtures.Overview);

    public Task ExecuteAsync(string operation, IReadOnlyList<string> paths)
    {
        _ = operation;
        _ = paths;
        return Task.FromException(new PlatformNotSupportedException(
            "Windows has no mo protocol engine. The GUI cannot delete files."));
    }
}
