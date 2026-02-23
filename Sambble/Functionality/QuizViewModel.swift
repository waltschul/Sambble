import Foundation

final class QuizViewModel: ObservableObject {
    let id: QuizID
    let quiz: Quiz

    @Published var index: Int

    init(id: QuizID, quiz: Quiz) {
        self.id = id
        self.quiz = quiz
        self.index = quiz.index
        registerMediaCommands()
    }

    func handleCardAnswer() {
        //TODO data race -- doesn't rlly matter
        if index != 1 {
            quiz.advance(allowTreats: quiz.treatModeEnabled)
            index = 1
        }
        quiz.currentCard.checked = quiz.currentCard.checked.nextState()
        quiz.index = index
        persistQuiz(id: id, quiz: quiz)
    }
}

extension QuizViewModel {
    func registerMediaCommands() {
        guard SettingsStore.shared.carMode else { return }
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
    }
}
