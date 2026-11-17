import Foundation

enum SyncConfig {
    static let endpoint = URL(string: "https://studytodo-sync.pages.dev")!
    static var key: String { SyncKey.value }
    static var isConfigured: Bool { !key.hasPrefix("dev-local-key") }
}

struct TaskDTO: Codable, Identifiable {
    var id: String
    var title: String
    var target: Double
    var deadline: Double
    var color: Int
    var repeatRule: Int
    var done: Bool
    var doneAt: Double?
    var createdAt: Double
}

struct Snapshot: Codable {
    var v: Int
    var updatedAt: Double
    var tasks: [TaskDTO]
}

enum SyncError: LocalizedError {
    case http(Int)

    var errorDescription: String? {
        switch self {
        case .http(let code): return "HTTP \(code)"
        }
    }
}

enum SyncClient {
    static func fetch(key: String = SyncConfig.key) async throws -> Snapshot? {
        var comps = URLComponents(url: SyncConfig.endpoint, resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "k", value: key)]
        var req = URLRequest(url: comps.url!)
        req.timeoutInterval = 15
        req.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw SyncError.http((resp as? HTTPURLResponse)?.statusCode ?? -1)
        }
        guard let snap = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return nil
        }
        return snap
    }

    static func push(_ snap: Snapshot, key: String = SyncConfig.key) async throws {
        var comps = URLComponents(url: SyncConfig.endpoint, resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "k", value: key)]
        var req = URLRequest(url: comps.url!)
        req.httpMethod = "PUT"
        req.timeoutInterval = 15
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(snap)
        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw SyncError.http((resp as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }
}
