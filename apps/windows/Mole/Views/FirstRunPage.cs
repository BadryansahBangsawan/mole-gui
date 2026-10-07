using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace Mole.Views;

public sealed class FirstRunPage : UserControl
{
    public event EventHandler? Continue;
    public event EventHandler? Quit;

    public FirstRunPage()
    {
        var quit = new MoleButton("Quit", MoleButtonKind.Secondary);
        quit.Click += (_, _) => Quit?.Invoke(this, EventArgs.Empty);
        var cont = new MoleButton("Continue", MoleButtonKind.Primary);
        cont.Click += (_, _) => Continue?.Invoke(this, EventArgs.Empty);

        var actions = new Grid { Margin = new Thickness(0, 24, 0, 0) };
        actions.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        actions.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        actions.Children.Add(quit);
        var contWrap = new StackPanel { HorizontalAlignment = HorizontalAlignment.Right };
        contWrap.Children.Add(cont);
        Grid.SetColumn(contWrap, 1);
        actions.Children.Add(contWrap);

        var card = Layout.Column(12,
            Theme.Text("Mole for Windows", 24, semibold: true),
            Theme.Text(
                "A companion for the open-source Mole CLI. It plans cleanups, then asks you to confirm before anything is moved.",
                13,
                brush: "MoleTextSecondary",
                wrap: true),
            Theme.Text(
                "Mole launches as a regular user. Windows Hello or elevation is requested only after you confirm a plan that needs it.",
                13,
                wrap: true),
            Theme.Text(
                "There is no Full Disk Access prompt on Windows. Protected locations stay listed as Protected or Unknown until they can be measured.",
                13,
                wrap: true),
            Theme.Text(
                "Clean removes rebuildable caches permanently; they will not appear in Recycle Bin. Uninstall and Disk Explorer still use Recycle Bin. Project purge is permanent.",
                13,
                wrap: true),
            actions);

        var frame = new Border
        {
            Width = 560,
            Background = Theme.Brush("MoleCanvas"),
            CornerRadius = new CornerRadius(8),
            BorderBrush = Theme.Brush("MoleBorder"),
            BorderThickness = new Thickness(1),
            Padding = new Thickness(32),
            Child = card,
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center
        };

        Content = new Grid
        {
            Background = Theme.Brush("MoleRaised"),
            Children = { frame }
        };
    }
}
