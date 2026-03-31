import Foundation

enum CardViewState {
    case unchecked  // State 1: index=1, answer not yet revealed
    case checked    // State 2: index=1, answer revealed, awaiting grade
    case graded     // State 3: index=0 or 2, graded, awaiting advance
}

enum CardInputEvent {
    case tap        // iOS tap, macOS Space
    case arrowLeft  // macOS Left Arrow
    case arrowRight // macOS Right Arrow
    case mediaNext  // CarPlay/BT next track
    case mediaPrev  // CarPlay/BT previous track
}

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

    var cardViewState: CardViewState {
        if quiz.currentCard.checked == .UNCHECKED { return .unchecked }
        return index == 1 ? .checked : .graded
    }

    func handle(_ event: CardInputEvent) {
        switch (cardViewState, event) {

        // State 1: any input reveals the card
        case (.unchecked, _):
            quiz.currentCard.checked = .CHECKED

        // State 2: tap/Space toggles easy
        case (.checked, .tap):
            quiz.currentCard.checked = quiz.currentCard.checked == .EASY ? .CHECKED : .EASY

        // State 2: rightward → grade correct
        case (.checked, .arrowRight), (.checked, .mediaNext):
            index = 0
            quiz.currentCard.correct = .CORRECT

        // State 2: leftward → grade incorrect
        case (.checked, .arrowLeft), (.checked, .mediaPrev):
            index = 2
            quiz.currentCard.correct = .INCORRECT

        // State 3: any input advances and reveals next card
        case (.graded, _):
            quiz.advance(allowTreats: quiz.treatModeEnabled)
            index = 1
            quiz.currentCard.checked = .CHECKED
        }

        quiz.index = index
        persistQuiz(id: id, quiz: quiz)
    }
}

extension QuizViewModel {
    func registerMediaCommands() {
        guard SettingsStore.shared.carMode else { return }
        let media = MediaCommandManager.shared
        media.onNext = { [weak self] in self?.handle(.mediaNext) }
        media.onPrevious = { [weak self] in self?.handle(.mediaPrev) }
    }
}
