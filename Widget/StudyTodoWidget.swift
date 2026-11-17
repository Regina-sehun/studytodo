import WidgetKit
import SwiftUI

struct P0Entry: TimelineEntry {
    let date: Date
    let counter: Int
    let target: Date
    let hasGroup: Bool
    let net: String
}

struct P0Provider: TimelineProvider {
    static let netURL = URL(string: "https://www.cloudflare.com/cdn-cgi/trace")!

    func placeholder(in context: Context) -> P0Entry {
        P0Entry(date: Date(), counter: 7, target: Date().addingTimeInterval(3600), hasGroup: true, net: "…")
    }

    func getSnapshot(in context: Context, completion: @escaping (P0Entry) -> Void) {
        completion(currentEntry(net: "…"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<P0Entry>) -> Void) {
        Task {
            let net = await Self.fetchNet()
            let entry = currentEntry(net: net)
            let next = Date().addingTimeInterval(net.hasPrefix("✅") ? 15 * 60 : 2 * 60)
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    static func fetchNet() async -> String {
        var req = URLRequest(url: netURL)
        req.timeoutInterval = 10
        req.cachePolicy = .reloadIgnoringLocalCacheData
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let text = String(decoding: data, as: UTF8.self)
            let ip = text.split(separator: "\n").first { $0.hasPrefix("ip=") }?.dropFirst(3) ?? ""
            let colo = text.split(separator: "\n").first { $0.hasPrefix("colo=") }?.dropFirst(5) ?? ""
            return "✅ \(colo) \(ip)"
        } catch {
            return "❌ \(error.localizedDescription.prefix(40))"
        }
    }

    private func currentEntry(net: String) -> P0Entry {
        P0Entry(
            date: Date(),
            counter: SharedStore.counter,
            target: Date().addingTimeInterval(3600),
            hasGroup: SharedStore.groupContainerURL != nil,
            net: net
        )
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
            Text(entry.hasGroup ? "App Group：可用 ✅" : "App Group：不可用 ❌")
                .font(.caption2)
                .foregroundStyle(entry.hasGroup ? .green : .red)
            Text("网络：\(entry.net)")
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(entry.net.hasPrefix("✅") ? .green : .red)
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
