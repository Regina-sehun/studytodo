import SwiftUI
import UserNotifications
import WidgetKit

struct ContentView: View {
    @AppStorage("p0.counter", store: SharedStore.defaults) private var counter: Int = 0

    @State private var notifStatus = "检查中…"
    private let countdownEnd = Date().addingTimeInterval(3600)

    var body: some View {
        NavigationStack {
            Form {
                Section("① 数据共享冒烟测试") {
                    Stepper("共享计数器：\(counter)", value: $counter, in: 0...999)
                    Text("去桌面看一眼 StudyTodo 小组件，数字应该同步为 \(counter)。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if let t = SharedStore.updatedAt {
                        Text("最近写入：\(t.formatted(date: .abbreviated, time: .standard))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("② 实时倒计时冒烟测试") {
                    Text(timerInterval: Date().addingTimeInterval(-1)...countdownEnd, countsDown: true)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text("App 内应秒级跳动；小组件里同样应跳动。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("③ 通知权限") {
                    HStack {
                        Text("状态")
                        Spacer()
                        Text(notifStatus).foregroundStyle(.secondary)
                    }
                    Button("请求通知权限") {
                        requestNotif()
                    }
                }

                Section("④ AlarmKit（iOS 26 闹钟能力）") {
                    alarmKitStatus
                }
            }
            .navigationTitle("StudyTodo · P0")
            .onAppear(perform: refreshNotifStatus)
            .onChange(of: counter) { _, _ in
                SharedStore.updatedAt = Date()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    @ViewBuilder
    private var alarmKitStatus: some View {
        #if canImport(AlarmKit)
        Text("当前 SDK 包含 AlarmKit ✅（P3 阶段接入真闹钟）")
        #else
        Text("当前构建没有 AlarmKit ❌（将降级为普通通知）")
        #endif
    }

    private func requestNotif() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                DispatchQueue.main.async {
                    refreshNotifStatus()
                }
            }
    }

    private func refreshNotifStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let text: String
            switch settings.authorizationStatus {
            case .authorized: text = "已授权 ✅"
            case .denied: text = "已拒绝 ❌"
            case .notDetermined: text = "未请求"
            case .provisional: text = "临时授权"
            case .ephemeral: text = "临时授权"
            @unknown default: text = "未知"
            }
            DispatchQueue.main.async {
                notifStatus = text
            }
        }
    }
}
