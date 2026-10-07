using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Mole.Engine;

namespace Mole.Views;

public sealed class MaintenancePage : UserControl
{
    public event EventHandler? Review;

    private readonly List<MaintenanceSection> _sections;
    private readonly StackPanel _list = new();
    private readonly TextBlock _footer;

    public MaintenancePage()
    {
        _sections = Fixtures.Maintenance
            .Select(s => s with { Tasks = s.Tasks.ToList() })
            .ToList();
        _footer = Theme.Text(FooterLabel(), 13, medium: true);

        var review = new MoleButton("Review Maintenance…", MoleButtonKind.Primary);
        review.Click += (_, _) => Review?.Invoke(this, EventArgs.Empty);

        Rebuild();

        var top = Layout.Column(16,
            Layout.Column(8,
                Theme.Text("Maintenance", 24, semibold: true),
                Theme.Text(
                    "Bounded tasks with a skip reason. No “speed up my PC” claim.",
                    13,
                    brush: "MoleTextSecondary",
                    wrap: true)),
            _list);
        top.Padding = new Thickness(20, 20, 20, 0);

        var footer = new Grid { Height = 56 };
        footer.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        footer.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        footer.Children.Add(_footer);
        Grid.SetColumn(review, 1);
        footer.Children.Add(review);

        var root = new Grid();
        root.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
        root.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        root.Children.Add(new ScrollViewer { Content = top });
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

    private void Rebuild()
    {
        _list.Children.Clear();
        foreach (var section in _sections)
        {
            var heading = Theme.Text(section.Title, 12, semibold: true, brush: "MoleTextSecondary");
            heading.Margin = new Thickness(8, 12, 8, 4);
            _list.Children.Add(heading);
            foreach (var task in section.Tasks)
            {
                _list.Children.Add(TaskRow(section.Id, task));
            }
        }
        _footer.Text = FooterLabel();
    }

    private UIElement TaskRow(string sectionId, MaintenanceTask task)
    {
        var grid = new Grid { Height = 52 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(32) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        var check = new MoleCheckbox(task.Selected, task.Enabled);
        check.Toggled += () => Toggle(sectionId, task.Id);
        var copy = Layout.Column(2,
            Theme.Text(task.Name, 13, medium: true),
            Theme.Text(task.Effect, 12, brush: "MoleTextSecondary"));
        Grid.SetColumn(copy, 1);
        var tone = task.Danger ? PillTone.Danger
            : task.Review || task.State is "Needs Hello" or "App running" or "On battery" ? PillTone.Review
            : task.State == "Ready" ? PillTone.Success
            : PillTone.Neutral;
        var pill = new StatusPill(task.State, tone);
        Grid.SetColumn(pill, 2);
        grid.Children.Add(check);
        grid.Children.Add(copy);
        grid.Children.Add(pill);
        return new Border
        {
            Background = task.Selected ? Theme.Brush("MoleSelected") : Theme.Brush("MoleCanvas"),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(8, 0, 8, 0),
            Opacity = task.Enabled ? 1 : 0.7,
            Child = grid
        };
    }

    private void Toggle(string sectionId, string taskId)
    {
        for (var s = 0; s < _sections.Count; s++)
        {
            if (_sections[s].Id != sectionId)
            {
                continue;
            }
            var tasks = _sections[s].Tasks.ToList();
            for (var i = 0; i < tasks.Count; i++)
            {
                if (tasks[i].Id == taskId && tasks[i].Enabled)
                {
                    tasks[i] = tasks[i] with { Selected = !tasks[i].Selected };
                }
            }
            _sections[s] = _sections[s] with { Tasks = tasks };
        }
        Rebuild();
    }

    private string FooterLabel()
    {
        var tasks = _sections.SelectMany(s => s.Tasks).ToList();
        var selected = tasks.Count(t => t.Selected);
        var hello = tasks.Count(t => t.State == "Needs Hello" && t.Selected);
        return hello > 0
            ? $"{selected} selected · {hello} needs Windows Hello"
            : $"{selected} selected";
    }
}
