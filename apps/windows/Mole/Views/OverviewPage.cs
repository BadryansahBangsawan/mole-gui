using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Mole.Engine;

namespace Mole.Views;

public sealed class OverviewPage : UserControl
{
    public event EventHandler<MoleDestination>? NavigateTo;
    public event EventHandler? ViewHistory;

    public OverviewPage()
    {
        var snap = Fixtures.Overview;
        var recommended = new StackPanel { Spacing = 4 };
        foreach (var item in snap.Recommendations)
        {
            var row = new RecommendationRow(item.Title);
            var dest = item.Destination;
            row.Activated += (_, _) => NavigateTo?.Invoke(this, dest);
            recommended.Children.Add(row);
        }

        var activity = new StackPanel { Spacing = 0 };
        foreach (var item in snap.Activity)
        {
            activity.Children.Add(new ActivityRow(item.Command, item.Detail, item.Time));
        }

        var historyLink = new MoleButton("View History", MoleButtonKind.Quiet);
        historyLink.Click += (_, _) => ViewHistory?.Invoke(this, EventArgs.Empty);

        var body = new StackPanel { Spacing = 20 };
        body.Children.Add(Layout.Column(8,
            Theme.Text("Mole", 24, semibold: true),
            Layout.Row(8,
                new StatusPill($"Health {snap.HealthScore}", PillTone.Success),
                Theme.Text("·", 13, brush: "MoleTextSecondary"),
                Theme.Text(snap.FreeSpace, 13, medium: true),
                Theme.Text("·", 13, brush: "MoleTextSecondary"),
                Theme.Text(snap.LastScan, 13, brush: snap.LastScanStale ? "MoleReview" : "MoleTextSecondary"))));

        var metrics = new Grid { ColumnSpacing = 16 };
        metrics.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        metrics.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        metrics.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        var reclaim = new SummaryPanel("Reclaimable space", snap.Reclaimable, snap.ReclaimableHint);
        var apps = new SummaryPanel("Applications", snap.Applications, snap.ApplicationsHint, PillTone.Review);
        var health = new SummaryPanel("Health", snap.HealthScore, snap.HealthHint);
        Grid.SetColumn(apps, 1);
        Grid.SetColumn(health, 2);
        metrics.Children.Add(reclaim);
        metrics.Children.Add(apps);
        metrics.Children.Add(health);
        body.Children.Add(metrics);

        body.Children.Add(Layout.Column(8,
            Theme.Text("Recommended actions", 16, semibold: true),
            recommended));

        var activityHeader = new Grid();
        activityHeader.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        activityHeader.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        activityHeader.Children.Add(Theme.Text("Recent activity", 16, semibold: true));
        Grid.SetColumn(historyLink, 1);
        activityHeader.Children.Add(historyLink);
        body.Children.Add(Layout.Column(8, activityHeader, activity));

        Content = new ScrollViewer
        {
            Content = body,
            Padding = new Thickness(20)
        };
    }
}
