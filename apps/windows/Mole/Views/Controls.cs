using Microsoft.UI;
using Microsoft.UI.Text;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;

namespace Mole.Views;

public sealed class MoleButton : Button
{
    public MoleButton(string label, MoleButtonKind kind)
    {
        Content = label;
        Height = 32;
        MinWidth = 80;
        Padding = new Thickness(12, 0, 12, 0);
        CornerRadius = new CornerRadius(4);
        FontSize = 13;
        FontWeight = FontWeights.Medium;
        BorderThickness = new Thickness(kind == MoleButtonKind.Secondary ? 1 : 0);
        BorderBrush = Theme.Brush("MoleBorder");
        switch (kind)
        {
            case MoleButtonKind.Primary:
                Background = Theme.Brush("MoleBrand");
                Foreground = Theme.Brush("MoleOnBrand");
                BorderThickness = new Thickness(0);
                break;
            case MoleButtonKind.Secondary:
                Background = Theme.Brush("MoleRaised");
                Foreground = Theme.Brush("MoleTextPrimary");
                break;
            case MoleButtonKind.Quiet:
                Background = new SolidColorBrush(Colors.Transparent);
                Foreground = Theme.Brush("MoleBrand");
                BorderThickness = new Thickness(0);
                break;
            case MoleButtonKind.Danger:
                Background = Theme.Brush("MoleDanger");
                Foreground = Theme.Brush("MoleOnDanger");
                BorderThickness = new Thickness(0);
                break;
        }
    }
}

public sealed class MoleCheckbox : UserControl
{
    public event Action? Toggled;

    public MoleCheckbox(bool isOn, bool enabled = true)
    {
        Width = 20;
        Height = 20;
        IsEnabled = enabled;
        Opacity = enabled ? 1 : 0.45;
        var box = new Border
        {
            Width = 20,
            Height = 20,
            CornerRadius = new CornerRadius(4),
            BorderThickness = new Thickness(isOn ? 0 : 1),
            BorderBrush = Theme.Brush("MoleStrongBorder"),
            Background = isOn ? Theme.Brush("MoleBrand") : new SolidColorBrush(Colors.Transparent),
            Child = isOn
                ? new TextBlock
                {
                    Text = "✓",
                    FontSize = 11,
                    FontWeight = FontWeights.SemiBold,
                    Foreground = Theme.Brush("MoleOnBrand"),
                    HorizontalAlignment = HorizontalAlignment.Center,
                    VerticalAlignment = VerticalAlignment.Center
                }
                : null
        };
        Content = box;
        if (enabled)
        {
            PointerPressed += (_, _) => Toggled?.Invoke();
        }
    }
}

public sealed class StatusPill : UserControl
{
    public StatusPill(string label, PillTone tone)
    {
        var (fill, fg) = tone switch
        {
            PillTone.Success => ("MoleSuccessFill", "MoleSuccess"),
            PillTone.Review => ("MoleReviewFill", "MoleReview"),
            PillTone.Danger => ("MoleDangerFill", "MoleDanger"),
            _ => ("MoleRaised", "MoleTextSecondary")
        };
        Content = new Border
        {
            Background = Theme.Brush(fill),
            CornerRadius = new CornerRadius(4),
            Padding = new Thickness(8, 2, 8, 2),
            VerticalAlignment = VerticalAlignment.Center,
            Child = Theme.Text(label, 11, medium: true, brush: fg)
        };
    }
}

public sealed class SafetyBanner : UserControl
{
    public SafetyBanner(string message, PillTone tone = PillTone.Review)
    {
        var (fill, fg) = tone switch
        {
            PillTone.Success => ("MoleSuccessFill", "MoleSuccess"),
            PillTone.Danger => ("MoleDangerFill", "MoleDanger"),
            _ => ("MoleReviewFill", "MoleReview")
        };
        Content = new Border
        {
            Background = Theme.Brush(fill),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(12),
            HorizontalAlignment = HorizontalAlignment.Stretch,
            Child = Theme.Text(message, 13, brush: fg, wrap: true)
        };
    }
}

public sealed class SummaryPanel : UserControl
{
    public SummaryPanel(string kicker, string value, string hint, PillTone hintTone = PillTone.Neutral)
    {
        var hintBrush = hintTone switch
        {
            PillTone.Review => "MoleReview",
            PillTone.Danger => "MoleDanger",
            _ => "MoleTextSecondary"
        };
        var stack = new StackPanel { Spacing = 4 };
        stack.Children.Add(Theme.Text(kicker, 12, brush: "MoleTextSecondary"));
        stack.Children.Add(Theme.Text(value, 22, semibold: true));
        stack.Children.Add(Theme.Text(hint, 12, brush: hintBrush, wrap: true));
        Content = new Border
        {
            Background = Theme.Brush("MoleRaised"),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(16),
            BorderBrush = Theme.Brush("MoleBorder"),
            BorderThickness = new Thickness(1),
            Child = stack
        };
    }
}

public sealed class RecommendationRow : UserControl
{
    public event RoutedEventHandler? Activated;

