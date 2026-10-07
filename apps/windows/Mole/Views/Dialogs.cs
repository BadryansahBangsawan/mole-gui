using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;

namespace Mole.Views;

public sealed class ConfirmRecycleCard : UserControl
{
    public event EventHandler? Cancel;
    public event EventHandler? Confirm;

    public ConfirmRecycleCard()
    {
        var cancel = new MoleButton("Cancel", MoleButtonKind.Secondary);
        cancel.Click += (_, _) => Cancel?.Invoke(this, EventArgs.Empty);
        var confirm = new MoleButton("Move to Recycle Bin", MoleButtonKind.Primary);
        confirm.Click += (_, _) => Confirm?.Invoke(this, EventArgs.Empty);

        Content = new ConfirmCard(Layout.Column(12,
            Theme.Text("Move 12 items to Recycle Bin?", 20, semibold: true, wrap: true),
            Theme.Text("3.5 GB measured · Paths reviewed · 1 item requires elevation", 13, brush: "MoleTextSecondary", wrap: true),
            new SafetyBanner("Items can be restored from Recycle Bin in File Explorer.", PillTone.Success),
            Path(@"C:\Users\you\AppData\Local\Google\Chrome\User Data\Default\Cache"),
            Path(@"C:\Users\you\AppData\Local\Microsoft\Edge\User Data\Default\Cache"),
            Theme.Text("Windows Hello is requested only after this plan is confirmed.", 12, brush: "MoleTextSecondary", wrap: true),
            Actions(cancel, confirm)));
    }

    internal static TextBlock Path(string value)
    {
        var text = Theme.Text(value, 12, wrap: true);
        text.FontFamily = new FontFamily("Cascadia Mono");
        return text;
    }

    internal static UIElement Actions(UIElement cancel, UIElement confirm)
    {
        var grid = new Grid();
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        var row = Layout.Row(8, cancel, confirm);
        row.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(row, 1);
        grid.Children.Add(row);
        return grid;
    }
}

public sealed class ConfirmRebuildableCard : UserControl
{
    public event EventHandler? Cancel;
    public event EventHandler? Confirm;

    public ConfirmRebuildableCard()
    {
        var cancel = new MoleButton("Cancel", MoleButtonKind.Secondary);
        cancel.Click += (_, _) => Cancel?.Invoke(this, EventArgs.Empty);
        var confirm = new MoleButton("Remove permanently", MoleButtonKind.Primary);
        confirm.Click += (_, _) => Confirm?.Invoke(this, EventArgs.Empty);

        Content = new ConfirmCard(Layout.Column(12,
            Theme.Text("Remove 12 rebuildable items permanently?", 20, semibold: true, wrap: true),
            Theme.Text("3.5 GB measured · Paths reviewed · 1 item requires elevation", 13, brush: "MoleTextSecondary", wrap: true),
            new SafetyBanner("These caches and installers will not appear in Recycle Bin.", PillTone.Review),
            ConfirmRecycleCard.Path(@"C:\Users\you\AppData\Local\Google\Chrome\User Data\Default\Cache"),
            ConfirmRecycleCard.Path(@"C:\Users\you\AppData\Local\Microsoft\Edge\User Data\Default\Cache"),
            Theme.Text("Windows Hello is requested only after this plan is confirmed.", 12, brush: "MoleTextSecondary", wrap: true),
            ConfirmRecycleCard.Actions(cancel, confirm)));
    }
}

public sealed class ConfirmPermanentCard : UserControl
{
    public event EventHandler? Cancel;
    public event EventHandler? Confirm;

    public ConfirmPermanentCard()
    {
        var cancel = new MoleButton("Cancel", MoleButtonKind.Secondary);
        cancel.Click += (_, _) => Cancel?.Invoke(this, EventArgs.Empty);
        var confirm = new MoleButton("Delete Permanently", MoleButtonKind.Danger);
        confirm.Click += (_, _) => Confirm?.Invoke(this, EventArgs.Empty);

        Content = new ConfirmCard(Layout.Column(12,
            Theme.Text("Delete 2 project artifacts permanently?", 20, semibold: true, wrap: true),
            Theme.Text("6.00 GB estimated · 2 paths reviewed · No elevation needed", 13, brush: "MoleTextSecondary", wrap: true),
            new SafetyBanner(
                "These selected artifacts will be deleted permanently and cannot be restored from Recycle Bin.",
                PillTone.Danger),
            ConfirmRecycleCard.Path(@"C:\Users\you\Projects\website\node_modules"),
            ConfirmRecycleCard.Path(@"C:\Users\you\Projects\rust-app\target"),
            ConfirmRecycleCard.Actions(cancel, confirm)));
    }
}

public enum ResultKind
{
    Recycle,
    Clean,
    Cancelled,
    Failed
}

public sealed class ResultCard : UserControl
{
    public event EventHandler? ViewHistory;
    public event EventHandler? Primary;

    public ResultCard(ResultKind kind = ResultKind.Recycle)
    {
        var (title, freed, counts, detail, primaryLabel) = kind switch
        {
            ResultKind.Clean => (
                "Cleanup complete",
                "4.5 GB actually freed",
                "97 removed permanently · 3 skipped · 0 failed",
                "Chrome is running, so its profile caches were kept.",
                "Done"),
            ResultKind.Cancelled => (
                "Cleanup cancelled",
                "0 B actually freed",
                "0 removed · 0 skipped · cancelled",
                "No files were changed. The plan is discarded.",
                "Done"),
            ResultKind.Failed => (
                "Cleanup failed",
                "0 B actually freed",
                "0 removed · 0 skipped · 1 failed",
                "A path identity changed after the plan. Nothing was deleted.",
                "Done"),
            _ => (
                "Cleanup complete",
                "4.5 GB actually freed",
                "97 moved to Recycle Bin · 3 skipped · 0 failed",
                "Chrome is running, so its profile caches were kept.",
                "Open Recycle Bin")
        };

        var history = new MoleButton("View History", MoleButtonKind.Secondary);
        history.Click += (_, _) => ViewHistory?.Invoke(this, EventArgs.Empty);
        var primary = new MoleButton(primaryLabel, MoleButtonKind.Primary);
        primary.Click += (_, _) => Primary?.Invoke(this, EventArgs.Empty);

        Content = new ConfirmCard(Layout.Column(12,
            Theme.Text(title, 20, semibold: true),
            Theme.Text(freed, 13, medium: true),
            Theme.Text(counts, 13, wrap: true),
            Theme.Text(detail, 13, brush: "MoleTextSecondary", wrap: true),
            ConfirmRecycleCard.Actions(history, primary)));
    }
}
