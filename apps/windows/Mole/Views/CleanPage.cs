using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Mole.Engine;

namespace Mole.Views;

public sealed class CleanPage : UserControl
{
    public event EventHandler? Review;
    public event EventHandler? Protect;

    private readonly List<CleanCategory> _categories = [.. Fixtures.Clean];
    private readonly StackPanel _rows = new();
    private readonly TextBlock _footer;

    public CleanPage()
    {
        _footer = Theme.Text(FooterLabel(), 13, medium: true);

        var header = new Grid();
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        header.Children.Add(Theme.Text("Clean", 24, semibold: true));
        var meta = Layout.Row(12,
            Theme.Text("4.8 GB measured", 13, medium: true),
            Theme.Text("12 categories ready", 13, brush: "MoleTextSecondary"),
            new StatusPill("2 need review", PillTone.Review));
        Grid.SetColumn(meta, 1);
        header.Children.Add(meta);

        var tableHeader = CandidateHeader();
        RebuildRows();

        var table = Layout.Column(0, tableHeader, _rows);

        var protect = new MoleButton("Protect…", MoleButtonKind.Secondary);
        protect.Click += (_, _) => Protect?.Invoke(this, EventArgs.Empty);
        var review = new MoleButton("Review Cleanup…", MoleButtonKind.Primary);
        review.Click += (_, _) => Review?.Invoke(this, EventArgs.Empty);

        var footer = new Grid { Height = 56 };
        footer.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        footer.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        footer.Children.Add(_footer);
        var actions = Layout.Row(8, protect, review);
        Grid.SetColumn(actions, 1);
        footer.Children.Add(actions);

        var root = new Grid();
        root.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
        root.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        var top = Layout.Column(16, header, table);
        top.Padding = new Thickness(20, 20, 20, 0);
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

    private void RebuildRows()
    {
        _rows.Children.Clear();
        for (var i = 0; i < _categories.Count; i++)
        {
            var index = i;
            var row = _categories[i];
            var stateTone = row.StateDanger ? PillTone.Danger
                : row.StateReview || row.State is "App running" or "Partial" ? PillTone.Review
                : row.State == "Ready" ? PillTone.Success
                : PillTone.Neutral;
            var sizeTone = row.SizeReview ? PillTone.Review : PillTone.Neutral;
            var candidate = new CandidateRow(
                row.Name, row.Items, row.Size, row.State, row.Selected, row.Enabled, sizeTone, stateTone);
            candidate.Toggled += () =>
            {
                if (!_categories[index].Enabled)
                {
                    return;
                }
                _categories[index] = _categories[index] with { Selected = !_categories[index].Selected };
                RebuildRows();
                _footer.Text = FooterLabel();
            };
            _rows.Children.Add(candidate);
        }
    }

    private string FooterLabel()
    {
        var selected = _categories.Where(c => c.Selected).ToList();
        var ids = selected.Select(c => c.Id).ToHashSet();
        if (ids.SetEquals(["app-caches", "browsers", "installers"]))
        {
            return "3 selected · 3.5 GB measured";
        }
        return $"{selected.Count} selected";
    }

    private static UIElement CandidateHeader()
    {
        var grid = new Grid { Height = 32 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(32) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(64) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(88) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(120) });
        var category = Theme.Text("Category", 12, medium: true, brush: "MoleTextSecondary");
        Grid.SetColumn(category, 1);
        var items = Theme.Text("Items", 12, medium: true, brush: "MoleTextSecondary");
        items.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(items, 2);
        var size = Theme.Text("Size", 12, medium: true, brush: "MoleTextSecondary");
        size.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(size, 3);
        var state = Theme.Text("State", 12, medium: true, brush: "MoleTextSecondary");
        Grid.SetColumn(state, 4);
        grid.Children.Add(category);
        grid.Children.Add(items);
        grid.Children.Add(size);
        grid.Children.Add(state);
        return new Border { Padding = new Thickness(8, 0, 8, 0), Child = grid };
    }
}

public sealed class CleanReviewPage : UserControl
{
    public event EventHandler? Back;
    public event EventHandler? Confirm;

    public CleanReviewPage()
    {
        var header = new Grid();
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        header.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        header.Children.Add(Theme.Text("Review cleanup", 24, semibold: true));
        var back = new MoleButton("Back", MoleButtonKind.Secondary);
        back.Click += (_, _) => Back?.Invoke(this, EventArgs.Empty);
        var confirm = new MoleButton("Remove permanently", MoleButtonKind.Primary);
        confirm.Click += (_, _) => Confirm?.Invoke(this, EventArgs.Empty);
        var actions = Layout.Row(8, back, confirm);
        Grid.SetColumn(actions, 1);
        header.Children.Add(actions);

        var banner = new SafetyBanner(
            "12 items · 3.5 GB measured · Remove permanently · 1 item needs elevation after confirm",
            PillTone.Review);

        var table = new StackPanel();
        table.Children.Add(ReviewHeader());
        foreach (var item in Fixtures.CleanReview)
        {
            table.Children.Add(ReviewRow(item));
        }

        var note = Theme.Text(
            "Protected items stay unchecked. Windows Hello is requested only after this plan is confirmed.",
            12,
            brush: "MoleTextSecondary",
            wrap: true);

        Content = new ScrollViewer
        {
            Padding = new Thickness(20),
            Content = Layout.Column(16, header, banner, table, note)
        };
    }

    private static UIElement ReviewHeader()
    {
        var grid = new Grid { Height = 32 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(88) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(120) });
        grid.Children.Add(Theme.Text("Path", 12, medium: true, brush: "MoleTextSecondary"));
        var size = Theme.Text("Size", 12, medium: true, brush: "MoleTextSecondary");
        size.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(size, 1);
        var status = Theme.Text("Status", 12, medium: true, brush: "MoleTextSecondary");
        Grid.SetColumn(status, 2);
        grid.Children.Add(size);
        grid.Children.Add(status);
        return grid;
    }

    private static UIElement ReviewRow(CleanReviewItem item)
    {
        var grid = new Grid { Height = 48 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(32) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(88) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(120) });
        var check = new MoleCheckbox(item.Selected, item.Enabled);
        var path = Theme.Text(item.Path, 12, wrap: true);
        path.FontFamily = new Microsoft.UI.Xaml.Media.FontFamily("Cascadia Mono");
        Grid.SetColumn(path, 1);
        var size = Theme.Text(
            item.Size,
            13,
            medium: true,
            brush: item.SizeReview ? "MoleReview" : "MoleTextPrimary");
        size.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(size, 2);
        var tone = item.Protected ? PillTone.Danger
            : item.StateReview || item.State == "Partial" ? PillTone.Review
            : item.State == "Ready" ? PillTone.Success
            : PillTone.Neutral;
        var pill = new StatusPill(item.State, tone);
        Grid.SetColumn(pill, 3);
        grid.Children.Add(check);
        grid.Children.Add(path);
        grid.Children.Add(size);
        grid.Children.Add(pill);
        return new Border
        {
            Background = item.Selected ? Theme.Brush("MoleSelected") : Theme.Brush("MoleCanvas"),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(8, 0, 8, 0),
            Child = grid
        };
    }
}
