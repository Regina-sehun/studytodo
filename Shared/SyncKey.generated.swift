import Foundation

// 构建时由 CI 用仓库 Secret（SYNC_KEY）覆盖；此默认值只用于本地构建。
enum SyncKey {
    static let value = "dev-local-key-please-set-SYNC_KEY-secret"
}
