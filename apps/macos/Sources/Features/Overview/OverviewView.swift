import SwiftUI

struct OverviewView: View {
    @Environment(\.molePalette) private var palette

    var snapshot: OverviewSnapshot
    var onLiveStatus: () -> Void
    var onHistory: () -> Void
    var onRecommendation: (OverviewRecommendation) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MoleTokens.bodyGap) {
                hero
                HStack(spacing: 16) {
                    SummaryPanel(
                        kicker: "Reclaimable space",
                        value: snapshot.reclaimable,
                        hint: snapshot.reclaimableHint
                    )
                    SummaryPanel(
                        kicker: "Applications",
                        value: snapshot.applications,
                        hint: snapshot.applicationsHint,
                        hintTone: snapshot.applicationsHintReview ? .review : .neutral
                    )
                    SummaryPanel(
                        kicker: "Health",
                        value: snapshot.healthScore,
                        hint: snapshot.healthHint
                    )
                }
                recommended
                activity
            }
            .padding(MoleTokens.bodyPadding)
        }
        .background(palette.canvas)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mole")
                .font(MoleTokens.ui(24, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            HStack(spacing: 8) {
                StatusPill(label: "Health \(snapshot.healthScore)", icon: .heartPulse, tone: .success)
                Text("·")
                    .foregroundStyle(palette.textSecondary)
                Text(snapshot.freeSpace)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                Text("·")
                    .foregroundStyle(palette.textSecondary)
                Text(snapshot.lastScan)
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(snapshot.lastScanStale ? palette.review : palette.textSecondary)
            }
        }
    }

    private var recommended: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended actions")
                .font(MoleTokens.ui(16, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            VStack(spacing: 4) {
                ForEach(snapshot.recommendations) { item in
                    RecommendationRow(title: item.title, icon: item.icon) {
                        onRecommendation(item)
                    }
                }
            }
        }
    }

    private var activity: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent activity")
                    .font(MoleTokens.ui(16, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                Button(action: onHistory) {
                    Text("View History")
                        .font(MoleTokens.ui(13, weight: .medium))
                        .foregroundStyle(palette.brand)
                }
                .buttonStyle(.plain)
            }
            VStack(spacing: 0) {
                ForEach(snapshot.activity) { item in
                    ActivityRow(command: item.command, detail: item.detail, time: item.time)
                }
            }
        }
    }
}
