import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.state == .idle ? Color.secondary.opacity(0.3) : theme.accentColor(for: viewModel.mode))
                    .frame(width: 8, height: 8)

                Text(viewModel.mode == .work ? lang.loc("Focus") : viewModel.mode == .shortBreak ? lang.loc("Short Break") : lang.loc("Long Break"))
                    .font(.headline)
            }

            Text(formatTime(viewModel.remainingSeconds))
                .font(.system(size: 32, weight: .medium, design: .monospaced))

            HStack(spacing: 12) {
                if viewModel.state == .running {
                    Button(action: { viewModel.pause() }) {
                        Image(systemName: "pause.fill")
                            .frame(width: 32, height: 24)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.accentColor(for: viewModel.mode))
                } else {
                    Button(action: { viewModel.start() }) {
                        Image(systemName: "play.fill")
                            .frame(width: 32, height: 24)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.accentColor(for: viewModel.mode))
                }

                Button(action: { viewModel.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.state == .idle && viewModel.remainingSeconds == 0)
            }

            Text("\(viewModel.completedSessions) / \(lang.loc("Today"))")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            Button(lang.loc("Show Window")) {
                AppDelegate.current?.showMainWindow()
            }
            .buttonStyle(.bordered)

            Button(lang.loc("Settings")) {
                AppNavigator.shared.openSettings()
            }
            .buttonStyle(.bordered)

            Button(lang.loc("Statistics")) {
                AppNavigator.shared.openStatistics()
            }
            .buttonStyle(.bordered)

            Divider()

            Button(lang.loc("Quit")) {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(16)
        .frame(width: 220)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
