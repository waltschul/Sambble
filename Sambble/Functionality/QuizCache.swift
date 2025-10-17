import Foundation

@Observable
class QuizCache {
    let quizzes: [QuizID]
    var quizCache: [QuizID: Quiz] = [:]

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
    }
    
    func removeQuiz(id: QuizID) {
        quizCache.removeValue(forKey: id)
        if !id.parameters.probabilityOrder {
            quizCache[id] = Quiz(cardLoader: CardLoader(quizParameters: id.parameters))
        }
    }
}
