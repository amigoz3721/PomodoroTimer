import Foundation

struct SessionRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let mode: PomodoroMode

    init(id: UUID = UUID(), date: Date = Date(), duration: TimeInterval, mode: PomodoroMode) {
        self.id = id
        self.date = date
        self.duration = duration
        self.mode = mode
    }
}
