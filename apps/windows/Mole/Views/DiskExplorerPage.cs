using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using Mole.Engine;

namespace Mole.Views;

public sealed class DiskExplorerPage : UserControl
{
    private string _selectedId = "documents";
    private string _tab = "This folder";
    private readonly StackPanel _list = new();
    private readonly StackPanel _inspector = new() { Spacing = 10 };
    private readonly StackPanel _tabs = new() { Orientation = Orientation.Horizontal, Spacing = 8 };

    public DiskExplorerPage()
    {
        var crumb = Layout.Row(8,
            Theme.Text("C:", 13, medium: true, brush: "MoleBrand"),
            Theme.Text("›", 13, brush: "MoleTextSecondary"),
            Theme.Text("Users", 13, medium: true, brush: "MoleBrand"),
            Theme.Text("›", 13, brush: "MoleTextSecondary"),
            Theme.Text("you", 13, medium: true));

        RebuildTabs();

        var header = new Grid { Height = 32 };
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(100) });
        header.Children.Add(Theme.Text("Name", 12, medium: true, brush: "MoleTextSecondary"));
        var sizeH = Theme.Text("Size", 12, medium: true, brush: "MoleTextSecondary");
        sizeH.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(sizeH, 1);
        header.Children.Add(sizeH);

        RebuildList();
        RebuildInspector();

        var listPane = Layout.Column(12, crumb, _tabs, header, _list);
        listPane.Padding = new Thickness(20);

        var inspector = new Border
        {
            Width = 280,
            BorderBrush = Theme.Brush("MoleBorder"),
            BorderThickness = new Thickness(1, 0, 0, 0),
            Padding = new Thickness(16),
            Child = new ScrollViewer { Content = _inspector }
        };

        var root = new Grid();
        root.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        root.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        root.Children.Add(listPane);
        Grid.SetColumn(inspector, 1);
        root.Children.Add(inspector);
        Content = root;
    }

    private void RebuildTabs()
    {
        _tabs.Children.Clear();
        foreach (var label in new[] { "This folder", "Large files" })
        {
            var chip = new FilterChip(label, _tab == label);
            var captured = label;
            chip.Activated += (_, _) =>
            {
                _tab = captured;
                RebuildTabs();
                RebuildList();
            };
            _tabs.Children.Add(chip);
        }
    }

    private void RebuildList()
    {
        _list.Children.Clear();
        IEnumerable<DiskItem> items = Fixtures.Disk;
        if (_tab == "Large files")
        {
            items = items.Where(i => i.Id is "videos" or "downloads" or "iso" or "appdata");
        }
        foreach (var item in items)
        {
            _list.Children.Add(Line(item));
        }
    }

    private UIElement Line(DiskItem item)
    {
        var grid = new Grid { Height = 48 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(100) });
        var name = Layout.Row(8, Theme.Text(item.Name, 13, medium: true));
        if (item.Partial)
        {
            name.Children.Add(new StatusPill("Partial", PillTone.Review));
        }
        if (item.Unavailable)
        {
            name.Children.Add(new StatusPill("Unavailable", PillTone.Danger));
        }
        var size = Theme.Text(
            item.Size,
            13,
            medium: true,
            brush: item.Partial ? "MoleReview" : "MoleTextPrimary");
        size.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(size, 2);
        grid.Children.Add(name);
        grid.Children.Add(size);

        var border = new Border
        {
            Background = item.Id == _selectedId ? Theme.Brush("MoleSelected") : new SolidColorBrush(Microsoft.UI.Colors.Transparent),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(8, 0, 8, 0),
            Opacity = item.Unavailable ? 0.7 : 1,
            Child = grid
        };
        border.PointerPressed += (_, _) =>
        {
            _selectedId = item.Id;
            RebuildList();
            RebuildInspector();
        };
        return border;
    }

    private void RebuildInspector()
    {
        _inspector.Children.Clear();
        var item = Fixtures.Disk.First(i => i.Id == _selectedId);
        _inspector.Children.Add(Theme.Text(item.Name, 16, semibold: true));
        var path = Theme.Text(item.Path, 11, brush: "MoleTextSecondary", wrap: true);
        path.FontFamily = new FontFamily("Cascadia Mono");
        _inspector.Children.Add(path);
        Fact("Size", item.Size);
        Fact("Scan status", item.ScanStatus);
        Fact("Children", item.Children);
        Fact("Modified", item.Modified);
        Fact("Protection", item.Protection);
        _inspector.Children.Add(Theme.Text("Preview", 12, medium: true, brush: "MoleTextSecondary"));
        var move = new MoleButton("Move to Recycle Bin…", MoleButtonKind.Primary)
        {
            HorizontalAlignment = HorizontalAlignment.Stretch,
            IsEnabled = false
        };
        _inspector.Children.Add(move);
    }

    private void Fact(string kicker, string value)
    {
        _inspector.Children.Add(Theme.Text(kicker, 12, brush: "MoleTextSecondary"));
        _inspector.Children.Add(Theme.Text(value, 13, medium: true));
    }
}
