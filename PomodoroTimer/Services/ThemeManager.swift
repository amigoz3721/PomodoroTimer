import SwiftUI

// MARK: - Color Scheme Mode

enum ColorSchemeMode: String, CaseIterable {
    case system
    case light
    case dark

    var displayKey: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var scheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Color Theme

enum ColorTheme: String, CaseIterable {
    case tomato
    case ocean
    case forest
    case lavender
    case sunset

    var displayKey: String {
        switch self {
        case .tomato: return "Tomato"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        case .lavender: return "Lavender"
        case .sunset: return "Sunset"
        }
    }

    var swatchColor: Color {
        switch self {
        case .tomato: return Color(red: 0.93, green: 0.33, blue: 0.23)
        case .ocean: return Color(red: 0.13, green: 0.55, blue: 0.85)
        case .forest: return Color(red: 0.22, green: 0.67, blue: 0.38)
        case .lavender: return Color(red: 0.58, green: 0.44, blue: 0.86)
        case .sunset: return Color(red: 0.94, green: 0.45, blue: 0.18)
        }
    }

    func accentColor(for mode: PomodoroMode) -> Color {
        switch (self, mode) {
        case (.tomato, .work):       return Color(red: 0.93, green: 0.33, blue: 0.23)
        case (.tomato, .shortBreak): return Color(red: 0.22, green: 0.67, blue: 0.38)
        case (.tomato, .longBreak):  return Color(red: 0.18, green: 0.55, blue: 0.65)

        case (.ocean, .work):        return Color(red: 0.13, green: 0.55, blue: 0.85)
        case (.ocean, .shortBreak):  return Color(red: 0.20, green: 0.73, blue: 0.67)
        case (.ocean, .longBreak):   return Color(red: 0.35, green: 0.45, blue: 0.82)

        case (.forest, .work):       return Color(red: 0.22, green: 0.67, blue: 0.38)
        case (.forest, .shortBreak): return Color(red: 0.55, green: 0.71, blue: 0.27)
        case (.forest, .longBreak):  return Color(red: 0.30, green: 0.52, blue: 0.55)

        case (.lavender, .work):     return Color(red: 0.58, green: 0.44, blue: 0.86)
        case (.lavender, .shortBreak): return Color(red: 0.80, green: 0.55, blue: 0.75)
        case (.lavender, .longBreak):  return Color(red: 0.45, green: 0.55, blue: 0.82)

        case (.sunset, .work):       return Color(red: 0.94, green: 0.45, blue: 0.18)
        case (.sunset, .shortBreak): return Color(red: 0.90, green: 0.63, blue: 0.29)
        case (.sunset, .longBreak):  return Color(red: 0.85, green: 0.38, blue: 0.42)
        }
    }
}

// MARK: - Theme Manager

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @AppStorage("colorTheme") var theme: ColorTheme = .tomato {
        didSet { objectWillChange.send() }
    }

    @AppStorage("colorSchemeMode") var colorSchemeMode: ColorSchemeMode = .system {
        didSet { objectWillChange.send() }
    }

    func accentColor(for mode: PomodoroMode) -> Color {
        theme.accentColor(for: mode)
    }
}
