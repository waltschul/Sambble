import SwiftUI

struct ScoreView: View {
    let quiz: Quiz
    @State private var isAnimating = false
    
    var body: some View {
        Text("\(quiz.score)")
            .foregroundColor(.mint)
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
    }
}
