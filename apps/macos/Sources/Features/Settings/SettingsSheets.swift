import SwiftUI

struct SettingsAuthenticationSheet: View {
    @Environment(\.molePalette) private var palette

    var onDisable: () -> Void = {}
    var onDone: () -> Void

    var body: some View {
        MoleSheetScrim {
            MoleSheetCard(width: 480) {
                Text("Authentication")
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("Touch ID for sudo is previewed here. Enabling still uses the mo touchid path.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("The app never owns a password field. macOS prompts after a confirmed plan that needs privilege.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Touch ID for sudo · On")
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                HStack(spacing: 12) {
                    Spacer(minLength: 0)
                    MoleButton(title: "Disable Touch ID…", kind: .secondary, action: onDisable)
                    MoleButton(title: "Done", kind: .primary, action: onDone)
                }
            }
        }
    }
}

struct SettingsCLISheet: View {
    @Environment(\.molePalette) private var palette

    var onPreviewCompletion: () -> Void = {}
    var onDone: () -> Void

    var body: some View {
        MoleSheetScrim {
            MoleSheetCard(width: 480) {
                Text("CLI integration")
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("Companion looks for mo next to the app, then PATH.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("If the CLI is missing, destructive actions stay disabled until a binary is found.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("/usr/local/bin/mo · 1.56.1")
                    .font(MoleTokens.mono(12))
                    .foregroundStyle(palette.textPrimary)
                Text("Shell completion · zsh · preview before changing")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                HStack(spacing: 12) {
                    Spacer(minLength: 0)
                    MoleButton(title: "Preview Completion…", kind: .secondary, action: onPreviewCompletion)
                    MoleButton(title: "Done", kind: .primary, action: onDone)
                }
            }
        }
    }
}

struct SettingsUpdatesSheet: View {
    @Environment(\.molePalette) private var palette

    var onNotNow: () -> Void
    var onCheck: () -> Void

    var body: some View {
        MoleSheetScrim {
            MoleSheetCard(width: 480) {
                Text("Updates")
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("Channel Stable · Last checked today · Current 1.56.1")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                Text("A checksum mismatch aborts. Install never falls back to an unverified binary.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Nightly installs from main and is labeled as such.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    Spacer(minLength: 0)
                    MoleButton(title: "Not now", kind: .secondary, action: onNotNow)
                    MoleButton(title: "Check for Update…", kind: .primary, action: onCheck)
                }
            }
        }
    }
}

struct SettingsAdvancedSheet: View {
    @Environment(\.molePalette) private var palette

    var onCopyDiagnostics: () -> Void = {}
    var onRemove: () -> Void = {}
    var onDone: () -> Void = {}

    var body: some View {
        MoleSheetScrim(onScrimTap: onDone) {
            MoleSheetCard(width: 480) {
                Text("Advanced")
                    .font(MoleTokens.ui(20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("Diagnostics and removal stay preview-first.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                Text("Remove Mole keeps a custom config root for manual review. Only ~/.config/mole moves to Trash.")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("~/Library/Logs/mole")
                    .font(MoleTokens.mono(12))
                    .foregroundStyle(palette.textPrimary)
                Text("Debug session · Off")
                    .font(MoleTokens.ui(13))
                    .foregroundStyle(palette.textSecondary)
                HStack(spacing: 12) {
                    Spacer(minLength: 0)
                    MoleButton(title: "Copy Diagnostics", kind: .secondary, action: onCopyDiagnostics)
                    MoleButton(title: "Remove Mole…", kind: .danger, action: onRemove)
                }
            }
        }
    }
}
