import SwiftUI
import SwiftData
import WidgetKit

struct TaskListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoTask.target) private var tasks: [TodoTask]

    @State private var showEditor = false
    @State private var showSettings = false
    @State private var pushWork: Task<Void, Never>?

    private var pending: [TodoTask] { tasks.filter { !$0.isDone } }
    private var finished: [TodoTask] { tasks.filter(\.isDone) }

    var body: some View {
        NavigationStack {
            List {
                if pending.isEmpty && finished.isEmpty {
                    ContentUnavailableView(
                        "还没有待办",
                        systemImage: "checklist",
                        description: Text("点右上角 + 添加第一个学习任务")
                    )
                }

                if !pending.isEmpty {
                    Section("待完成") {
                        ForEach(pending) { task in
                            row(task)
                        }
                        .onDelete { delete($0, in: pending) }
                    }
                }

                if !finished.isEmpty {
                    Section("已完成") {
                        ForEach(finished) { task in
                            row(task)
                        }
                        .onDelete { delete($0, in: finished) }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("StudyTodo")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showEditor = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                TaskEditorView { task in
                    context.insert(task)
                    save()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .task {
                await Syncer.pullIfEmpty(context: context)
            }
        }
    }

    private func row(_ task: TodoTask) -> some View {
        TaskRowView(task: task) {
            task.isDone.toggle()
            task.doneAt = task.isDone ? Date() : nil
            save()
        }
    }

    private func delete(_ offsets: IndexSet, in list: [TodoTask]) {
        for index in offsets {
            context.delete(list[index])
        }
        save()
    }

    private func save() {
        try? context.save()
        pushWork?.cancel()
        let snapshot = tasks
        pushWork = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await Syncer.push(tasks: snapshot)
        }
    }
}

struct TaskRowView: View {
    let task: TodoTask
    let toggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Theme.color(task.colorIndex))
                .frame(width: 5)

            Button(action: toggle) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isDone ? Theme.color(task.colorIndex) : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? .secondary : .primary)

                HStack(spacing: 8) {
                    if task.target > .now {
                        Text(timerInterval: Date()...task.target, countsDown: true)
                            .monospacedDigit()
                            .foregroundStyle(Theme.color(task.colorIndex))
                    } else {
                        Text("已过目标时间")
                            .foregroundStyle(.orange)
                    }
                    Text("截止 \(task.deadline.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }

            Spacer(minLength: 0)

            if task.repeatRule > 0 {
                Image(systemName: "arrow.2.squarepath")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
