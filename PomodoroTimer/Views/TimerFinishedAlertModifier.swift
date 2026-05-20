import SwiftUI

struct TimerFinishedAlertModifier: ViewModifier {
    @ObservedObject private var alerts = CompletionAlertCenter.shared
    @ObservedObject private var lang = LanguageManager.shared

    func body(content: Content) -> some View {
        content
            .alert(
                alerts.activeAlert?.title ?? "",
                isPresented: Binding(
                    get: { alerts.activeAlert != nil },
                    set: { if !$0 { alerts.activeAlert = nil } }
                )
            ) {
                Button(lang.loc("OK")) {
                    alerts.activeAlert = nil
                }
            } message: {
                if let alert = alerts.activeAlert {
                    Text(alert.message)
                }
            }
    }
}

extension View {
    func timerFinishedAlert() -> some View {
        modifier(TimerFinishedAlertModifier())
    }
}
