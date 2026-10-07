import SwiftUI

struct AuthAfterConfirmSheet: View {
    @Environment(\.molePalette) private var palette

    var onCancel: () -> Void
    var onContinue: () -> Void

    var body: some View {
        MoleSheetScrim {
            MoleSheetCard {
                Text("Administrator access needed")
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("1 selected item requires administrator access to continue.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textPrimary)
                Text("macOS will prompt for administrator authentication. Mole does not collect the password.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Cancel leaves the confirmed plan waiting. Continue opens the system prompt.")
                    .font(MoleTokens.ui(12))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    Spacer(minLength: 0)
                    MoleButton(title: "Cancel", kind: .secondary, action: onCancel)
                    MoleButton(title: "Continue", kind: .primary, action: onContinue)
                }
            }
        }
    }
}
