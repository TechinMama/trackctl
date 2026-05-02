import Foundation
import Sentry

/// Lightweight structured event logger. Writes JSON lines to a rolling file in
/// the app's Caches directory and forwards warnings/errors to Sentry.
///
/// Usage:
///   AthenaLogger.shared.event("athlete_followed", props: ["id": athleteID])
///   AthenaLogger.shared.error("api_failure", error: err, props: ["path": "/athletes"])
final class AthenaLogger: @unchecked Sendable {
    static let shared = AthenaLogger()

    enum Level: String {
        case info, warning, error
    }

    private let queue = DispatchQueue(label: "com.athena.logger", qos: .utility)
    private let maxFileSizeBytes = 512 * 1024   // 512 KB rolling limit
    private let logFileName = "athena-events.jsonl"
    private let sentryEnabled: Bool

    private var logFileURL: URL? {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(logFileName)
    }

    private init() {
        let dsn = (Bundle.main.object(forInfoDictionaryKey: "SentryDSN") as? String ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        sentryEnabled = !dsn.isEmpty
    }

    // MARK: - Public API

    func event(_ name: String, props: [String: Any] = [:]) {
        write(level: .info, name: name, props: props)
    }

    func warning(_ name: String, props: [String: Any] = [:]) {
        write(level: .warning, name: name, props: props)
        guard sentryEnabled else { return }
        let crumb = Breadcrumb(level: .warning, category: "athena")
        crumb.message = name
        crumb.data = props.mapValues { "\($0)" }
        SentrySDK.addBreadcrumb(crumb)
    }

    func error(_ name: String, error: Error? = nil, props: [String: Any] = [:]) {
        var merged = props
        if let error { merged["error"] = error.localizedDescription }
        write(level: .error, name: name, props: merged)
        guard sentryEnabled else { return }
        SentrySDK.capture(message: name) { scope in
            scope.setTag(value: "error", key: "level")
            merged.forEach { scope.setExtra(value: $0.value, key: $0.key) }
            if let error { scope.setExtra(value: error.localizedDescription, key: "underlying_error") }
        }
    }

    // MARK: - Read / export

    /// Returns the last `limit` log lines as raw strings (for a debug screen or support export).
    func recentLines(limit: Int = 100) -> [String] {
        guard let url = logFileURL,
              let content = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
        return Array(lines.suffix(limit))
    }

    // MARK: - Private

    private func write(level: Level, name: String, props: [String: Any]) {
        queue.async { [weak self] in
            guard let self else { return }
            var record: [String: Any] = [
                "ts": ISO8601DateFormatter().string(from: Date()),
                "level": level.rawValue,
                "event": name
            ]
            for (key, value) in props {
                record[key] = value
            }
            guard let data = try? JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]),
                  var line = String(data: data, encoding: .utf8) else { return }
            line += "\n"

            guard let url = self.logFileURL else { return }
            let fileManager = FileManager.default

            if !fileManager.fileExists(atPath: url.path) {
                fileManager.createFile(atPath: url.path, contents: nil)
            }

            // Rolling: truncate first half of file when size limit hit
            if let attrs = try? fileManager.attributesOfItem(atPath: url.path),
               let size = attrs[.size] as? Int, size > self.maxFileSizeBytes,
               let content = try? String(contentsOf: url, encoding: .utf8) {
                let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
                let trimmed = lines.dropFirst(lines.count / 2).joined(separator: "\n") + "\n"
                try? trimmed.write(to: url, atomically: true, encoding: .utf8)
            }

            if let handle = try? FileHandle(forWritingTo: url) {
                handle.seekToEndOfFile()
                if let bytes = line.data(using: .utf8) {
                    handle.write(bytes)
                }
                try? handle.close()
            }
        }
    }
}
