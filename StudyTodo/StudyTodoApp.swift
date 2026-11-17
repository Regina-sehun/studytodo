import SwiftUI
import SwiftData

@main
struct StudyTodoApp: App {
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
        .modelContainer(for: TodoTask.self)
    }
}
