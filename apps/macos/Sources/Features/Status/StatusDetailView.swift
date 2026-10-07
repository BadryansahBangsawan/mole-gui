import SwiftUI

struct StatusMetric: Equatable, Identifiable {
    var id: String
    var kicker: String
    var value: String
    var hint: String
}

struct StatusProcess: Equatable, Identifiable {
    var id: String
    var name: String
    var cpu: String
    var sustained: String
    var attribution: String
}

struct StatusSnapshot: Equatable {
    var sampled: String
    var cores: String
    var live: Bool
    var metrics: [StatusMetric]
    var processes: [StatusProcess]
    var zombieLabel: String
    var zombieNote: String
}

struct StatusDetailView: View {
    @Environment(\.molePalette) private var palette

    var snapshot: StatusSnapshot

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SafetyBanner(
                    message: "Session-scoped and read-only. Stopping live view ends sampling; Mole does not keep a background monitor."
                )
                HStack(spacing: 8) {
                    StatusPill(label: "Health 92", icon: .heartPulse, tone: .success)
                    Text("·").foregroundStyle(palette.textSecondary)
                    Text(snapshot.sampled)
                        .font(MoleTokens.ui(13))
                        .foregroundStyle(palette.textSecondary)
                    Text("·").foregroundStyle(palette.textSecondary)
                    Text(snapshot.cores)
                        .font(MoleTokens.ui(13))
                        .foregroundStyle(palette.textSecondary)
                    Text("·").foregroundStyle(palette.textSecondary)
                    Text(snapshot.live ? "Live" : "Stopped")
                        .font(MoleTokens.ui(13))
                        .foregroundStyle(palette.brand)
                }
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(snapshot.metrics) { metric in
                        SummaryPanel(kicker: metric.kicker, value: metric.value, hint: metric.hint)
                    }
                }
                processTable
            }
            .padding(MoleTokens.bodyPadding)
        }
        .background(palette.canvas)
    }

    private var processTable: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Sustained CPU · read-only")
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                Text("No process can be terminated from this view.")
                    .font(MoleTokens.ui(12))
                    .foregroundStyle(palette.textSecondary)
            }
            HStack {
                header("Process", 160)
                header("CPU", 64)
                header("Sustained", 90)
                header("Attribution", nil)
            }
            .padding(.horizontal, 8)
            ForEach(snapshot.processes) { row in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(row.name)
                        .font(MoleTokens.mono(13, weight: .medium))
                        .foregroundStyle(palette.textPrimary)
                        .frame(width: 160, alignment: .leading)
                    Text(row.cpu)
                        .font(MoleTokens.mono(12))
                        .foregroundStyle(palette.textPrimary)
                        .frame(width: 64, alignment: .leading)
                    Text(row.sustained)
                        .font(MoleTokens.ui(12))
                        .foregroundStyle(palette.textSecondary)
                        .frame(width: 90, alignment: .leading)
                    Text(row.attribution)
                        .font(MoleTokens.ui(12))
                        .foregroundStyle(palette.textSecondary)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
                .frame(height: 36)
            }
            HStack {
                StatusPill(label: snapshot.zombieLabel, tone: .success)
                Text(snapshot.zombieNote)
                    .font(MoleTokens.ui(12))
                    .foregroundStyle(palette.textSecondary)
            }
        }
        .padding(16)
        .background(palette.raised)
        .clipShape(RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        }
    }

    private func header(_ title: String, _ width: CGFloat?) -> some View {
        Text(title)
            .font(MoleTokens.ui(11, weight: .medium))
            .foregroundStyle(palette.textSecondary)
            .frame(width: width, alignment: .leading)
    }
}
