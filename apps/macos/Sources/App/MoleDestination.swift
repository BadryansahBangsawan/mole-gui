import Foundation

enum MoleDestination: String, Hashable, CaseIterable, Identifiable {
    case overview
    case clean
    case applications
    case diskExplorer
    case projects
    case maintenance
    case history
    case settings
    case statusDetail
    case firstRun

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
        case .statusDetail: return "Status"
        case .firstRun: return "Welcome"
        }
    }

    var symbol: MoleSymbol {
        switch self {
        case .overview, .statusDetail: return .layoutDashboard
        case .clean: return .sparkles
        case .applications: return .appWindow
        case .diskExplorer: return .hardDrive
        case .projects: return .folderGit
        case .maintenance: return .wrench
        case .history: return .history
        case .settings: return .settings
        case .firstRun: return .sparkles
        }
    }

    static let sidebarPrimary: [MoleDestination] = [
        .overview, .clean, .applications, .diskExplorer, .projects, .maintenance
    ]

    static let sidebarSecondary: [MoleDestination] = [
        .history, .settings
    ]

    var isSidebarItem: Bool {
        Self.sidebarPrimary.contains(self) || Self.sidebarSecondary.contains(self)
    }
}
