import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var backendStatus = "未测试"
    @State private var groupOK = SharedStore.groupContainerURL != nil

    var body: some View {
        NavigationStack {
            Form {
                Section("云同步") {
                    LabeledContent("状态", value: SyncStatus.text)
                    LabeledContent("密钥", value: SyncConfig.isConfigured ? "已配置" : "未配置（构建时注入）")
                    Button("测试后端连接") {
                        backendStatus = "测试中…"
                        Task { backendStatus = await Syncer.testConnection() }
                    }
                    LabeledContent("后端", value: backendStatus)
                }

                Section("诊断") {
                    LabeledContent("App Group", value: groupOK ? "可用 ✅" : "不可用（免费签名限制）")
                    LabeledContent("小组件数据源", value: "云端快照")
                }

                Section("说明") {
                    Text("任务保存在本机；每次修改会自动上传一份快照到云端，供桌面小组件读取。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
