using Microsoft.UI;
using Microsoft.UI.Text;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Shapes;

namespace Mole.Views;

public sealed class NavButton : Button
{
    public static readonly DependencyProperty LabelProperty = DependencyProperty.Register(
        nameof(Label), typeof(string), typeof(NavButton), new PropertyMetadata("", OnChanged));

    public static readonly DependencyProperty IsCurrentProperty = DependencyProperty.Register(
        nameof(IsCurrent), typeof(bool), typeof(NavButton), new PropertyMetadata(false, OnChanged));

    private readonly Rectangle _bar = new()
    {
        Width = 3,
        HorizontalAlignment = HorizontalAlignment.Left,
        VerticalAlignment = VerticalAlignment.Stretch
    };

    private readonly TextBlock _label = new()
    {
        FontSize = 13,
        Margin = new Thickness(16, 0, 12, 0),
        VerticalAlignment = VerticalAlignment.Center
    };

    public NavButton()
    {
        Height = 40;
        HorizontalAlignment = HorizontalAlignment.Stretch;
        HorizontalContentAlignment = HorizontalAlignment.Stretch;
        Padding = new Thickness(0);
        BorderThickness = new Thickness(0);
        CornerRadius = new CornerRadius(4);
        Background = new SolidColorBrush(Colors.Transparent);

        var grid = new Grid();
        grid.Children.Add(_bar);
        grid.Children.Add(_label);
        Content = grid;
        Loaded += (_, _) => Apply();
    }

    public string Label
    {
        get => (string)GetValue(LabelProperty);
        set => SetValue(LabelProperty, value);
    }

    public bool IsCurrent
    {
        get => (bool)GetValue(IsCurrentProperty);
        set => SetValue(IsCurrentProperty, value);
    }

    private static void OnChanged(DependencyObject d, DependencyPropertyChangedEventArgs e) =>
        ((NavButton)d).Apply();

    private void Apply()
    {
        _label.Text = Label;
        _label.FontWeight = IsCurrent ? FontWeights.SemiBold : FontWeights.Medium;
        _label.Foreground = Theme.Brush(IsCurrent ? "MoleTextPrimary" : "MoleTextSecondary");
        _bar.Fill = IsCurrent ? Theme.Brush("MoleBrand") : new SolidColorBrush(Colors.Transparent);
        Background = IsCurrent ? Theme.Brush("MoleSelected") : new SolidColorBrush(Colors.Transparent);
    }
}
