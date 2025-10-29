import SwiftUI

struct QuizView: View {
    //TODO serialize QuizID with quiz again
    let id: QuizID
    let quiz: Quiz
    @State var index = 1

    var body: some View {
        CardSwipeView(quiz: quiz, index: $index)
            .background(Color.clear.contentShape(Rectangle()).ignoresSafeArea())
            .onTapGesture { handleCardAnswer() }
    }
    
    func handleCardAnswer() {
        //TODO data race -- doesn't rlly matter
        if index != 1 {
            quiz.advance()
            index = 1
        }
        quiz.currentCard.checked = quiz.currentCard.checked.nextState()
        persistQuiz(id: id, quiz: quiz)
    }
}
