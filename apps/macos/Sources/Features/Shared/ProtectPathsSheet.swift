import SwiftUI

struct ProtectPathsSheet: View {
    @Environment(\.molePalette) private var palette

    var patterns: [String] = [
        "~/Library/Caches/MyApp",
        "~/Movies",
        "*.code-workspace"
    ]
    var onCancel: () -> Void
    var onSave: () -> Void

    var body: some View {
        MoleSheetScrim {
            MoleSheetCard(width: 480) {
                Text("Protect paths")
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("3 cleanup path patterns · 1 maintenance exclusion")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                Text("Matching targets are kept. A pattern skips a path; it is not a vendor-wide delete.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: 8) {
                    ForEach(patterns, id: \.self) { pattern in
                        MolePathLine(path: pattern)
                    }
                }
                HStack(spacing: 12) {
                    Spacer(minLength: 0)
                    MoleButton(title: "Cancel", kind: .secondary, action: onCancel)
                    MoleButton(title: "Save Patterns", kind: .primary, action: onSave)
                }
            }
        }
    }
}
