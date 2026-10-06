import SwiftUI

@main
struct MoleApp: App {
    var body: some Scene {
        WindowGroup("Mole") {
            MoleRootView()
                .frame(
                    minWidth: MoleTokens.minWindowWidth,
                    minHeight: MoleTokens.minWindowHeight
                )
        }
        .defaultSize(width: MoleTokens.windowWidth, height: MoleTokens.windowHeight)
    }
}

enum MoleDestination: String, Hashable, CaseIterable, Identifiable {
    case overview
    case clean
    case applications
    case diskExplorer
    case projects
    case maintenance
    case history
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .clean: return "Clean"
        case .applications: return "Applications"
        case .diskExplorer: return "Disk Explorer"
        case .projects: return "Projects"
        case .maintenance: return "Maintenance"
        case .history: return "History"
        case .settings: return "Settings"
        }
    }
}

struct MoleRootView: View {
    @State private var destination: MoleDestination = .overview

    var body: some View {
        NavigationSplitView {
            List(MoleDestination.allCases, selection: $destination) { item in
                Text(item.title).tag(item)
            }
            .navigationSplitViewColumnWidth(MoleTokens.sidebarWidth)
            .background(MoleTokens.Light.canvas)
        } detail: {
            switch destination {
            case .overview:
                OverviewView()
            default:
                ContentUnavailableView(
                    destination.title,
                    systemImage: "hammer",
                    description: Text("Wired in a later phase. Mutations go through mo protocol.")
                )
            }
        }
        .background(MoleTokens.Light.canvas)
    }
}
