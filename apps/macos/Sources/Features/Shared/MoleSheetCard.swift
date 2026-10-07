import SwiftUI

struct MoleSheetCard<Content: View>: View {
    @Environment(\.molePalette) private var palette

    var width: CGFloat = 440
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(24)
        .frame(width: width, alignment: .leading)
        .background(palette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MoleTokens.panelRadius, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        }
    }
}

struct MoleSheetScrim<Content: View>: View {
    @Environment(\.molePalette) private var palette

    var onScrimTap: (() -> Void)?
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            palette.canvas.opacity(0.72)
                .contentShape(Rectangle())
                .onTapGesture { onScrimTap?() }
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.canvas)
    }
}

struct MolePathLine: View {
    @Environment(\.molePalette) private var palette

    var path: String

    var body: some View {
        Text(path)
            .font(MoleTokens.mono(12))
            .foregroundStyle(palette.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(palette.raised)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
