import Foundation
import SwiftData
import WidgetKit

enum SyncStatus {
    static var text: String {
        get { UserDefaults.standard.string(forKey: "sync.status") ?? "未同步" }
        set { UserDefaults.standard.set(newValue, forKey: "sync.status") }
    }
}

@MainActor
enum Syncer {
    static func push(tasks: [TodoTask]) async {
        guard SyncConfig.isConfigured else {
            SyncStatus.text = "未配置密钥"
            return
        }
        let snap = Snapshot(
            v: 1,
            updatedAt: Date().timeIntervalSince1970,
            tasks: tasks.map(\.dto)
        )
        do {
            try await SyncClient.push(snap)
            SyncStatus.text = "已同步 \(Date().formatted(date: .omitted, time: .shortened))"
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            SyncStatus.text = "同步失败：\(error.localizedDescription)"
        }
    }

    static func pullIfEmpty(context: ModelContext) async {
        let existing = (try? context.fetch(FetchDescriptor<TodoTask>())) ?? []
        guard existing.isEmpty else { return }
        guard let snap = try? await SyncClient.fetch(), !snap.tasks.isEmpty else { return }
        for dto in snap.tasks {
            let t = TodoTask(
                title: dto.title,
                target: Date(timeIntervalSince1970: dto.target),
                deadline: Date(timeIntervalSince1970: dto.deadline),
                colorIndex: dto.color,
                repeatRule: dto.repeatRule
            )
            t.isDone = dto.done
            t.doneAt = dto.doneAt.map(Date.init(timeIntervalSince1970:))
            context.insert(t)
        }
        try? context.save()
        SyncStatus.text = "已从云端恢复 \(snap.tasks.count) 条"
    }

    static func testConnection() async -> String {
        do {
            if let snap = try await SyncClient.fetch() {
                return "✅ 已连接，云端 \(snap.tasks.count) 条"
            }
            return "✅ 已连接，云端为空"
        } catch {
            return "❌ \(error.localizedDescription)"
        }
    }
}
