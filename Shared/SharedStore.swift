import Foundation

/// App 与小组件之间的共享存储（App Group）。
/// P0 用共享计数器验证桥接；P1 起换成真正的任务数据。
enum SharedStore {
    static let appGroupID = "group.com.regina0317.studytodo"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static var counter: Int {
        get { defaults.integer(forKey: "p0.counter") }
        set { defaults.set(newValue, forKey: "p0.counter") }
    }

    static var updatedAt: Date? {
        get { defaults.object(forKey: "p0.updatedAt") as? Date }
        set { defaults.set(newValue, forKey: "p0.updatedAt") }
    }

    /// nil 表示当前签名没有 App Group 权限（容器不可用）。
    static var groupContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    static var groupContainerPath: String {
        groupContainerURL?.path ?? "nil（无 App Group 权限）"
    }
}
