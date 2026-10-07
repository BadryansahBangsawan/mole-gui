using Microsoft.UI;
using Microsoft.UI.Windowing;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Mole.Engine;
using Mole.Views;
using WinRT.Interop;

namespace Mole;

public sealed partial class MainWindow : Window
{
    private MoleDestination _destination = MoleDestination.Overview;
    private readonly Dictionary<MoleDestination, UserControl> _pages = [];

    public MainWindow()
    {
        InitializeComponent();
        ExtendsContentIntoTitleBar = true;
        SetTitleBar(AppTitleBar);
        TrySize();
        Navigate(MoleDestination.Overview);
    }

    private void TrySize()
    {
        var hwnd = WindowNative.GetWindowHandle(this);
        var id = Win32Interop.GetWindowIdFromWindow(hwnd);
        var appWindow = AppWindow.GetFromWindowId(id);
        appWindow.Resize(new Windows.Graphics.SizeInt32(1220, 780));
    }

    private void OnNav(object sender, RoutedEventArgs e)
    {
        if (sender is FrameworkElement { Tag: string tag } &&
            Enum.TryParse<MoleDestination>(tag, out var dest))
        {
            Navigate(dest);
        }
    }

    private void Navigate(MoleDestination dest)
    {
        _destination = dest;
        ToolbarTitle.Text = dest switch
        {
            MoleDestination.DiskExplorer => "Disk Explorer",
            MoleDestination.FirstRun => "Welcome",
            _ => dest.ToString()
        };
        HighlightNav();
        if (!_pages.TryGetValue(dest, out var page))
        {
            page = CreatePage(dest);
            _pages[dest] = page;
        }
        PageHost.Content = page;
        BuildToolbar();
    }

    private UserControl CreatePage(MoleDestination dest) => dest switch
    {
        MoleDestination.Overview => BindOverview(),
        MoleDestination.Clean => BindClean(),
        MoleDestination.Applications => BindApplications(),
        MoleDestination.DiskExplorer => new DiskExplorerPage(),
        MoleDestination.Projects => BindProjects(),
        MoleDestination.Maintenance => BindMaintenance(),
        MoleDestination.History => new HistoryPage(),
        MoleDestination.Settings => new SettingsPage(),
        MoleDestination.FirstRun => BindFirstRun(),
        _ => new OverviewPage()
    };

    private OverviewPage BindOverview()
    {
        var page = new OverviewPage();
        page.NavigateTo += (_, d) => Navigate(d);
        page.ViewHistory += (_, _) => Navigate(MoleDestination.History);
        return page;
    }

    private CleanPage BindClean()
    {
        var page = new CleanPage();
        page.Review += (_, _) => ShowCleanReview();
        page.Protect += (_, _) => Navigate(MoleDestination.Settings);
        return page;
    }

    private ApplicationsPage BindApplications()
    {
        var page = new ApplicationsPage();
        page.ReviewUninstall += (_, _) => ShowDialog(new ConfirmRecycleCard());
        return page;
    }

    private ProjectsPage BindProjects()
    {
        var page = new ProjectsPage();
        page.Review += (_, _) => ShowDialog(new ConfirmPermanentCard());
        return page;
    }

    private MaintenancePage BindMaintenance()
    {
        var page = new MaintenancePage();
        page.Review += (_, _) => { };
        return page;
    }

    private FirstRunPage BindFirstRun()
    {
        var page = new FirstRunPage();
        page.Continue += (_, _) => Navigate(MoleDestination.Overview);
        page.Quit += (_, _) => Close();
        return page;
    }

    private void ShowCleanReview()
    {
        var review = new CleanReviewPage();
        review.Back += (_, _) =>
        {
            PageHost.Content = _pages[MoleDestination.Clean];
            BuildToolbar();
        };
        review.Confirm += (_, _) => ShowDialog(new ConfirmRebuildableCard());
        PageHost.Content = review;
        ToolbarTitle.Text = "Review cleanup";
        ToolbarTrailing.Children.Clear();
    }

    private void ShowScan()
    {
        var scan = new ScanInProgressPage();
        scan.Stop += (_, _) =>
        {
            PageHost.Content = _pages[MoleDestination.Clean];
            BuildToolbar();
        };
        PageHost.Content = scan;
        ToolbarTitle.Text = "Clean";
        ToolbarTrailing.Children.Clear();
    }

    private void ShowDialog(UserControl card)
    {
        switch (card)
        {
            case ConfirmRecycleCard recycle:
                recycle.Cancel += (_, _) => HideDialog();
                recycle.Confirm += (_, _) => HideDialog();
                break;
            case ConfirmRebuildableCard rebuild:
                rebuild.Cancel += (_, _) => HideDialog();
                rebuild.Confirm += (_, _) => HideDialog();
                break;
            case ConfirmPermanentCard permanent:
                permanent.Cancel += (_, _) => HideDialog();
                permanent.Confirm += (_, _) => HideDialog();
                break;
            case ResultCard result:
                result.ViewHistory += (_, _) =>
                {
                    HideDialog();
                    Navigate(MoleDestination.History);
                };
                result.Primary += (_, _) => HideDialog();
                break;
        }
        DialogHost.Content = card;
        DialogScrim.Visibility = Visibility.Visible;
    }

    private void HideDialog()
    {
        DialogScrim.Visibility = Visibility.Collapsed;
        DialogHost.Content = null;
    }

    private void HighlightNav()
    {
        foreach (var child in NavPane.Children)
        {
            if (child is NavButton nav)
            {
                nav.IsCurrent = nav.Tag as string == _destination.ToString();
            }
        }
    }

    private void BuildToolbar()
    {
        ToolbarTrailing.Children.Clear();
        switch (_destination)
        {
            case MoleDestination.Overview:
                ToolbarTrailing.Children.Add(MakeButton("View live status", false));
                break;
            case MoleDestination.Clean:
                ToolbarTrailing.Children.Add(MakeText("Last scanned 10:42"));
                var scan = MakeButton("Scan", true);
                scan.Click += (_, _) => ShowScan();
                ToolbarTrailing.Children.Add(scan);
                break;
            case MoleDestination.Applications:
                var search = new TextBox
                {
                    PlaceholderText = "Search apps",
                    Width = 220,
                    Height = 32
                };
                search.TextChanged += (_, _) =>
                {
                    if (_pages.TryGetValue(MoleDestination.Applications, out var page) &&
                        page is ApplicationsPage apps)
                    {
                        apps.ApplySearch(search.Text);
                    }
                };
                ToolbarTrailing.Children.Add(search);
                break;
            case MoleDestination.Projects:
                ToolbarTrailing.Children.Add(MakeText(@"C:\Users\you\Projects"));
                ToolbarTrailing.Children.Add(MakeButton("Manage locations", true));
                ToolbarTrailing.Children.Add(MakeButton("Scan", true));
                break;
            case MoleDestination.DiskExplorer:
                ToolbarTrailing.Children.Add(MakeButton("Choose folder", true));
                break;
            case MoleDestination.History:
                ToolbarTrailing.Children.Add(MakeButton("Open log", true));
                break;
        }
    }

    private static TextBlock MakeText(string text) => new()
    {
        Text = text,
        FontSize = 12,
        Foreground = Theme.Brush("MoleTextSecondary"),
        VerticalAlignment = VerticalAlignment.Center
    };

    private static Button MakeButton(string label, bool secondary) =>
        new MoleButton(label, secondary ? MoleButtonKind.Secondary : MoleButtonKind.Primary);
}
