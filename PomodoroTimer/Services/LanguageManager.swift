import SwiftUI

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @AppStorage("appLanguage") var appLanguage: String = "zh-Hans" {
        didSet { objectWillChange.send() }
    }

    var isChinese: Bool { appLanguage == "zh-Hans" }

    func loc(_ key: String) -> String {
        string(for: key)
    }

    func loc(_ key: String, _ args: CVarArg...) -> String {
        String(format: string(for: key), arguments: args)
    }

    private func string(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: appLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return key }
        let str = bundle.localizedString(forKey: key, value: nil, table: nil)
        return str != key ? str : key
    }
}
