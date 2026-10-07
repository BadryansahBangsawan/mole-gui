using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace Mole.Views;

public sealed class EmptyCleanPage : UserControl
{
    public event EventHandler? ScanNow;

    public EmptyCleanPage()
    {
        var scan = new MoleButton("Scan now", MoleButtonKind.Primary);
        scan.Click += (_, _) => ScanNow?.Invoke(this, EventArgs.Empty);

        var header = new Grid();
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        header.Children.Add(Theme.Text("Clean", 24, semibold: true));
        Grid.SetColumn(scan, 1);
        header.Children.Add(scan);

        var card = new Border
        {
            Background = Theme.Brush("MoleRaised"),
            CornerRadius = new CornerRadius(8),
            BorderBrush = Theme.Brush("MoleBorder"),
            BorderThickness = new Thickness(1),
            Padding = new Thickness(16),
            Child = Layout.Column(8,
                Theme.Text("No cleanup candidates", 16, semibold: true),
                Theme.Text(
                    "Caches and temp files look already tidy, or this category could not be measured. Mole never shows 0 GB when a scan is partial or unavailable.",
                    13,
                    brush: "MoleTextSecondary",
                    wrap: true))
        };

        Content = new ScrollViewer
        {
            Padding = new Thickness(20),
            Content = Layout.Column(16, header, card)
        };
    }
}

public sealed class ScanInProgressPage : UserControl
{
    public event EventHandler? Stop;

    public ScanInProgressPage()
    {
        var stop = new MoleButton("Stop scan", MoleButtonKind.Secondary);
        stop.Click += (_, _) => Stop?.Invoke(this, EventArgs.Empty);

        var footer = new Grid { Height = 56 };
        footer.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        footer.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        footer.Children.Add(Theme.Text("Browsers · Microsoft Edge profile", 13, medium: true));
        Grid.SetColumn(stop, 1);
        footer.Children.Add(stop);

        var top = Layout.Column(12,
            Theme.Text("Clean", 24, semibold: true),
            Theme.Text("Scanning user caches and logs", 16, semibold: true),
            Theme.Text(
                "Sizes appear as they become known. Incomplete categories stay marked Partial or Unknown.",
                13,
                brush: "MoleTextSecondary",
                wrap: true));
        top.Padding = new Thickness(20, 20, 20, 0);

        var root = new Grid();
        root.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
        root.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        root.Children.Add(top);
        var footerWrap = new Border
        {
            BorderBrush = Theme.Brush("MoleBorder"),
            BorderThickness = new Thickness(0, 1, 0, 0),
            Padding = new Thickness(20, 0, 20, 0),
            Child = footer
        };
        Grid.SetRow(footerWrap, 1);
        root.Children.Add(footerWrap);
        Content = root;
    }
}

public sealed class OperationProgressPage : UserControl
{
    public event EventHandler? Stop;

    public OperationProgressPage()
    {
        var stop = new MoleButton("Stop", MoleButtonKind.Secondary);
        stop.Click += (_, _) => Stop?.Invoke(this, EventArgs.Empty);

        var path = Theme.Text(
            @"C:\Users\you\AppData\Local\Temp\nse9A2.tmp",
            12,
            wrap: true);
        path.FontFamily = new Microsoft.UI.Xaml.Media.FontFamily("Cascadia Mono");

        Content = new ScrollViewer
        {
            Padding = new Thickness(20),
            Content = Layout.Column(12,
                Theme.Text("Cleanup in progress", 24, semibold: true),
                Theme.Text("Removing rebuildable items", 16, semibold: true),
                Theme.Text(
                    "Total work is unknown. Mole does not invent a percentage.",
                    13,
                    brush: "MoleTextSecondary",
                    wrap: true),
                path,
                Theme.Text("41 moved · 2 skipped · still working", 13, medium: true),
                stop)
        };
    }
}
