import SwiftUI

struct ScanLocationsSheet: View {
    @Environment(\.molePalette) private var palette

    var locations: [String] = [
        "~/Projects",
        "~/GitHub",
        "~/dev",
        "~/.codex/worktrees"
    ]
    var onAdd: () -> Void = {}
    var onSave: () -> Void

    var body: some View {
        MoleSheetScrim {
            MoleSheetCard(width: 480) {
                Text("Project scan locations")
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("Discovery uses these containers. Other dot directories stay out of scope.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("A purge target is never a container. ~/node_modules is not scanned as a set of projects.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: 8) {
                    ForEach(locations, id: \.self) { location in
                        MolePathLine(path: location)
                    }
                }
                HStack(spacing: 12) {
                    MoleButton(title: "Add Location…", kind: .secondary, action: onAdd)
                    Spacer(minLength: 0)
                    MoleButton(title: "Save Locations", kind: .primary, action: onSave)
                }
            }
        }
    }
}
