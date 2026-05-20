import SwiftUI
import Combine

@main
struct PomodoroTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .frame(minWidth: 380, minHeight: 480)
                .background(MainWindowOpener())
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 380, height: 480)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var current: AppDelegate? { NSApp.delegate as? AppDelegate }

    private var statusItem: NSStatusItem!
    private var menuBarWindow: NSWindow?
    private var cancellable: AnyCancellable?
    private var localEventMonitor: Any?
    private var lastCloseTime = Date.distantPast

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationManager.shared.configure()
        setupMenuBar()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func showMainWindow() {
        closeMenuBarWindow()
        NSApp.activate(ignoringOtherApps: true)
        if let window = primaryMainWindow() {
            window.makeKeyAndOrderFront(nil)
        } else {
            AppWindowController.shared.showMainWindow()
        }
    }

    // MARK: - Menu bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusTitle()
        attachStatusBarAction()

        cancellable = PomodoroViewModel.shared.$remainingSeconds
            .combineLatest(PomodoroViewModel.shared.$state)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusTitle()
            }

        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let window = self.menuBarWindow, window.isVisible else { return event }
            let clickInWindow = window.convertPoint(fromScreen: NSEvent.mouseLocation)
            if window.contentView?.bounds.contains(clickInWindow) == false {
                self.closeMenuBarWindow()
            }
            return event
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    private func attachStatusBarAction() {
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(statusBarButtonClicked)
        button.sendAction(on: [.leftMouseUp])
    }

    private func updateStatusTitle() {
        let vm = PomodoroViewModel.shared
        if vm.state == .idle && vm.remainingSeconds == 0 {
            statusItem.button?.title = "🍅"
        } else {
            let m = Int(vm.remainingSeconds) / 60
            let s = Int(vm.remainingSeconds) % 60
            statusItem.button?.title = vm.state == .paused
                ? "⏸ \(String(format: "%02d:%02d", m, s))"
                : "\(String(format: "%02d:%02d", m, s))"
        }
    }

    @objc private func statusBarButtonClicked() {
        if let window = menuBarWindow, window.isVisible {
            closeMenuBarWindow()
            return
        }
        // If the event monitor just closed the window on mouseDown, don't re-open on mouseUp
        if Date().timeIntervalSince(lastCloseTime) < 0.3 {
            return
        }
        showMenuBarWindow()
    }

    @objc private func appDidResignActive() {
        closeMenuBarWindow()
    }

    private func showMenuBarWindow() {
        guard let button = statusItem.button, let buttonWindow = button.window else { return }

        if menuBarWindow == nil {
            let hosting = NSHostingController(rootView:
                MenuBarView(viewModel: PomodoroViewModel.shared)
            )

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 240, height: 330),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .popUpMenu
            window.collectionBehavior = [.transient, .ignoresCycle]
            window.hasShadow = true

            let visualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 240, height: 330))
            visualEffect.material = .menu
            visualEffect.blendingMode = .behindWindow
            visualEffect.state = .active
            visualEffect.wantsLayer = true
            visualEffect.layer?.cornerRadius = 10
            visualEffect.layer?.masksToBounds = true

            hosting.view.frame = visualEffect.bounds
            hosting.view.autoresizingMask = [.width, .height]
            visualEffect.addSubview(hosting.view)

            window.contentView = visualEffect
            menuBarWindow = window
        }

        let buttonScreenRect = buttonWindow.convertToScreen(button.frame)
        let windowWidth = menuBarWindow!.frame.width
        let windowHeight = menuBarWindow!.frame.height

        let x = buttonScreenRect.midX - windowWidth / 2
        let y = buttonScreenRect.minY - windowHeight - 4

        menuBarWindow?.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: false)
        menuBarWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeMenuBarWindow() {
        menuBarWindow?.orderOut(nil)
        lastCloseTime = Date()
    }

    // MARK: - Main window

    private func primaryMainWindow() -> NSWindow? {
        let title = LanguageManager.shared.loc("Pomodoro Timer")
        for window in NSApp.windows {
            guard window.canBecomeKey else { continue }
            guard window.title == title else { continue }
            guard window.contentViewController != nil else { continue }
            return window
        }
        return nil
    }
}
