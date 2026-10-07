import SwiftUI

struct InstallerFile: Equatable, Identifiable {
    var id: String { name }
    var name: String
    var size: String
}

struct InstallerInspectorView: View {
    @Environment(\.molePalette) private var palette

    var files: [InstallerFile] = [
        InstallerFile(name: "Photoshop_2024.dmg", size: "240 MB"),
        InstallerFile(name: "Xcode_16.pkg", size: "180 MB"),
        InstallerFile(name: "Docker.dmg", size: "120 MB"),
        InstallerFile(name: "Slack.dmg", size: "60 MB")
    ]
    var onChooseVolume: () -> Void = {}
    var onBack: () -> Void
    var onReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Installers")
                .font(MoleTokens.ui(24, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            Text("4 files · 600 MB measured · removed permanently when confirmed")
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textSecondary)
            SafetyBanner(message: "Installer files are rebuildable downloads. They will not appear in Trash.")
            VStack(spacing: 8) {
                ForEach(files) { file in
                    HStack {
                        Text(file.name)
                            .font(MoleTokens.mono(13))
                            .foregroundStyle(palette.textPrimary)
                        Spacer()
                        Text(file.size)
                            .font(MoleTokens.ui(13, weight: .medium))
                            .foregroundStyle(palette.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(palette.raised)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            Spacer(minLength: 0)
            HStack(spacing: 12) {
                MoleButton(title: "Choose Volume…", kind: .secondary, action: onChooseVolume)
                Spacer()
                MoleButton(title: "Back", kind: .secondary, action: onBack)
                MoleButton(title: "Review Installers…", kind: .primary, action: onReview)
            }
        }
        .padding(MoleTokens.bodyPadding)
        .background(palette.canvas)
    }
}
