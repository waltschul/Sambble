import SwiftUI

struct ScoreView: View {
    let id: QuizID
    let quiz: Quiz
    @EnvironmentObject var settings: SettingsStore
    @State var isAnimating = false

    var body: some View {
        Text(String(quiz.score))
            .foregroundColor(settings.themeColor)
            .font(.system(size: 50, weight: .medium, design: .monospaced))
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            .onChange(of: quiz.score) { _, newScore in
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimating = false
                }
            }
            .debugOutline()
            .shareOnLongPress(items: ["I've studied \(quiz.score) / \(quiz.cardLoader.totalWords) of my Sambble \(id.rawValue)!"])
    }
}
