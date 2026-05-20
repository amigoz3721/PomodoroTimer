import Foundation
import Combine
import SwiftUI

final class PomodoroViewModel: ObservableObject {
    static let shared = PomodoroViewModel()

    // MARK: - Published state
    @Published var mode: PomodoroMode = .work
    @Published var state: PomodoroState = .idle
    @Published var remainingSeconds: TimeInterval = 0
    @Published var completedSessions: Int = 0

    // MARK: - Settings (AppStorage)
    @AppStorage("workDuration") var workDuration: TimeInterval = 25 * 60
    @AppStorage("shortBreakDuration") var shortBreakDuration: TimeInterval = 5 * 60
    @AppStorage("longBreakDuration") var longBreakDuration: TimeInterval = 15 * 60
    @AppStorage("longBreakInterval") var longBreakInterval: Int = 4

    let statisticsStore = StatisticsStore()

    private var timer: AnyCancellable?
    private var workSessionCount: Int = 0

    var progressFraction: Double {
        let total = durationFor(mode)
        guard total > 0 else { return 0 }
        return 1.0 - (remainingSeconds / total)
    }

    // MARK: - Actions

    func start() {
        if state == .idle {
            remainingSeconds = durationFor(mode)
        }
        state = .running
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        state = .paused
        timer?.cancel()
        timer = nil
    }

    func reset() {
        state = .idle
        timer?.cancel()
        timer = nil
        remainingSeconds = 0
    }

    // MARK: - Private

    private func tick() {
        guard remainingSeconds > 0 else {
            completeSession()
            return
        }
        remainingSeconds -= 1
    }

    private func completeSession() {
        timer?.cancel()
        timer = nil

        let finishedMode = mode

        // Record session
        let record = SessionRecord(duration: durationFor(finishedMode), mode: finishedMode)
        statisticsStore.addRecord(record)

        // Advance mode
        if mode == .work {
            workSessionCount += 1
            completedSessions += 1
            if workSessionCount % longBreakInterval == 0 {
                mode = .longBreak
            } else {
                mode = .shortBreak
            }
        } else {
            mode = .work
        }

        remainingSeconds = durationFor(mode)
        state = .idle

        // Defer alerts/notifications so they don't run during the same layout pass as state updates.
        DispatchQueue.main.async {
            NotificationManager.shared.sendTimerFinished(mode: finishedMode)
        }
    }

    private func durationFor(_ mode: PomodoroMode) -> TimeInterval {
        switch mode {
        case .work: return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }
}
