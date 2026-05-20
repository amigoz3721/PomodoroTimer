import SwiftUI

/// Registers `openWindow(id: "main")` with AppWindowController whenever a main window is on screen.
struct MainWindowOpener: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear(perform: registerOpenHandler)
    }

    private func registerOpenHandler() {
        AppWindowController.shared.openMainWindow = {
            openWindow(id: "main")
        }
    }
}
