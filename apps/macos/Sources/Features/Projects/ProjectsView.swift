import SwiftUI

enum ProjectFilter: String, CaseIterable, Identifiable {
    case selected = "Selected"
    case old = "Old"
    case recent = "Recent"
    case couldNotInspect = "Could not inspect"
    case protected = "Protected"

    var id: String { rawValue }
}

struct ProjectArtifact: Equatable, Identifiable {
    var id: String
    var name: String
    var kind: String
    var age: String
    var size: String
    var sizeTone: MolePillTone = .neutral
    var state: String
    var stateTone: MolePillTone = .neutral
    var selected: Bool
    var enabled: Bool = true
    var estimatedBytes: Int64?
}

struct ProjectGroup: Equatable, Identifiable {
    var id: String
    var path: String
    var size: String
    var artifacts: [ProjectArtifact]
}

struct ProjectsView: View {
    @Environment(\.molePalette) private var palette

    var onReview: () -> Void = {}

    @State private var filter: ProjectFilter = .selected
    @State private var groups: [ProjectGroup] = ProjectGroup.kit

    private var selectedArtifacts: [ProjectArtifact] {
        groups.flatMap(\.artifacts).filter(\.selected)
    }

    private var footerText: String {
        let bytes = selectedArtifacts.compactMap(\.estimatedBytes).reduce(Int64(0), +)
        return "\(selectedArtifacts.count) selected · \(formatEstimate(bytes)) estimated · permanent"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Projects")
                .font(MoleTokens.ui(24, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            SafetyBanner(
                message: "Project purge is permanent. Selected artifacts cannot be restored from Trash. Worktrees themselves are never deleted."
            )
            filters
            artifactList
            Spacer(minLength: 0)
            HStack {
                Text(footerText)
                    .font(MoleTokens.ui(13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                MoleButton(title: "Review Purge…", kind: .danger, action: onReview)
            }
        }
        .padding(MoleTokens.bodyPadding)
        .background(palette.canvas)
    }

    private var filters: some View {
        HStack(spacing: 8) {
            ForEach(ProjectFilter.allCases) { item in
                let active = filter == item
                Button {
                    filter = item
                } label: {
                    Text(item.rawValue)
                        .font(MoleTokens.ui(12, weight: .medium))
                        .foregroundStyle(active ? palette.brand : palette.textSecondary)
                        .padding(.horizontal, 12)
                        .frame(height: 28)
                        .background(active ? palette.selected : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var artifactList: some View {
        VStack(spacing: 0) {
            ForEach(groups) { group in
                groupHeader(group)
                ForEach(group.artifacts) { artifact in
                    artifactRow(artifact)
                }
            }
        }
    }

    private func groupHeader(_ group: ProjectGroup) -> some View {
        HStack(spacing: 8) {
            Image(mole: .chevronRight)
                .font(MoleTokens.ui(10, weight: .semibold))
                .foregroundStyle(palette.textSecondary)
                .rotationEffect(.degrees(90))
            Text(group.path)
                .font(MoleTokens.ui(12, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(group.size)
                .font(MoleTokens.ui(12))
                .foregroundStyle(palette.textSecondary)
        }
        .padding(.horizontal, 8)
        .frame(height: 36)
    }

    private func artifactRow(_ artifact: ProjectArtifact) -> some View {
        HStack(spacing: 12) {
            MoleCheckbox(
                isOn: artifact.selected,
                enabled: artifact.enabled,
                action: { toggle(artifact) }
            )
            Text("\(artifact.name)  ·  \(artifact.kind)")
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(artifact.age)
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textSecondary)
                .frame(width: 64, alignment: .trailing)
            Text(artifact.size)
                .font(MoleTokens.ui(13, weight: .medium))
                .foregroundStyle(artifact.sizeTone == .review ? palette.review : palette.textPrimary)
                .frame(width: 88, alignment: .trailing)
            StatusPill(label: artifact.state, tone: artifact.stateTone)
        }
        .padding(.horizontal, 8)
        .frame(height: MoleTokens.candidateRowHeight)
        .background(artifact.selected ? palette.selected : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .opacity(artifact.enabled ? 1 : 0.7)
    }

    private func toggle(_ artifact: ProjectArtifact) {
        guard artifact.enabled else { return }
        for groupIndex in groups.indices {
            if let artifactIndex = groups[groupIndex].artifacts.firstIndex(where: { $0.id == artifact.id }) {
                groups[groupIndex].artifacts[artifactIndex].selected.toggle()
                return
            }
        }
    }

    private func formatEstimate(_ bytes: Int64) -> String {
        let gb = Double(bytes) / 1_000_000_000
        if gb >= 1 || bytes == 0 {
            return String(format: "%.2f GB", gb)
        }
        return String(format: "%.0f MB", Double(bytes) / 1_000_000)
    }
}

extension ProjectGroup {
    static let kit: [ProjectGroup] = [
        ProjectGroup(
            id: "website",
            path: "~/Projects/website",
            size: "3.99 GB",
            artifacts: [
                ProjectArtifact(
                    id: "website-node-modules",
                    name: "node_modules",
                    kind: "node_modules",
                    age: "28d",
                    size: "3.80 GB",
                    state: "Ready",
                    selected: true,
                    estimatedBytes: 3_800_000_000
                ),
                ProjectArtifact(
                    id: "website-dist",
                    name: "dist",
                    kind: "dist",
                    age: "<1d",
                    size: "186 MB",
                    sizeTone: .review,
                    state: "Ready",
                    selected: false,
                    estimatedBytes: 186_000_000
                )
            ]
        ),
        ProjectGroup(
            id: "rust-app",
            path: "~/Projects/rust-app",
            size: "2.22 GB",
            artifacts: [
                ProjectArtifact(
                    id: "rust-target",
                    name: "target",
                    kind: "target",
                    age: "2mo",
                    size: "2.20 GB",
                    state: "Ready",
                    selected: true,
                    estimatedBytes: 2_200_000_000
                ),
                ProjectArtifact(
                    id: "rust-dist",
                    name: "dist",
                    kind: "dist-rust",
                    age: "<7d",
                    size: "22 MB",
                    sizeTone: .review,
                    state: "Ready",
                    selected: false,
                    estimatedBytes: 22_000_000
                )
            ]
        ),
        ProjectGroup(
            id: "legacy-tool",
            path: "~/Projects/legacy-tool",
            size: "—",
            artifacts: [
                ProjectArtifact(
                    id: "legacy-nested-git",
                    name: "node_modules",
                    kind: "nested-git",
                    age: "—",
                    size: "Unknown",
                    state: "Could not inspect",
                    stateTone: .review,
                    selected: false,
                    enabled: false
                )
            ]
        )
    ]
}
