import Foundation

final class StatisticsStore: ObservableObject {
    @Published private(set) var records: [SessionRecord] = []

    private let fileName = "pomodoro_records.json"

    private var fileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("PomodoroTimer")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func addRecord(_ record: SessionRecord) {
        records.append(record)
        save()
    }

    var todayCount: Int {
        records.filter { Calendar.current.isDateInToday($0.date) }.count
    }

    var weekCount: Int {
        records.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }.count
    }

    var recentRecords: [SessionRecord] {
        Array(records.sorted { $0.date > $1.date }.prefix(50))
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data)
        else { return }
        records = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
