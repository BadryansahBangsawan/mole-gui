using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Mole.Engine;

namespace Mole.Views;

public sealed class ProjectsPage : UserControl
{
    public event EventHandler? Review;

    private readonly List<ProjectGroup> _groups;
    private string _filter = "*";
    private readonly StackPanel _list = new() { Spacing = 16 };
    private readonly StackPanel _filters = new() { Orientation = Orientation.Horizontal, Spacing = 8 };
    private readonly TextBlock _footer;

    public ProjectsPage()
    {
        _groups = Fixtures.Projects.Select(g => g with { Artifacts = g.Artifacts.ToList() }).ToList();
        _footer = Theme.Text(FooterLabel(), 13, medium: true);

        var review = new MoleButton("Review Purge…", MoleButtonKind.Danger);
        review.Click += (_, _) => Review?.Invoke(this, EventArgs.Empty);

        var footer = new Grid { Height = 56 };
        footer.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        footer.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        footer.Children.Add(_footer);
        Grid.SetColumn(review, 1);
        footer.Children.Add(review);

        RebuildFilters();
        Rebuild();

        var top = Layout.Column(16,
            Theme.Text("Projects", 24, semibold: true),
            new SafetyBanner(
                "Project purge is permanent. Selected artifacts cannot be restored from Recycle Bin.",
                PillTone.Danger),
            _filters,
            _list);
        top.Padding = new Thickness(20, 20, 20, 0);

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

    private void RebuildFilters()
    {
        _filters.Children.Clear();
        foreach (var label in new[] { "Selected", "Old", "Recent", "Could not inspect", "Protected" })
        {
            var chip = new FilterChip(label, _filter == label);
            var captured = label;
            chip.Activated += (_, _) =>
            {
                _filter = captured;
                RebuildFilters();
                Rebuild();
            };
            _filters.Children.Add(chip);
        }
    }

    private void Rebuild()
    {
        _list.Children.Clear();
        foreach (var group in _groups)
        {
            var artifacts = group.Artifacts.Where(Matches).ToList();
            if (artifacts.Count == 0)
            {
                continue;
            }
            var block = new StackPanel { Spacing = 4 };
            var heading = new Grid();
            heading.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            heading.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
            var path = Theme.Text(group.Path, 12, brush: "MoleTextSecondary", wrap: true);
            path.FontFamily = new Microsoft.UI.Xaml.Media.FontFamily("Cascadia Mono");
            heading.Children.Add(path);
            var size = Theme.Text(group.Size, 12, medium: true, brush: "MoleTextSecondary");
            Grid.SetColumn(size, 1);
            heading.Children.Add(size);
            block.Children.Add(heading);
            foreach (var artifact in artifacts)
            {
                block.Children.Add(ArtifactRow(group.Id, artifact));
            }
            _list.Children.Add(block);
        }
        _footer.Text = FooterLabel();
    }

    private bool Matches(ProjectArtifact artifact) => _filter switch
    {
        "*" => true,
        "Selected" => artifact.Selected,
        "Old" => artifact.Age == "Old",
        "Recent" => artifact.Age == "Recent",
        "Could not inspect" => artifact.Age is "Unknown" or "Could not inspect",
        "Protected" => artifact.Protected,
        _ => true
    };

    private UIElement ArtifactRow(string groupId, ProjectArtifact artifact)
    {
        var grid = new Grid { Height = 44 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(32) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(88) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(120) });
        var check = new MoleCheckbox(artifact.Selected, artifact.Enabled);
        check.Toggled += () => Toggle(groupId, artifact.Id);
        var name = Theme.Text(artifact.Name, 13, medium: true);
        Grid.SetColumn(name, 1);
        var size = Theme.Text(artifact.Size, 13, medium: true);
        size.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(size, 2);
        var tone = artifact.Protected ? PillTone.Danger
            : artifact.Age == "Recent" ? PillTone.Review
            : artifact.Age == "Old" ? PillTone.Success
            : PillTone.Neutral;
        var pill = new StatusPill(artifact.Age, tone);
        Grid.SetColumn(pill, 3);
        grid.Children.Add(check);
        grid.Children.Add(name);
        grid.Children.Add(size);
        grid.Children.Add(pill);
        return new Border
        {
            Background = artifact.Selected ? Theme.Brush("MoleSelected") : Theme.Brush("MoleCanvas"),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(8, 0, 8, 0),
            Opacity = artifact.Enabled ? 1 : 0.7,
            Child = grid
        };
    }

    private void Toggle(string groupId, string artifactId)
    {
        for (var g = 0; g < _groups.Count; g++)
        {
            if (_groups[g].Id != groupId)
            {
                continue;
            }
            var arts = _groups[g].Artifacts.ToList();
            for (var i = 0; i < arts.Count; i++)
            {
                if (arts[i].Id == artifactId && arts[i].Enabled)
                {
                    arts[i] = arts[i] with { Selected = !arts[i].Selected };
                }
            }
            _groups[g] = _groups[g] with { Artifacts = arts };
        }
        Rebuild();
    }

    private string FooterLabel()
    {
        var selected = _groups.SelectMany(g => g.Artifacts).Where(a => a.Selected).ToList();
        return selected.Count == 2
            ? "2 selected · 6.00 GB estimated · permanent"
            : $"{selected.Count} selected · permanent";
    }
}
