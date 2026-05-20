import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var theme = ThemeManager.shared
    @State private var editingField: String? = nil
    @State private var editingText: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(lang.loc("Settings"))
                .font(.title2)
                .bold()

            Form {
                Section {
                    durationRow(label: lang.loc("Focus duration (min)"), fieldKey: "work", binding: binding(for: \.workDuration))
                    durationRow(label: lang.loc("Short break (min)"), fieldKey: "shortBreak", binding: binding(for: \.shortBreakDuration))
                    durationRow(label: lang.loc("Long break (min)"), fieldKey: "longBreak", binding: binding(for: \.longBreakDuration))

                    Stepper(lang.loc("Long break after %lld sessions", viewModel.longBreakInterval), value: $viewModel.longBreakInterval, in: 2...8)
                }

                Section {
                    Picker(lang.loc("Language"), selection: $lang.appLanguage) {
                        Text("中文").tag("zh-Hans")
                        Text("English").tag("en")
                    }
                    .pickerStyle(.segmented)
                    .id(lang.appLanguage)
                }

                Section(lang.loc("Theme")) {
                    themePicker

                    Picker(lang.loc("Color Scheme"), selection: $theme.colorSchemeMode) {
                        ForEach(ColorSchemeMode.allCases, id: \.self) { mode in
                            Text(lang.loc(mode.displayKey)).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .id(lang.appLanguage)
                }

                Section(lang.loc("Notifications")) {
                    Text(lang.loc("If banners are silent, set Pomodoro Timer to Alerts and allow sounds in System Settings."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button(lang.loc("Open Notification Settings")) {
                        NotificationManager.shared.openSystemNotificationSettings()
                    }
                }
            }
            .formStyle(.grouped)

            Button(lang.loc("Done")) {
                commitEdit()
                NSApp.keyWindow?.close()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(width: 420, height: 520)
        .onTapGesture { commitEdit() }
    }

    // MARK: - Theme

    private var themePicker: some View {
        HStack(spacing: 12) {
            ForEach(ColorTheme.allCases, id: \.self) { t in
                themeButton(t)
            }
        }
    }

    private func themeButton(_ t: ColorTheme) -> some View {
        Button(action: { theme.theme = t }) {
            Circle()
                .fill(t.swatchColor)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(Color.primary, lineWidth: theme.theme == t ? 3 : 0)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: theme.theme == t ? 1 : 0)
                )
        }
        .buttonStyle(.plain)
        .help(lang.loc(t.displayKey))
    }

    // MARK: - Duration editing

    private func durationRow(label: String, fieldKey: String, binding: Binding<Double>) -> some View {
        let minutes = Binding<Int>(
            get: { Int(binding.wrappedValue / 60) },
            set: { binding.wrappedValue = TimeInterval($0 * 60) }
        )

        return HStack {
            Text(label)
            Spacer()

            if editingField == fieldKey {
                TextField("", text: $editingText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 55)
                    .onSubmit { commitEdit() }
                    .onExitCommand { editingField = nil }
            } else {
                Text("\(minutes.wrappedValue)")
                    .foregroundColor(.accentColor)
                    .frame(minWidth: 30, alignment: .trailing)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        commitEdit()
                        editingText = "\(minutes.wrappedValue)"
                        editingField = fieldKey
                    }
            }

            Stepper("", value: minutes, in: 1...120)
                .frame(width: 100)
                .labelsHidden()
        }
    }

    private func commitEdit() {
        guard let key = editingField else { return }
        if let value = Int(editingText), value >= 1, value <= 120 {
            let clamped = min(max(value, 1), 120)
            let minutes = clamped * 60
            switch key {
            case "work": viewModel.workDuration = TimeInterval(minutes)
            case "shortBreak": viewModel.shortBreakDuration = TimeInterval(minutes)
            case "longBreak": viewModel.longBreakDuration = TimeInterval(minutes)
            default: break
            }
        }
        editingField = nil
    }

    private func binding(for keyPath: ReferenceWritableKeyPath<PomodoroViewModel, TimeInterval>) -> Binding<TimeInterval> {
        Binding(
            get: { self.viewModel[keyPath: keyPath] },
            set: { self.viewModel[keyPath: keyPath] = $0 }
        )
    }
}
