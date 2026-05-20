import SwiftUI

struct StatisticsView: View {
    @ObservedObject var store: StatisticsStore
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Text(lang.loc("Statistics"))
                .font(.title2)
                .bold()

            HStack(spacing: 40) {
                statBox(value: "\(store.todayCount)", label: lang.loc("Today"))
                statBox(value: "\(store.weekCount)", label: lang.loc("This Week"))
                statBox(value: "\(store.records.count)", label: lang.loc("Total"))
            }

            Divider()

            if store.recentRecords.isEmpty {
                Text(lang.loc("No sessions yet"))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                Table(store.recentRecords) {
                    TableColumn(lang.loc("Date")) { record in
                        Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    }
                    TableColumn(lang.loc("Mode")) { record in
                        Text(record.mode.displayName)
                    }
                    TableColumn(lang.loc("Duration")) { record in
                        Text(formatDuration(record.duration))
                    }
                }
                .tableStyle(.inset)
                .frame(minHeight: 200)
            }

            Button(lang.loc("Done")) {
                NSApp.keyWindow?.close()
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.theme.swatchColor)
        }
        .padding(24)
        .frame(width: 520, height: 420)
        .preferredColorScheme(theme.colorSchemeMode.scheme)
    }

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(theme.theme.swatchColor)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        return lang.loc("%lld min", m)
    }
}
