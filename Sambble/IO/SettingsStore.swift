import Foundation
import SwiftUI

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @AppStorage("SELECTED_QUIZ_ID") var selectedQuizIdentifierData: Data = Data()
    @AppStorage("CUSTOM_QUIZZES") var customQuizzesData: Data = Data()
    @AppStorage("THEME_COLOR") var themeColorData: Data = Constants.THEME_COLOR_DEFAULT.encode()
    @AppStorage("CAR_MODE") var carMode: Bool = false {
        didSet { objectWillChange.send() }
    }

    var selectedQuizIdentifier: QuizIdentifier {
        get {
            if let id = try? JSONDecoder().decode(QuizIdentifier.self, from: selectedQuizIdentifierData) {
                return id
            }
            // Migration: read the old SELECTED_QUIZ string key
            if let rawValue = UserDefaults.standard.string(forKey: "SELECTED_QUIZ"),
               let oldID = QuizID(rawValue: rawValue) {
                return .builtin(oldID)
            }
            return .builtin(.SEVENS)
        }
        set {
            selectedQuizIdentifierData = (try? JSONEncoder().encode(newValue)) ?? Data()
            objectWillChange.send()
        }
    }

    var customQuizzes: [CustomQuizSpec] {
        get {
            (try? JSONDecoder().decode([CustomQuizSpec].self, from: customQuizzesData)) ?? []
        }
        set {
            customQuizzesData = (try? JSONEncoder().encode(newValue)) ?? Data()
            objectWillChange.send()
        }
    }

    func addCustomQuiz(_ spec: CustomQuizSpec) {
        var quizzes = customQuizzes
        quizzes.append(spec)
        customQuizzes = quizzes
    }

    func removeCustomQuiz(id: UUID) {
        customQuizzes = customQuizzes.filter { $0.id != id }
    }

    var themeColor: Color {
        get { Color.decode(themeColorData) }
        set { themeColorData = newValue.encode() }
    }
}

extension Color {
    func encode() -> Data {
        let components = rgbComponents
        return try! JSONEncoder().encode(components)
    }

    static func decode(_ data: Data) -> Color {
        if let components = try? JSONDecoder().decode([Double].self, from: data) {
            return Color.fromRGB(components)
        } else {
            return .blue
        }
    }
}

extension Color {
    var rgbComponents: [Double] {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return [Double(r), Double(g), Double(b)]
    }

    static func fromRGB(_ components: [Double]) -> Color {
        guard components.count == 3 else { return Color.blue }
        return Color(red: components[0], green: components[1], blue: components[2])
    }
}
