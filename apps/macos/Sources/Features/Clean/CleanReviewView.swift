import SwiftUI

struct CleanReviewItem: Equatable, Identifiable {
    var id: String
    var name: String
    var size: String
    var state: String = "Ready"
    var stateTone: MolePillTone = .success
}

struct CleanReviewView: View {
    @Environment(\.molePalette) private var palette

    var summary: String = "3 selected · 3.5 GB measured · Remove permanently"
    var note: String = "Developer tools are unselected because Chrome is running."
    var items: [CleanReviewItem] = [
        CleanReviewItem(id: "user-app-caches", name: "User app caches", size: "1.7 GB"),
        CleanReviewItem(id: "browsers", name: "Browsers", size: "1.2 GB"),
        CleanReviewItem(id: "installers", name: "Installers", size: "600 MB")
    ]
    var onBack: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Review cleanup")
                        .font(MoleTokens.ui(16, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                    Text(summary)
                        .font(MoleTokens.ui(13))
                        .foregroundStyle(palette.textSecondary)
                }
                SafetyBanner(
                    message: "1 selected item requires administrator access. Authentication is requested only after you confirm."
                )
                Text(note)
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        HStack(spacing: 12) {
                            Text(item.name)
                                .font(MoleTokens.ui(13, weight: .medium))
                                .foregroundStyle(palette.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(item.size)
                                .font(MoleTokens.ui(13))
                                .foregroundStyle(palette.textPrimary)
                            StatusPill(label: item.state, icon: .check, tone: item.stateTone)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                    }
                }
                .background(palette.raised)
                .clipShape(RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous)
                        .stroke(palette.border, lineWidth: 1)
                }
                HStack(spacing: 12) {
                    Spacer(minLength: 0)
                    MoleButton(title: "Back", kind: .secondary, action: onBack)
                    MoleButton(title: "Confirm Cleanup…", kind: .primary, action: onConfirm)
                }
            }
            .padding(24)
            .frame(maxWidth: 520)
            .background(palette.canvas)
            .clipShape(RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous)
                    .stroke(palette.border, lineWidth: 1)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.canvas)
    }
}
