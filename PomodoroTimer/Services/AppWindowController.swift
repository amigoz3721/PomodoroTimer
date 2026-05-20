import Foundation

/// Bridges AppDelegate → SwiftUI `openWindow` so we never create duplicate NSWindows by hand.
final class AppWindowController {
    static let shared = AppWindowController()

    private var isOpeningMainWindow = false

    private init() {}

    var openMainWindow: (() -> Void)?

    func showMainWindow() {
        guard !isOpeningMainWindow else { return }
        isOpeningMainWindow = true
        openMainWindow?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isOpeningMainWindow = false
        }
    }
}
