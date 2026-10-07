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
        if let bundled = Bundle.main.url(forAuxiliaryExecutable: "mo")
            ?? Bundle.main.url(forAuxiliaryExecutable: "mole") {
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

    func analyzeJSON(path: String? = nil) async throws -> Data {
        var arguments = ["analyze", "--json"]
        if let path {
            arguments.append(path)
        }
        return try await run(arguments: arguments)
    }

    func protocolPlan(operation: String, paths: [String]) async throws -> Data {
        var arguments = ["protocol", "plan", "--operation", operation]
        for path in paths {
            arguments.append(contentsOf: ["--path", path])
        }
        return try await run(arguments: arguments)
    }

    func protocolExecute(planId: String, candidateIds: [String] = []) async throws -> Data {
        var arguments = ["protocol", "execute", "--plan-id", planId]
        for id in candidateIds {
            arguments.append(contentsOf: ["--id", id])
        }
        return try await run(arguments: arguments)
    }

    func protocolCancel(planId: String) async throws -> Data {
        try await run(arguments: ["protocol", "cancel", "--plan-id", planId])
    }

    /// Plan/execute NDJSON. Paths on execute are rejected by the engine.
    func protocolNDJSON(arguments: [String]) async throws -> Data {
        try await run(arguments: ["protocol"] + arguments)
    }

    /// Line-delimited NDJSON for plan/execute/watch. Prefer this over `run` once
    /// family scans stream events; `run` still buffers whole stdout.
    func protocolEventLines(arguments: [String]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let data = try await self.run(arguments: ["protocol"] + arguments)
                    let text = String(data: data, encoding: .utf8) ?? ""
                    for line in text.split(whereSeparator: \.isNewline) {
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            continuation.yield(String(trimmed))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func run(arguments: [String]) async throws -> Data {
        let cli = try resolveCLI()
        return try await Task.detached(priority: .userInitiated) {
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
        }.value
    }
}
