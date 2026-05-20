import AppKit
import SwiftUI
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func configure() {
        requestPermission()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            if !granted {
                print("Notification permission denied — use in-app alert and check System Settings.")
            }
        }
    }

    func sendTimerFinished(mode: PomodoroMode) {
        let lang = LanguageManager.shared
        let title = mode == .work
            ? lang.loc("Time for a break!")
            : lang.loc("Break over!")
        let body = mode == .work
            ? lang.loc("Great job! Take a break.")
            : lang.loc("Break finished. Ready for the next focus session?")

        playCompletionSound()
        postSystemNotification(title: title, body: body)

        DispatchQueue.main.async {
            NSApp.requestUserAttention(.informationalRequest)
            CompletionAlertCenter.shared.show(title: title, message: body)
        }
    }

    func openSystemNotificationSettings() {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.pomodoro.timer"
        let urlString = "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(bundleID)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
            return
        }
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Private

    private func playCompletionSound() {
        if let sound = NSSound(named: NSSound.Name("Glass")) {
            sound.play()
            return
        }
        if let sound = NSSound(named: NSSound.Name("Ping")) {
            sound.play()
            return
        }
        NSSound.beep()
    }

    private func postSystemNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        if #available(macOS 12.0, *) {
            content.interruptionLevel = .timeSensitive
        }

        // Immediate (nil) delivery often lands silently in Notification Center on macOS.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.3, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to deliver notification: \(error)")
            }
        }
    }

    // Show banner + sound when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}

// MARK: - Non-blocking timer-finished alert

final class CompletionAlertCenter: ObservableObject {
    static let shared = CompletionAlertCenter()

    struct AlertInfo: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    @Published var activeAlert: AlertInfo?

    func show(title: String, message: String) {
        let info = AlertInfo(title: title, message: message)
        DispatchQueue.main.async {
            self.activeAlert = info
        }
    }
}
