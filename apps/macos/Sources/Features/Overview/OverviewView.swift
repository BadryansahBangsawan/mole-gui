import SwiftUI

/// Overview is read-only in Phase 0: `status --json` and `history --json`.
struct OverviewView: View {
    @State private var statusText = "Status JSON loads on a Mac via MoleClient.statusJSON()."
    @State private var historyText = "History JSON loads on a Mac via MoleClient.describeHistory()."

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.title2.weight(.semibold))
            Text("Mole CLI companion — not Mole Mac. Destructive work stays behind Review → Confirm.")
                .foregroundStyle(.secondary)
            GroupBox("Health") {
                Text(statusText)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            GroupBox("Recent activity") {
                Text(historyText)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
        }
        .padding(24)
        .background(MoleTokens.Light.canvas)
    }
}