    public RecommendationRow(string title)
    {
        var row = new Grid { Height = 44 };
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        var label = Theme.Text(title, 13, medium: true);
        var chevron = Theme.Text("›", 16, brush: "MoleTextSecondary");
        Grid.SetColumn(chevron, 1);
        row.Children.Add(label);
        row.Children.Add(chevron);
        Content = new Border
        {
            Padding = new Thickness(12, 0, 12, 0),
            CornerRadius = new CornerRadius(8),
            Child = row
        };
        PointerPressed += (s, e) => Activated?.Invoke(this, new RoutedEventArgs());
        PointerEntered += (_, _) => ((Border)Content).Background = Theme.Brush("MoleHover");
        PointerExited += (_, _) => ((Border)Content).Background = new SolidColorBrush(Colors.Transparent);
    }
}

public sealed class ActivityRow : UserControl
{
    public ActivityRow(string command, string detail, string time)
    {
        var grid = new Grid { Height = 48 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(120) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        var cmd = Theme.Text(command, 13, medium: true);
        var det = Theme.Text(detail, 13, brush: "MoleTextSecondary");
        var t = Theme.Text(time, 12, brush: "MoleTextSecondary");
        Grid.SetColumn(det, 1);
        Grid.SetColumn(t, 2);
        grid.Children.Add(cmd);
        grid.Children.Add(det);
        grid.Children.Add(t);
        Content = grid;
    }
}

public sealed class CandidateRow : UserControl
{
    public event Action? Toggled;

    public CandidateRow(
        string name,
        string items,
        string size,
        string state,
        bool isOn,
        bool enabled,
        PillTone sizeTone = PillTone.Neutral,
        PillTone stateTone = PillTone.Neutral)
    {
        var grid = new Grid { Height = 48 };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(32) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(64) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(88) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(120) });

        var check = new MoleCheckbox(isOn, enabled);
        check.Toggled += () => Toggled?.Invoke();
        check.VerticalAlignment = VerticalAlignment.Center;

        var nameText = Theme.Text(name, 13, medium: true);
        nameText.Opacity = enabled ? 1 : 0.55;
        Grid.SetColumn(nameText, 1);

        var itemsText = Theme.Text(items, 13, brush: "MoleTextSecondary");
        itemsText.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(itemsText, 2);

        var sizeText = Theme.Text(
            size,
            13,
            medium: true,
            brush: sizeTone == PillTone.Review ? "MoleReview" : "MoleTextPrimary");
        sizeText.HorizontalAlignment = HorizontalAlignment.Right;
        Grid.SetColumn(sizeText, 3);

        var pill = new StatusPill(state, stateTone) { HorizontalAlignment = HorizontalAlignment.Left };
        Grid.SetColumn(pill, 4);

        grid.Children.Add(check);
        grid.Children.Add(nameText);
        grid.Children.Add(itemsText);
        grid.Children.Add(sizeText);
        grid.Children.Add(pill);

        Content = new Border
        {
            Background = isOn ? Theme.Brush("MoleSelected") : new SolidColorBrush(Colors.Transparent),
            CornerRadius = new CornerRadius(8),
            Padding = new Thickness(8, 0, 8, 0),
            Opacity = enabled ? 1 : 0.7,
            Child = grid
        };
    }
}

public sealed class FilterChip : UserControl
{
    public event RoutedEventHandler? Activated;

    public FilterChip(string label, bool active)
    {
        var text = Theme.Text(label, 13, medium: true, brush: active ? "MoleBrand" : "MoleTextSecondary");
        Content = new Border
        {
            Background = active ? Theme.Brush("MoleSelected") : new SolidColorBrush(Colors.Transparent),
            CornerRadius = new CornerRadius(16),
            Padding = new Thickness(14, 0, 14, 0),
            Height = 32,
            Child = text
        };
        PointerPressed += (s, e) => Activated?.Invoke(this, new RoutedEventArgs());
    }
}

public sealed class ConfirmCard : UserControl
{
    public ConfirmCard(UIElement body)
    {
        Content = new Border
        {
            Width = 480,
            Background = Theme.Brush("MoleCanvas"),
            CornerRadius = new CornerRadius(8),
            BorderBrush = Theme.Brush("MoleBorder"),
            BorderThickness = new Thickness(1),
            Padding = new Thickness(24),
            Child = body
        };
    }
}

internal static class Layout
{
    public static Grid Columns(params (GridLength width, UIElement el)[] cells)
    {
        var grid = new Grid();
        for (var i = 0; i < cells.Length; i++)
        {
            grid.ColumnDefinitions.Add(new ColumnDefinition { Width = cells[i].width });
            Grid.SetColumn(cells[i].el, i);
            grid.Children.Add(cells[i].el);
        }
        return grid;
    }

    public static StackPanel Column(double gap, params UIElement[] children)
    {
        var stack = new StackPanel { Spacing = gap };
        foreach (var child in children)
        {
            stack.Children.Add(child);
        }
        return stack;
    }

    public static StackPanel Row(double gap, params UIElement[] children)
    {
        var stack = new StackPanel { Orientation = Orientation.Horizontal, Spacing = gap, VerticalAlignment = VerticalAlignment.Center };
        foreach (var child in children)
        {
            stack.Children.Add(child);
        }
        return stack;
    }
}
