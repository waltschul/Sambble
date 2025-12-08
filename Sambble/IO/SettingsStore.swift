import Foundation
import SwiftUI

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @AppStorage("SELECTED_QUIZ") var selectedQuiz: QuizID = QuizID.SEVENS
    @AppStorage("CARDBOX_ZERO_SIZE") var cardboxZeroSize: Int = Constants.CARDBOX_ZERO_SIZE_DEFAULT
    @AppStorage("EASY_ANSWER_SHIFT") var easyAnswerShift: Int = Constants.EASY_ANSWER_SHIFT_DEFAULT
    @AppStorage("THEME_COLOR") var themeColorData: Data = Constants.THEME_COLOR_DEFAULT.encode()

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

