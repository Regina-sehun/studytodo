import WidgetKit
import SwiftUI

struct P0Entry: TimelineEntry {
    let date: Date
    let counter: Int
    let target: Date
}

struct P0Provider: TimelineProvider {
    func placeholder(in context: Context) -> P0Entry {
        P0Entry(date: Date(), counter: 7, target: Date().addingTimeInterval(3600))
    }

    func getSnapshot(in context: Context, completion: @escaping (P0Entry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<P0Entry>) -> Void) {
        let entry = currentEntry()
        let next = Date().addingTimeInterval(15 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func currentEntry() -> P0Entry {
        P0Entry(date: Date(), counter: SharedStore.counter, target: Date().addingTimeInterval(3600))
    }
}

struct P0WidgetView: View {
    var entry: P0Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("StudyTodo · P0")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("共享计数：\(entry.counter)")
                .font(.system(.title3, design: .rounded).weight(.semibold))
            Text(timerInterval: entry.date...entry.target, countsDown: true)
                .font(.system(.body, design: .rounded).monospacedDigit())
            Spacer(minLength: 0)
            Text("实时倒计时冒烟")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            Color(red: 0.97, green: 0.98, blue: 1.0)
        }
    }
}

struct StudyTodoWidget: Widget {
    let kind = "StudyTodoP0Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: P0Provider()) { entry in
            P0WidgetView(entry: entry)
        }
        .configurationDisplayName("StudyTodo 冒烟测试")
        .description("验证小组件与 App 的数据互通和实时倒计时")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct StudyTodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        StudyTodoWidget()
    }
}
