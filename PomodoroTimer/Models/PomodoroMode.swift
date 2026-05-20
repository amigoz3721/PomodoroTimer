import Foundation

enum PomodoroMode: String, Codable, CaseIterable {
    case work
    case shortBreak
    case longBreak

    var displayName: String {
        switch self {
        case .work: return LanguageManager.shared.loc("Focus")
        case .shortBreak: return LanguageManager.shared.loc("Short Break")
        case .longBreak: return LanguageManager.shared.loc("Long Break")
        }
    }

    var defaultDuration: TimeInterval {
        switch self {
        case .work: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }
}
