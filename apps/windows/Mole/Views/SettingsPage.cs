using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Mole.Engine;

namespace Mole.Views;

public sealed class SettingsPage : UserControl
{
    public SettingsPage()
    {
        var body = new StackPanel { Spacing = 20 };
        foreach (var section in Fixtures.Settings)
        {
            var block = new StackPanel { Spacing = 8 };
            block.Children.Add(Theme.Text(section.Title, 12, medium: true, brush: "MoleTextSecondary"));
            var rows = new StackPanel();
            foreach (var row in section.Rows)
            {
                rows.Children.Add(SettingsLine(row));
            }
            block.Children.Add(rows);
            body.Children.Add(block);
        }

        Content = new ScrollViewer
        {
            Padding = new Thickness(20),
            Content = body
        };
    }

    private static UIElement SettingsLine(SettingsRow row)
    {
        var grid = new Grid { Height = 36, Padding = new Thickness(0, 4, 0, 4) };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(220) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        var title = Theme.Text(row.Title, 13, medium: true, brush: row.Danger ? "MoleDanger" : "MoleTextPrimary");
        var value = Theme.Text(row.Value, row.Id == "rel" ? 12 : 13, brush: "MoleTextSecondary", wrap: true);
        value.HorizontalAlignment = HorizontalAlignment.Right;
        value.TextAlignment = Microsoft.UI.Xaml.TextAlignment.Right;
        Grid.SetColumn(value, 1);
        grid.Children.Add(title);
        grid.Children.Add(value);
        return grid;
    }
}
