using Microsoft.UI.Text;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Shapes;

namespace Mole.Views;

internal static class Theme
{
    public static Brush Brush(string key) =>
        (Brush)Application.Current.Resources[key];

    public static TextBlock Text(
        string value,
        double size,
        bool medium = false,
        bool semibold = false,
        string brush = "MoleTextPrimary",
        bool wrap = false)
    {
        return new TextBlock
        {
            Text = value,
            FontSize = size,
            FontWeight = semibold ? FontWeights.SemiBold : medium ? FontWeights.Medium : FontWeights.Normal,
            Foreground = Brush(brush),
            TextWrapping = wrap ? TextWrapping.Wrap : TextWrapping.NoWrap,
            VerticalAlignment = VerticalAlignment.Center
        };
    }

    public static Border Hairline() => new()
    {
        Height = 1,
        Background = Brush("MoleBorder")
    };

    public static Rectangle VLine() => new()
    {
        Width = 1,
        Fill = Brush("MoleBorder")
    };
}

public enum PillTone
{
    Neutral,
    Success,
    Review,
    Danger
}

public enum MoleButtonKind
{
    Primary,
    Secondary,
    Quiet,
    Danger
}
