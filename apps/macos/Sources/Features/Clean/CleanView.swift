import SwiftUI

struct CleanCategory: Equatable, Identifiable {
    var id: String
    var name: String
    var items: String
    var size: String
    var sizeTone: MolePillTone = .neutral
    var state: String
    var stateTone: MolePillTone = .neutral
    var selected: Bool
    var enabled: Bool = true
}

struct CleanView: View {
    @Environment(\.molePalette) private var palette

    var categories: [CleanCategory]
    var onToggle: (CleanCategory) -> Void
    var onProtect: () -> Void
    var onReview: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Clean")
                        .font(MoleTokens.ui(24, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    Text("4.8 GB measured")
                        .font(MoleTokens.ui(13, weight: .medium))
                        .foregroundStyle(palette.textPrimary)
                    Text("8 categories")
                        .font(MoleTokens.ui(13))
                        .foregroundStyle(palette.textSecondary)
                    StatusPill(label: "2 need review", tone: .review)
                }
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Color.clear.frame(width: MoleTokens.checkboxSize, height: MoleTokens.checkboxSize)
                        Text("Category")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Items").frame(width: 64, alignment: .trailing)
                        Text("Size").frame(width: 88, alignment: .trailing)
                        Text("State").frame(width: 120, alignment: .leading)
                    }
                    .font(MoleTokens.ui(12, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.horizontal, 8)
                    .frame(height: 32)
                    ForEach(categories) { row in
                        CandidateRow(
                            name: row.name,
                            items: row.items,
                            size: row.size,
                            sizeTone: row.sizeTone,
                            stateLabel: row.state,
                            stateTone: row.stateTone,
                            isOn: row.selected,
                            enabled: row.enabled,
                            toggle: { onToggle(row) }
                        )
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(MoleTokens.bodyPadding)

            HStack {
                Text(footerLabel)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                MoleButton(title: "Protect…", kind: .secondary, action: onProtect)
                MoleButton(title: "Review Cleanup…", kind: .primary, action: onReview)
            }
            .padding(.horizontal, MoleTokens.bodyPadding)
            .frame(height: 56)
            .overlay(alignment: .top) {
                Rectangle().fill(palette.border).frame(height: 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(palette.canvas)
    }

    private var footerLabel: String {
        let selected = categories.filter(\.selected)
        let ids = Set(selected.map(\.id))
        if ids == ["user-app-caches", "browsers", "installers"] {
            return "3 selected · 3.5 GB measured"
        }
        return "\(selected.count) selected"
    }
}
