using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using Mole.Engine;

namespace Mole.Views;

public sealed class HistoryPage : UserControl
{
    private string _tab = "Sessions";
    private string? _selectedId = "clean-1";
    private readonly StackPanel _table = new();
    private readonly StackPanel _chips = new() { Orientation = Orientation.Horizontal, Spacing = 8 };
    private readonly TextBlock _note;
    private readonly TextBlock _title;

    public HistoryPage()
    {
        _title = Theme.Text("History", 24, semibold: true);
        _note = Theme.Text(Note(), 12, brush: "MoleTextSecondary", wrap: true);
        RebuildChips();
        RebuildTable();

        Content = new ScrollViewer
        {
            Padding = new Thickness(20),
            Content = Layout.Column(16, _title, _chips, _table, _note)
        };
    }

    private string Note() => _tab == "Sessions"
        ? "History is read-only. Recycle Bin items can be restored in File Explorer. Permanent removals cannot."
        : "Read-only audit. Recycle Bin items can be restored in File Explorer. Permanent removals cannot.";

    private void RebuildChips()
    {
        _chips.Children.Clear();
        foreach (var label in new[] { "Sessions", "Deletion audit" })
        {
            var chip = new FilterChip(label, _tab == label);
            var captured = label;
            chip.Activated += (_, _) =>
            {
                _tab = captured;
                _selectedId = _tab == "Sessions" ? "clean-1" : Fixtures.HistoryAudit[0].Id;
                _title.Text = _tab == "Sessions" ? "History" : "Deletion audit";
                RebuildChips();
                RebuildTable();
                _note.Text = Note();
            };
            _chips.Children.Add(chip);
        }
    }

    private void RebuildTable()
    {
        _table.Children.Clear();
        if (_tab == "Sessions")
        {
            _table.Children.Add(SessionHeader());
            foreach (var row in Fixtures.History)
            {
                _table.Children.Add(SessionRow(row));
            }
            return;
        }
        _table.Children.Add(AuditHeader());
        foreach (var row in Fixtures.HistoryAudit)
        {
            _table.Children.Add(AuditRow(row));
        }
    }

    private static UIElement SessionHeader()
    {
        var grid = new Grid { Height = 36 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(160) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(160) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(80) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(100) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        AddHeader(grid, 0, "Command");
        AddHeader(grid, 1, "Started");
        AddHeader(grid, 2, "Items");
        AddHeader(grid, 3, "Size");
        AddHeader(grid, 4, "Outcome");
        return new Border { Padding = new Thickness(8, 0, 8, 0), Child = grid };
    }

    private UIElement SessionRow(HistorySession row)
    {
        var selected = row.Id == _selectedId;
        var grid = new Grid { Height = 48 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(160) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(160) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(80) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(100) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.Children.Add(Theme.Text(row.Command, 13, medium: true));
        var started = Theme.Text(row.Started, 12, brush: "MoleTextSecondary");
        Grid.SetColumn(started, 1);
        var items = Theme.Text(row.Items, 13);
        Grid.SetColumn(items, 2);
        var size = Theme.Text(row.Size, 13, medium: true);
        Grid.SetColumn(size, 3);
        var tone = row.Outcome is "Completed with skips" or "2 skipped" ? PillTone.Review
            : row.Outcome == "Permanent" ? PillTone.Danger
            : PillTone.Success;
        var pill = new StatusPill(row.Outcome, tone);
        Grid.SetColumn(pill, 4);
        grid.Children.Add(started);
        grid.Children.Add(items);
        grid.Children.Add(size);
        grid.Children.Add(pill);
        var border = new Border
        {
            Background = selected ? Theme.Brush("MoleSelected") : Theme.Brush("MoleCanvas"),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(8, 0, 8, 0),
            BorderBrush = selected ? Theme.Brush("MoleBorder") : new SolidColorBrush(Microsoft.UI.Colors.Transparent),
            BorderThickness = new Thickness(selected ? 1 : 0),
            Child = grid
        };
        border.PointerPressed += (_, _) =>
        {
            _selectedId = row.Id;
            RebuildTable();
        };
        return border;
    }

    private static UIElement AuditHeader()
    {
        var grid = new Grid { Height = 36 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(150) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(110) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(120) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(80) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        AddHeader(grid, 0, "Timestamp");
        AddHeader(grid, 1, "Mode");
        AddHeader(grid, 2, "Status");
        AddHeader(grid, 3, "Size");
        AddHeader(grid, 4, "Path");
        return new Border { Padding = new Thickness(8, 0, 8, 0), Child = grid };
    }

    private UIElement AuditRow(HistoryAuditRow row)
    {
        var selected = row.Id == _selectedId;
        var grid = new Grid { Height = 48 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(150) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(110) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(120) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(80) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.Children.Add(Theme.Text(row.Timestamp, 12, brush: "MoleTextSecondary"));
        var mode = new StatusPill(row.Mode, row.ModePermanent ? PillTone.Danger : PillTone.Success);
        Grid.SetColumn(mode, 1);
        var statusTone = row.StatusDanger ? PillTone.Danger : row.StatusReview ? PillTone.Review : PillTone.Success;
        var status = new StatusPill(row.Status, statusTone);
        Grid.SetColumn(status, 2);
        var size = Theme.Text(row.Size, 13, medium: true);
        Grid.SetColumn(size, 3);
        var path = Theme.Text(row.Path, 11, wrap: true);
        path.FontFamily = new FontFamily("Cascadia Mono");
        Grid.SetColumn(path, 4);
        grid.Children.Add(mode);
        grid.Children.Add(status);
        grid.Children.Add(size);
        grid.Children.Add(path);
        var border = new Border
        {
            Background = selected ? Theme.Brush("MoleSelected") : Theme.Brush("MoleCanvas"),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(8, 0, 8, 0),
            Child = grid
        };
        border.PointerPressed += (_, _) =>
        {
            _selectedId = row.Id;
            RebuildTable();
        };
        return border;
    }

    private static void AddHeader(Grid grid, int column, string label)
    {
        var text = Theme.Text(label, 12, medium: true, brush: "MoleTextSecondary");
        Grid.SetColumn(text, column);
        grid.Children.Add(text);
    }
}
