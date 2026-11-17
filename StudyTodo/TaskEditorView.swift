import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (TodoTask) -> Void

    @State private var title = ""
    @State private var target = Date().addingTimeInterval(3600)
    @State private var deadline = Date().addingTimeInterval(86400)
    @State private var repeatRule = 0
    @State private var colorIndex = 0

    private var valid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && target <= deadline
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("任务") {
                    TextField("要学什么？", text: $title)
                }

                Section("目标完成时间") {
                    DatePicker("日期与时间", selection: $target, displayedComponents: [.date, .hourAndMinute])
                        .environment(\.locale, Locale(identifier: "zh_CN"))
                }

                Section("截止时间") {
                    DatePicker("日期与时间", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                        .environment(\.locale, Locale(identifier: "zh_CN"))
                    if target > deadline {
                        Text("截止时间不能早于目标时间")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section("重复") {
                    Picker("重复方式", selection: $repeatRule) {
                        ForEach(Theme.repeatNames.indices, id: \.self) { index in
                            Text(Theme.repeatNames[index]).tag(index)
                        }
                    }
                }

                Section("颜色") {
                    HStack(spacing: 14) {
                        ForEach(Theme.colors.indices, id: \.self) { index in
                            Circle()
                                .fill(Theme.colors[index])
                                .frame(width: 28, height: 28)
                                .overlay {
                                    if index == colorIndex {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture { colorIndex = index }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("新任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let task = TodoTask(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            target: target,
                            deadline: deadline,
                            colorIndex: colorIndex,
                            repeatRule: repeatRule
                        )
                        onSave(task)
                        dismiss()
                    }
                    .disabled(!valid)
                }
            }
        }
    }
}
