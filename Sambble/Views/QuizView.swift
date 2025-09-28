import SwiftUI

struct QuizView: View {
    let quiz: Quiz
    @State private var index = 1

    var body: some View {
        CardSwipeView(quiz: quiz, index: $index)
            .background(Color.black.ignoresSafeArea())
            .onTapGesture { handleCardAnswer() }
            .overlay(CardboxView(quiz: quiz)
                .padding(.leading),
                alignment: .topLeading
            )
            .overlay(ScoreView(quiz: quiz),
                alignment: .top
            )
    }
    
    func handleCardAnswer() {
        //TODO data race, isProcessing didn't work
        if index != 1 {
            quiz.markCard(correct: index == 0)
            index = 1
        }
        quiz.currentCard.checked = true
        saveQuiz(quiz: quiz)
    }
}
