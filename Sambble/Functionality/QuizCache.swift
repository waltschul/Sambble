import Foundation

@Observable
class QuizCache {
    let quizzes: [QuizID]
    var quizCache: [QuizID: Quiz] = [:]
    var customQuizCache: [UUID: Quiz] = [:]

    init() {
        quizzes = Constants.DEBUG ? Constants.PREVIEW_QUIZZES : QuizID.allCases
        quizzes.forEach { id in
            let quiz = loadQuiz(id: id)
            if let quiz {
                quizCache[id] = quiz
            } else {
                removeQuiz(id: id)
            }
        }

        // Load persisted custom quizzes
        for spec in SettingsStore.shared.customQuizzes {
            if let quiz = loadCustomQuiz(spec: spec) {
                customQuizCache[spec.id] = quiz
            } else if !spec.probabilityOrder {
                customQuizCache[spec.id] = Quiz(cardLoader: CardLoader(quizParameters: spec.parameters))
            }
            // probabilityOrder custom quizzes with no saved state wait for InitializeView
        }
    }

    func removeQuiz(id: QuizID) {
        quizCache.removeValue(forKey: id)
        if !id.parameters.probabilityOrder {
            quizCache[id] = Quiz(cardLoader: CardLoader(quizParameters: id.parameters))
        }
    }

    func addCustomQuiz(spec: CustomQuizSpec) {
        SettingsStore.shared.addCustomQuiz(spec)
        if !spec.probabilityOrder {
            customQuizCache[spec.id] = Quiz(cardLoader: CardLoader(quizParameters: spec.parameters))
        }
        // probabilityOrder: leave nil so InitializeView is shown
    }

    func removeCustomQuiz(spec: CustomQuizSpec) {
        customQuizCache.removeValue(forKey: spec.id)
        SettingsStore.shared.removeCustomQuiz(id: spec.id)
        deleteCustomQuizFile(spec: spec)
    }

    func customQuizSpec(for uuid: UUID) -> CustomQuizSpec? {
        SettingsStore.shared.customQuizzes.first { $0.id == uuid }
    }
}
