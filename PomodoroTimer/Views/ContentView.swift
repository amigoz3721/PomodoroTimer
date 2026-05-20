import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = PomodoroViewModel.shared
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        VStack(spacing: 24) {
            modePicker

            timerCircle

            controls

            Text(lang.loc("%lld sessions completed", viewModel.completedSessions))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(32)
        .frame(minWidth: 320, maxWidth: 400, minHeight: 420)
        .preferredColorScheme(theme.colorSchemeMode.scheme)
        .timerFinishedAlert()
        .onAppear { updateWindowTitle() }
        .onChange(of: lang.appLanguage) { _ in updateWindowTitle() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu(lang.loc("Menu"), systemImage: "ellipsis.circle") {
                    Button(lang.loc("Settings")) { AppNavigator.shared.openSettings() }
                    Button(lang.loc("Statistics")) { AppNavigator.shared.openStatistics() }
                }
            }
        }
    }

    private var modePicker: some View {
        Picker(lang.loc("Mode"), selection: $viewModel.mode) {
            modeItem(.work)
            modeItem(.shortBreak)
            modeItem(.longBreak)
        }
        .pickerStyle(.segmented)
        .disabled(viewModel.state != .idle)
        .onChange(of: viewModel.mode) { _ in
            viewModel.reset()
        }
    }

    private func modeItem(_ mode: PomodoroMode) -> some View {
        let key = switch mode {
        case .work: "Focus"
        case .shortBreak: "Short Break"
        case .longBreak: "Long Break"
        }
        return Text(lang.loc(key))
            .tag(mode)
            .id("\(lang.appLanguage)-\(mode.rawValue)")
    }

    private var timerCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: 12)

            Circle()
                .trim(from: 0, to: viewModel.progressFraction)
                .stroke(
                    theme.accentColor(for: viewModel.mode),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: viewModel.progressFraction)

            VStack(spacing: 4) {
                Text(formatTime(viewModel.remainingSeconds))
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)

                Text(statusLabel)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 240, height: 240)
    }

    private var statusLabel: String {
        switch viewModel.state {
        case .running: return lang.loc("Running")
        case .paused: return lang.loc("Paused")
        case .idle: return lang.loc("Ready")
        }
    }

    private var controls: some View {
        HStack(spacing: 20) {
            Button(action: {
                switch viewModel.state {
                case .idle, .paused: viewModel.start()
                case .running: viewModel.pause()
                }
            }) {
                Label(
                    viewModel.state == .running ? lang.loc("Pause") : lang.loc("Start"),
                    systemImage: viewModel.state == .running ? "pause.fill" : "play.fill"
                )
                .frame(minWidth: 80)
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.accentColor(for: viewModel.mode))
            .controlSize(.large)

            Button(action: { viewModel.reset() }) {
                Label(lang.loc("Reset"), systemImage: "arrow.counterclockwise")
                    .frame(minWidth: 80)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(viewModel.state == .idle && viewModel.remainingSeconds == 0)
        }
    }

    private func updateWindowTitle() {
        for window in NSApp.windows {
            window.title = lang.loc("Pomodoro Timer")
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
