import Foundation
import SwiftData

@Model
final class TodoTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var target: Date
    var deadline: Date
    var colorIndex: Int
    var repeatRule: Int
    var isDone: Bool
    var doneAt: Date?
    var createdAt: Date

    init(title: String, target: Date, deadline: Date, colorIndex: Int, repeatRule: Int) {
        self.id = UUID()
        self.title = title
        self.target = target
        self.deadline = deadline
        self.colorIndex = colorIndex
        self.repeatRule = repeatRule
        self.isDone = false
        self.doneAt = nil
        self.createdAt = Date()
    }

    var dto: TaskDTO {
        TaskDTO(
            id: id.uuidString,
            title: title,
            target: target.timeIntervalSince1970,
            deadline: deadline.timeIntervalSince1970,
            color: colorIndex,
            repeatRule: repeatRule,
            done: isDone,
            doneAt: doneAt?.timeIntervalSince1970,
            createdAt: createdAt.timeIntervalSince1970
        )
    }
}
