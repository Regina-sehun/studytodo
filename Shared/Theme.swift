import SwiftUI

enum Theme {
    static let colors: [Color] = [
        Color(red: 0.36, green: 0.60, blue: 0.98),
        Color(red: 0.98, green: 0.45, blue: 0.42),
        Color(red: 0.35, green: 0.78, blue: 0.55),
        Color(red: 0.95, green: 0.66, blue: 0.30),
        Color(red: 0.62, green: 0.47, blue: 0.92),
        Color(red: 0.30, green: 0.75, blue: 0.85),
        Color(red: 0.94, green: 0.55, blue: 0.75),
        Color(red: 0.55, green: 0.56, blue: 0.62)
    ]

    static func color(_ index: Int) -> Color {
        colors[abs(index) % colors.count]
    }

    static let repeatNames = ["不重复", "每天", "工作日"]
}
