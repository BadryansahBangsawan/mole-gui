using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using Mole.Engine;

namespace Mole.Views;

public sealed class ApplicationsPage : UserControl
{
    public event EventHandler<AppRow>? ReviewUninstall;

    private readonly List<AppRow> _apps = [.. Fixtures.Applications];
    private string _filter = "All";
    private string _search = "";
    private string _selectedId = "photoshop";
    private readonly StackPanel _list = new();
    private readonly StackPanel _inspector = new() { Spacing = 12 };
    private readonly StackPanel _filters = new() { Orientation = Orientation.Horizontal, Spacing = 8 };

    public ApplicationsPage()
    {
        RebuildFilters();

        var header = new Grid { Height = 32 };
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(32) });
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(88) });
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(88) });
        var name = Theme.Text("Name", 12, medium: true, brush: "MoleTextSecondary");
        Grid.SetColumn(name, 1);
        var size = Theme.Text("Size", 12, medium: true, brush: "MoleTextSecondary");
        size.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(size, 2);
        var used = Theme.Text("Last used", 12, medium: true, brush: "MoleTextSecondary");
        used.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(used, 3);
        header.Children.Add(name);
        header.Children.Add(size);
        header.Children.Add(used);

        RebuildList();
        RebuildInspector();

        var listPane = Layout.Column(12, _filters, header, _list);
        listPane.Padding = new Thickness(20);

        var inspectorWrap = new Border
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
        Grid.SetColumn(inspectorWrap, 1);
        root.Children.Add(inspectorWrap);
        Content = root;
    }

    public void ApplySearch(string query)
    {
        _search = query;
        RebuildList();
    }

    private void RebuildFilters()
    {
        _filters.Children.Clear();
        foreach (var label in new[] { "All", "Large", "Not recently used", "Protected" })
        {
            var chip = new FilterChip(label, _filter == label);
            var captured = label;
            chip.Activated += (_, _) =>
            {
                _filter = captured;
                RebuildFilters();
                RebuildList();
            };
            _filters.Children.Add(chip);
        }
    }

    private IEnumerable<AppRow> Visible()
    {
        foreach (var app in _apps)
        {
            if (!string.IsNullOrWhiteSpace(_search) &&
                app.Name.IndexOf(_search, StringComparison.OrdinalIgnoreCase) < 0)
            {
                continue;
            }
            yield return _filter switch
            {
                "Large" when !app.IsLarge => null!,
                "Not recently used" when !app.NotRecentlyUsed => null!,
                "Protected" when !app.IsProtected => null!,
                _ => app
            };
        }
    }

    private void RebuildList()
    {
        _list.Children.Clear();
        foreach (var app in Visible().Where(a => a is not null))
        {
            _list.Children.Add(AppLine(app));
        }
    }

    private UIElement AppLine(AppRow app)
    {
        var grid = new Grid { Height = 48 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(32) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(32) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(88) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(88) });

        var check = new MoleCheckbox(app.Checked, app.Enabled);
        check.Toggled += () =>
        {
            var i = _apps.FindIndex(a => a.Id == app.Id);
            if (i >= 0 && _apps[i].Enabled)
            {
                _apps[i] = _apps[i] with { Checked = !_apps[i].Checked };
                RebuildList();
                RebuildInspector();
            }
        };

        var avatar = new Border
        {
            Width = 24,
            Height = 24,
            CornerRadius = new CornerRadius(4),
            Background = Theme.Brush("MoleRaised"),
            Child = Theme.Text(app.Letter, 11, semibold: true, brush: "MoleTextSecondary")
        };
        ((TextBlock)avatar.Child).HorizontalAlignment = HorizontalAlignment.Center;
        Grid.SetColumn(avatar, 1);

        var nameCol = new StackPanel { Spacing = 2, VerticalAlignment = VerticalAlignment.Center };
        nameCol.Children.Add(Theme.Text(app.Name, 13, medium: true));
        if (app.IsProtected)
        {
            nameCol.Children.Add(new StatusPill("Protected", PillTone.Danger));
        }
        Grid.SetColumn(nameCol, 2);

        var size = Theme.Text(app.Size, 13, medium: true);
        size.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(size, 3);
        var used = Theme.Text(app.LastUsed, 12, brush: "MoleTextSecondary");
        used.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(used, 4);

        grid.Children.Add(check);
        grid.Children.Add(avatar);
        grid.Children.Add(nameCol);
        grid.Children.Add(size);
        grid.Children.Add(used);

        var border = new Border
        {
            Background = app.Id == _selectedId ? Theme.Brush("MoleSelected") : new SolidColorBrush(Microsoft.UI.Colors.Transparent),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(8, 0, 8, 0),
            Opacity = app.Enabled ? 1 : 0.7,
            Child = grid
        };
        border.PointerPressed += (_, _) =>
        {
            _selectedId = app.Id;
            RebuildList();
            RebuildInspector();
        };
        return border;
    }

    private void RebuildInspector()
    {
        _inspector.Children.Clear();
        var app = _apps.FirstOrDefault(a => a.Id == _selectedId) ?? _apps[0];
        _inspector.Children.Add(Theme.Text(app.Name, 16, semibold: true));
        var path = Theme.Text(app.Path, 11, brush: "MoleTextSecondary", wrap: true);
        path.FontFamily = new FontFamily("Cascadia Mono");
        _inspector.Children.Add(path);
        if (!string.IsNullOrEmpty(app.Publisher))
        {
            _inspector.Children.Add(Theme.Text(app.Publisher, 12, brush: "MoleTextSecondary", wrap: true));
        }
        _inspector.Children.Add(Theme.Text("Related files", 12, medium: true, brush: "MoleTextSecondary"));
        if (!string.IsNullOrEmpty(app.RelatedExact))
        {
            _inspector.Children.Add(Theme.Text(
                $"{app.RelatedExact} · {app.SharedKept}",
                12,
                brush: "MoleTextSecondary",
                wrap: true));
        }
        foreach (var related in app.RelatedPaths)
        {
            var line = Theme.Text(related, 11, wrap: true);
            line.FontFamily = new FontFamily("Cascadia Mono");
            _inspector.Children.Add(line);
        }
        var review = new MoleButton("Review Uninstall…", MoleButtonKind.Primary)
        {
            HorizontalAlignment = HorizontalAlignment.Stretch,
            IsEnabled = app.Enabled
        };
        review.Click += (_, _) => ReviewUninstall?.Invoke(this, app);
        _inspector.Children.Add(review);
    }
}
