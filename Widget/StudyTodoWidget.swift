import WidgetKit
import SwiftUI

struct TodoEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskDTO]
    let offline: Bool
}

struct TodoProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(date: Date(), tasks: [
            TaskDTO(id: "1", title: "背 50 个单词", target: Date().addingTimeInterval(3600).timeIntervalSince1970,
                    deadline: Date().addingTimeInterval(7200).timeIntervalSince1970, color: 0,
                    repeatRule: 0, done: false, doneAt: nil, createdAt: Date().timeIntervalSince1970),
            TaskDTO(id: "2", title: "高数第三章习题", target: Date().addingTimeInterval(7200).timeIntervalSince1970,
                    deadline: Date().addingTimeInterval(86400).timeIntervalSince1970, color: 3,
                    repeatRule: 0, done: false, doneAt: nil, createdAt: Date().timeIntervalSince1970)
        ], offline: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
        Task {
            var tasks: [TaskDTO] = []
            var offline = false
            do {
                let snap = try await SyncClient.fetch()
                tasks = (snap?.tasks ?? []).filter { !$0.done }.sorted { $0.target < $1.target }
            } catch {
                offline = true
            }
            let entry = TodoEntry(date: Date(), tasks: tasks, offline: offline)
            let next = Date().addingTimeInterval(offline ? 120 : 600)
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }
}

struct TodoWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: TodoEntry

    private var limit: Int {
        switch family {
        case .systemSmall: return 2
        case .systemMedium: return 3
        default: return 8
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("StudyTodo")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                if entry.offline {
                    Text("离线")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            if entry.tasks.isEmpty {
                Spacer(minLength: 0)
                Text(entry.offline ? "打开 App 联网同步" : "暂无待办 🎉")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            } else {
                ForEach(entry.tasks.prefix(limit)) { task in
                    TaskRow(task: task, date: entry.date)
                }
                if entry.tasks.count > limit {
                    Text("还有 \(entry.tasks.count - limit) 项…")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            Color(red: 0.97, green: 0.98, blue: 1.0)
        }
    }
}

private struct TaskRow: View {
    let task: TaskDTO
    let date: Date

    var body: some View {
        let target = Date(timeIntervalSince1970: task.target)
        HStack(spacing: 6) {
            Circle()
                .fill(Theme.color(task.color))
                .frame(width: 7, height: 7)
            Text(task.title)
                .font(.footnote.weight(.medium))
                .lineLimit(1)
            Spacer(minLength: 4)
            if target > date {
                Text(timerInterval: date...target, countsDown: true)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(Theme.color(task.color))
            } else {
                Text("已超时")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }
}

struct StudyTodoWidget: Widget {
    let kind = "StudyTodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { entry in
            TodoWidgetView(entry: entry)
        }
        .configurationDisplayName("StudyTodo 待办")
        .description("显示最近的待办任务和倒计时")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct StudyTodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        StudyTodoWidget()
    }
}
