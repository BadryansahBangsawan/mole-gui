import SwiftUI

struct MoleRootView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var destination: MoleDestination = .overview
    @State private var overview = MoleFixtures.overview
    @State private var historyTab: HistoryTab = .sessions
    @State private var selectedSessionID = MoleFixtures.historySessions.first?.id
    @State private var selectedAuditID = MoleFixtures.historyAudit.first?.id
    @State private var selectedDiskID = "documents"
    @State private var cleanCategories = MoleFixtures.cleanCategories
    @State private var showingCleanReview = false
    @State private var applications = MoleFixtures.applications
    @State private var applicationsSearch = ""
    @State private var selectedAppID: String? = "photoshop"
    @State private var applicationsFilter: ApplicationsFilter = .all
    @State private var maintenanceSections = MoleFixtures.maintenance
    @State private var presentedSheet: CompanionSheet?
    private let client = MoleClient()

    var body: some View {
        let palette = MoleTokens.palette(colorScheme)
        HStack(spacing: 0) {
            MoleSidebar(destination: $destination)
            Rectangle()
                .fill(palette.border)
                .frame(width: 1)
            VStack(spacing: 0) {
                MoleToolbar(destination: destination) {
                    switch destination {
                    case .overview:
                        MoleButton(title: "View Live Status", icon: .activity, kind: .quiet) {
                            destination = .statusDetail
                        }
                        MoleIconButton(symbol: .ellipsis, action: {})
                    case .history:
                        MoleButton(title: "Reveal Log", kind: .quiet, action: {})
                        MoleIconButton(symbol: .ellipsis, action: {})
                    case .statusDetail:
                        Text("Every 2s")
                            .font(MoleTokens.ui(12))
                            .foregroundStyle(palette.textPrimary)
                            .padding(.horizontal, 10)
                            .frame(height: 32)
                            .background(palette.raised)
                            .clipShape(RoundedRectangle(cornerRadius: MoleTokens.fieldRadius, style: .continuous))
                        MoleButton(title: "Stop", kind: .quiet, action: {})
                        MoleIconButton(symbol: .ellipsis, action: {})
                    case .diskExplorer:
                        MoleButton(title: "Choose Folder…", kind: .secondary, action: {})
                        MoleIconButton(symbol: .ellipsis, action: {})
                    case .clean:
                        Text("Last scanned 10:42")
                            .font(MoleTokens.ui(12))
                            .foregroundStyle(palette.textSecondary)
                        MoleButton(title: "Scan", kind: .secondary, action: {})
                    case .applications:
                        MoleSearchField(placeholder: "Search apps", text: $applicationsSearch)
                            .frame(width: 220)
                    case .projects:
                        Text("Scanning ~/Projects")
                            .font(MoleTokens.ui(12))
                            .foregroundStyle(palette.textSecondary)
                        MoleButton(title: "Manage Scan Locations…", kind: .secondary) {
                            presentedSheet = .scanLocations
                        }
                        MoleButton(title: "Scan", kind: .secondary, action: {})
                    case .maintenance:
                        MoleIconButton(symbol: .ellipsis, action: {})
                    case .firstRun:
                        EmptyView()
                    default:
                        MoleIconButton(symbol: .ellipsis, action: {})
                    }
                }
                detail
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(palette.canvas)
        }
        .environment(\.molePalette, palette)
        .background(palette.canvas)
        .overlay { sheetOverlay }
        .task { await refreshOverview() }
    }

    @ViewBuilder
    private var sheetOverlay: some View {
        switch presentedSheet {
        case .protectPaths:
            ProtectPathsSheet(
                onCancel: { presentedSheet = nil },
                onSave: { presentedSheet = nil }
            )
        case .scanLocations:
            ScanLocationsSheet(onSave: { presentedSheet = nil })
        case .confirmTrash:
            MoleSheetScrim(onScrimTap: { presentedSheet = nil }) {
                ConfirmTrashSheet(
                    onCancel: { presentedSheet = nil },
                    onConfirm: { presentedSheet = nil }
                )
            }
        case .confirmRebuildable:
            MoleSheetScrim(onScrimTap: { presentedSheet = nil }) {
                ConfirmRebuildableSheet(
                    onCancel: { presentedSheet = nil },
                    onConfirm: { presentedSheet = nil }
                )
            }
        case .confirmPermanent:
            MoleSheetScrim(onScrimTap: { presentedSheet = nil }) {
                ConfirmPermanentSheet(
                    onCancel: { presentedSheet = nil },
                    onConfirm: { presentedSheet = nil }
                )
            }
        case .installerInspector:
            MoleSheetScrim(onScrimTap: { presentedSheet = nil }) {
                InstallerInspectorView(onBack: { presentedSheet = nil }, onReview: {
                    presentedSheet = .confirmRebuildable
                })
            }
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch destination {
        case .overview:
            OverviewView(
                snapshot: overview,
                onLiveStatus: { destination = .statusDetail },
                onHistory: { destination = .history },
                onRecommendation: { destination = $0.destination }
            )
        case .history:
            HistoryView(
                tab: historyTab,
                sessions: MoleFixtures.historySessions,
                audit: MoleFixtures.historyAudit,
                selectedSessionID: selectedSessionID,
                selectedAuditID: selectedAuditID,
                onTab: { historyTab = $0 },
                onSelectSession: { selectedSessionID = $0.id },
                onSelectAudit: { selectedAuditID = $0.id }
            )
        case .statusDetail:
            StatusDetailView(snapshot: MoleFixtures.status)
        case .settings:
            SettingsView(sections: MoleFixtures.settings, onRow: { _ in })
        case .diskExplorer:
            DiskExplorerView(
                items: MoleFixtures.diskItems,
                selectedID: selectedDiskID,
                mutationEnabled: false,
                onSelect: { selectedDiskID = $0.id },
                onMoveToTrash: {}
            )
        case .clean:
            if showingCleanReview {
                CleanReviewView(
                    items: cleanReviewItems,
                    onBack: { showingCleanReview = false },
                    onConfirm: { presentedSheet = .confirmRebuildable }
                )
            } else {
                CleanView(
                    categories: cleanCategories,
                    onToggle: toggleClean,
                    onProtect: { presentedSheet = .protectPaths },
                    onReview: { showingCleanReview = true }
                )
            }
        case .applications:
            ApplicationsView(
                apps: applications,
                search: applicationsSearch,
                selectedID: selectedAppID,
                filter: applicationsFilter,
                onSearch: { applicationsSearch = $0 },
                onFilter: { applicationsFilter = $0 },
                onSelect: { selectedAppID = $0.id },
                onToggle: toggleApp,
                onReviewUninstall: { _ in presentedSheet = .confirmTrash }
            )
        case .projects:
            ProjectsView(onReview: { presentedSheet = .confirmPermanent })
        case .maintenance:
            MaintenanceView(
                sections: maintenanceSections,
                onToggle: toggleMaintenance,
                onReview: {}
            )
        case .firstRun:
            FirstRunView(
                onNotNow: { destination = .overview },
                onGrantAccess: { destination = .overview }
            )
        default:
            PlaceholderPage(
                title: destination.title,
                note: "Wired in a later page. Mutations go through mo protocol."
            )
        }
    }

    private var cleanReviewItems: [CleanReviewItem] {
        cleanCategories.filter(\.selected).map { row in
            CleanReviewItem(id: row.id, name: row.name, size: row.size)
        }
    }

    private func toggleClean(_ row: CleanCategory) {
        guard row.enabled else { return }
        guard let index = cleanCategories.firstIndex(where: { $0.id == row.id }) else { return }
        cleanCategories[index].selected.toggle()
    }

    private func toggleApp(_ app: AppRow) {
        guard app.enabled else { return }
        guard let index = applications.firstIndex(where: { $0.id == app.id }) else { return }
        applications[index].checked.toggle()
    }

    private func toggleMaintenance(_ task: MaintenanceTask) {
        guard task.enabled else { return }
        for sectionIndex in maintenanceSections.indices {
            if let taskIndex = maintenanceSections[sectionIndex].tasks.firstIndex(where: { $0.id == task.id }) {
                maintenanceSections[sectionIndex].tasks[taskIndex].selected.toggle()
                return
            }
        }
    }

    private func refreshOverview() async {
        do {
            _ = try await client.statusJSON()
            _ = try await client.describeHistory()
        } catch {
            overview = MoleFixtures.overview
        }
    }
}

private enum CompanionSheet: Equatable {
    case protectPaths
    case scanLocations
    case confirmTrash
    case confirmRebuildable
    case confirmPermanent
    case installerInspector
}

struct MoleSidebar: View {
    @Environment(\.molePalette) private var palette
    @Binding var destination: MoleDestination

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TrafficLights()
                Spacer()
            }
            .frame(height: MoleTokens.trafficRowHeight)
            .padding(.horizontal, 10)

            HStack(spacing: 8) {
                BrandMark()
                Text("Mole")
                    .font(MoleTokens.ui(13, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
            }
            .padding(.horizontal, 10)
            .frame(height: 46)

            VStack(spacing: 2) {
                ForEach(MoleDestination.sidebarPrimary) { item in
                    NavItem(
                        title: item.title,
                        symbol: item.symbol,
                        selected: sidebarSelection == item,
                        action: { destination = item }
                    )
                }
            }
            .padding(.horizontal, 10)

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                ForEach(MoleDestination.sidebarSecondary) { item in
                    NavItem(
                        title: item.title,
                        symbol: item.symbol,
                        selected: sidebarSelection == item,
                        action: { destination = item }
                    )
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
        }
        .frame(width: MoleTokens.sidebarWidth)
        .background(palette.canvas)
    }

    private var sidebarSelection: MoleDestination {
        switch destination {
        case .statusDetail, .firstRun: return .overview
        default: return destination
        }
    }
}

struct MoleToolbar: View {
    @Environment(\.molePalette) private var palette

    var destination: MoleDestination
    @ViewBuilder var trailing: () -> some View

    var body: some View {
        HStack(spacing: 12) {
            Text(destination == .statusDetail ? "Status" : destination.title)
                .font(MoleTokens.ui(15, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            Spacer(minLength: 0)
            trailing()
        }
        .padding(.horizontal, 20)
        .frame(height: MoleTokens.toolbarHeight)
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.border).frame(height: 1)
        }
    }
}

struct PlaceholderPage: View {
    @Environment(\.molePalette) private var palette

    var title: String
    var note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(MoleTokens.ui(24, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            Text(note)
                .font(MoleTokens.ui(13))
                .foregroundStyle(palette.textSecondary)
            Spacer()
        }
        .padding(MoleTokens.bodyPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(palette.canvas)
    }
}
