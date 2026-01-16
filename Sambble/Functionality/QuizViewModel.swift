import Foundation

final class QuizViewModel: ObservableObject {
    let id: QuizID
    let quiz: Quiz

    @Published var index: Int = 1

    init(id: QuizID, quiz: Quiz) {
        self.id = id
        self.quiz = quiz
        registerMediaCommands()
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

extension QuizViewModel {
    func registerMediaCommands() {
        let media = MediaCommandManager.shared

        //TODO simplify?
        media.onNext = { [weak self] in
            if (self?.index == 1
                       && self?.quiz.currentCard.checked != AnswerState.UNCHECKED) {
                self?.index = 0
            } else {
                self?.handleCardAnswer();
            }
        }

        media.onPrevious = { [weak self] in
            if (self?.index == 1
                       && self?.quiz.currentCard.checked != AnswerState.UNCHECKED) {
                self?.index = 2
            } else {
                self?.handleCardAnswer();
            }
        }

        media.updateNowPlaying()
    }
}
