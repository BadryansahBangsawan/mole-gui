import Foundation

/// Spawns `mo protocol` / `mo status --json` / `mo history --json`.
/// Never parse TUI or ANSI. Never spawn raw `mo clean` / installer / purge / uninstall.
actor MoleClient {
    enum ClientError: Error {
        case cliMissing
        case invalidJSON
        case protocolFailed(String)
    }

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    /// Bundled CLI next to the app, else PATH. Never run as root.
    func resolveCLI() throws -> URL {
        if let bundled = Bundle.main.url(forAuxiliaryExecutable: "mo") ?? Bundle.main.url(forAuxiliaryExecutable: "mole") {
            return bundled
        }
        let path = ProcessInfo.processInfo.environment["PATH"] ?? ""
        for dir in path.split(separator: ":") {
            for name in ["mo", "mole"] {
                let candidate = URL(fileURLWithPath: String(dir)).appendingPathComponent(String(name))
                if fileManager.isExecutableFile(atPath: candidate.path) {
                    return candidate
                }
            }
        }
        throw ClientError.cliMissing
    }

    func describeHistory(limit: Int = 20) async throws -> Data {
        try await run(arguments: ["protocol", "describe", "--operation", "history", "--limit", String(limit)])
    }

    func statusJSON() async throws -> Data {
        try await run(arguments: ["status", "--json"])
    }

    /// Plan/execute NDJSON. Paths on execute are rejected by the engine.
    func protocolNDJSON(arguments: [String]) async throws -> Data {
        try await run(arguments: ["protocol"] + arguments)
    }

    private func run(arguments: [String]) async throws -> Data {
        let cli = try resolveCLI()
        let process = Process()
        process.executableURL = cli
        process.arguments = arguments
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()
        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        if process.terminationStatus != 0 {
            let err = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw ClientError.protocolFailed(err)
        }
        return data
    }
}
