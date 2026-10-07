namespace Mole.Engine;

/// <summary>
/// Engine-owned recovery. The GUI cannot flip these modes except uninstall --permanent.
/// </summary>
public enum RecoveryAction
{
    Permanent,
    RecycleBin
}

public static class RecoveryContract
{
    public static RecoveryAction For(string operation) => operation switch
    {
        "clean" or "installer" or "purge" => RecoveryAction.Permanent,
        "uninstall" or "analyze-trash" => RecoveryAction.RecycleBin,
        _ => RecoveryAction.Permanent
    };
}
