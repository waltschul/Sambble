import SwiftUI

struct QuizView: View {
    let quiz: Quiz
    @State var index = 1

    var body: some View {
        CardSwipeView(quiz: quiz, index: $index)
            .background(Color.clear.contentShape(Rectangle()).ignoresSafeArea())
            .onTapGesture { handleCardAnswer() }
            .overlay(
                CardboxView(quiz: quiz)
                    .padding(.all),
                alignment: .topLeading
            )
            .overlay(
                ScoreView(quiz: quiz),
                alignment: .top
            )
    }
    
    func handleCardAnswer() {
        //TODO data race
        if index != 1 {
            quiz.advance(correct: index == 0)
            index = 1
        }
        quiz.currentCard.checked = true
        persistQuiz(quiz: quiz)
    }
}
