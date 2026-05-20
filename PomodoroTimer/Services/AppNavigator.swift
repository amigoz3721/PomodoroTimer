import AppKit
import SwiftUI

/// Opens Settings / Statistics in standalone windows so menu-bar actions work
/// even when the main window is closed or the app is not frontmost.
final class AppNavigator: NSObject, NSWindowDelegate {
    static let shared = AppNavigator()

    private var settingsWindow: NSWindow?
    private var statisticsWindow: NSWindow?

    func openSettings() {
        AppDelegate.current?.closeMenuBarWindow()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.presentSettingsWindow()
        }
    }

    func openStatistics() {
        AppDelegate.current?.closeMenuBarWindow()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.presentStatisticsWindow()
        }
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window === settingsWindow { settingsWindow = nil }
        if window === statisticsWindow { statisticsWindow = nil }
    }

    // MARK: - Private

    private func presentSettingsWindow() {
        present(
            window: &settingsWindow,
            titleKey: "Settings",
            size: NSSize(width: 420, height: 520),
            rootView: SettingsView(viewModel: PomodoroViewModel.shared)
        )
    }

    private func presentStatisticsWindow() {
        present(
            window: &statisticsWindow,
            titleKey: "Statistics",
            size: NSSize(width: 520, height: 420),
            rootView: StatisticsView(store: PomodoroViewModel.shared.statisticsStore)
        )
    }

    private func present<Content: View>(
        window storage: inout NSWindow?,
        titleKey: String,
        size: NSSize,
        rootView: Content
    ) {
        NSApp.activate(ignoringOtherApps: true)

        if let window = storage {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let lang = LanguageManager.shared
        let hosting = NSHostingController(rootView: rootView)
        hosting.view.frame = NSRect(origin: .zero, size: size)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = lang.loc(titleKey)
        window.contentViewController = hosting
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)

        storage = window
    }
}
