import SwiftUI

struct FirstRunView: View {
    @Environment(\.molePalette) private var palette

    var onNotNow: () -> Void
    var onGrantAccess: () -> Void

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome to Mole")
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("Companion for the mo CLI. Review exact paths first. Nothing is deleted until you confirm.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .leading, spacing: 8) {
                    bullet("Scan known-safe caches, apps, and rebuildable artifacts.")
                    bullet("Clean removes rebuildable caches permanently; they will not appear in Trash.")
                    bullet("The CLI remains the surface for scripts and automation.")
                }
                HStack(spacing: 12) {
                    Spacer(minLength: 0)
                    MoleButton(title: "Not now", kind: .secondary, action: onNotNow)
                    MoleButton(title: "Grant Full Disk Access…", kind: .primary, action: onGrantAccess)
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

    private func bullet(_ text: String) -> some View {
        Text("·  \(text)")
            .font(MoleTokens.ui(13))
            .foregroundStyle(palette.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
