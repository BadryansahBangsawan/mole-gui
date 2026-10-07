import SwiftUI

struct DiskItem: Equatable, Identifiable {
    var id: String
    var name: String
    var size: String
    var sizeTone: MolePillTone = .neutral
    var stateLabel: String?
    var stateTone: MolePillTone = .neutral
    var path: String
    var scanStatus: String
    var children: String
    var modified: String
    var protection: String
    var selectable: Bool = true
}

struct DiskExplorerView: View {
    @Environment(\.molePalette) private var palette

    var items: [DiskItem]
    var selectedID: String?
    var mutationEnabled: Bool
    var onSelect: (DiskItem) -> Void
    var onMoveToTrash: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                breadcrumb
                HStack(spacing: 8) {
                    tab("This folder", selected: true)
                    tab("Large Files", selected: false)
                }
                VStack(spacing: 0) {
                    HStack {
                        Text("Name")
                            .font(MoleTokens.ui(12, weight: .medium))
                            .foregroundStyle(palette.textSecondary)
                        Spacer()
                        Text("Size")
                            .font(MoleTokens.ui(12, weight: .medium))
                            .foregroundStyle(palette.textSecondary)
                            .frame(width: 88, alignment: .trailing)
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 32)
                    ForEach(items) { item in
                        row(item)
                            .onTapGesture { onSelect(item) }
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(MoleTokens.bodyPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Rectangle().fill(palette.border).frame(width: 1)

            inspector
                .frame(width: 280)
        }
        .background(palette.canvas)
    }

    private var breadcrumb: some View {
        HStack(spacing: 6) {
            Text("Macintosh HD").foregroundStyle(palette.textSecondary)
            Text("›").foregroundStyle(palette.textSecondary)
            Text("Users").foregroundStyle(palette.textSecondary)
            Text("›").foregroundStyle(palette.textSecondary)
            Text("you").foregroundStyle(palette.textPrimary)
        }
        .font(MoleTokens.ui(12))
    }

    private func tab(_ title: String, selected: Bool) -> some View {
        Text(title)
            .font(MoleTokens.ui(12, weight: .medium))
            .foregroundStyle(selected ? palette.brand : palette.textSecondary)
            .padding(.horizontal, 12)
            .frame(height: 28)
            .background(selected ? palette.selected : Color.clear)
            .clipShape(Capsule())
    }

    private func row(_ item: DiskItem) -> some View {
        let selected = item.id == selectedID
        return HStack {
            Text(item.name)
                .font(item.name.hasPrefix(".") ? MoleTokens.mono(13) : MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(item.selectable ? palette.textPrimary : palette.textSecondary)
            Spacer()
            if let state = item.stateLabel {
                StatusPill(label: state, tone: item.stateTone)
            }
            Text(item.size)
                .font(MoleTokens.ui(13, weight: item.sizeTone == .review ? .medium : .regular))
                .foregroundStyle(item.sizeTone == .review ? palette.review : (item.selectable ? palette.textPrimary : palette.textSecondary))
                .frame(width: 88, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .frame(height: 40)
        .background(selected ? palette.selected : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var inspector: some View {
        if let item = items.first(where: { $0.id == selectedID }) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(MoleTokens.ui(20, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                    Text(item.path)
                        .font(MoleTokens.mono(11))
                        .foregroundStyle(palette.textSecondary)
                }
                inspectorLine("Size", item.size)
                inspectorLine("Scan status", item.scanStatus)
                inspectorLine("Children", item.children)
                inspectorLine("Modified", item.modified)
                inspectorLine("Protection", item.protection)
                Spacer(minLength: 0)
                HStack(spacing: 8) {
                    MoleButton(title: "Quick Look", kind: .secondary, action: {})
                    MoleButton(title: "Move to Trash…", kind: .primary, action: onMoveToTrash)
                        .disabled(!mutationEnabled)
                        .opacity(mutationEnabled ? 1 : 0.45)
                }
            }
            .padding(20)
        } else {
            Text("Select an item")
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func inspectorLine(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key)
                .font(MoleTokens.ui(12))
                .foregroundStyle(palette.textSecondary)
            Spacer()
            Text(value)
                .font(MoleTokens.ui(12, weight: .medium))
                .foregroundStyle(palette.textPrimary)
        }
    }
}
