import Foundation

enum RecoveryAction: String, Codable, Equatable {
    case permanent
    case trash
    case rebuild
    case none
}

enum SizeState: String, Codable, Equatable {
    case measured
    case partial
    case unavailable
}

enum Eligibility: String, Codable, Equatable {
    case ready
    case kept
    case running
    case protected
    case partial
    case unavailable
    case failed
}

struct PathIdentity: Codable, Equatable {
    var dev: Int
    var ino: Int
    var mtime: Int
}

struct ProtocolCandidate: Codable, Equatable, Identifiable {
    var id: String
    var name: String
    var paths: [String]
    var sizeBytes: Int?
    var sizeState: SizeState
    var eligibility: Eligibility
    var action: RecoveryAction
    var reason: String?
    var requiresAdmin: Bool
    var identity: PathIdentity?

    enum CodingKeys: String, CodingKey {
        case id, name, paths, reason, identity, action, eligibility
        case sizeBytes = "size_bytes"
        case sizeState = "size_state"
        case requiresAdmin = "requires_admin"
    }
}

struct ProtocolEvent: Codable, Equatable {
    var protocolVersion: Int
    var event: String
    var operationId: String
    var ts: String

    enum CodingKeys: String, CodingKey {
        case event, ts
        case protocolVersion = "protocol_version"
        case operationId = "operation_id"
    }
}

struct OverviewSnapshot: Equatable {
    var freeSpace: String
    var lastScan: String
    var lastScanStale: Bool
    var healthScore: String
    var healthHint: String
    var reclaimable: String
    var reclaimableHint: String
    var applications: String
    var applicationsHint: String
    var applicationsHintReview: Bool
    var recommendations: [OverviewRecommendation]
    var activity: [OverviewActivity]
}

struct OverviewRecommendation: Equatable, Identifiable {
    var id: String
    var title: String
    var icon: MoleSymbol
    var destination: MoleDestination
}

struct OverviewActivity: Equatable, Identifiable {
    var id: String
    var command: String
    var detail: String
    var time: String
}

extension MoleSymbol: Equatable {}
