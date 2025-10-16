import Foundation

@Observable
class QuizCache {
    let quizzes: [QuizID]
    var quizCache: [QuizID: Quiz] = [:]
    var cardLoaderCache: [QuizID: CardLoader] = [:]

    init() {
        quizzes = Constants.DEBUG ? Constants.PREVIEW_QUIZZES : QuizID.allCases
        quizzes.forEach { id in
            let quiz = loadQuiz(id: id)
            if let quiz {
                quizCache[id] = quiz
            } else if !id.parameters.probabilityOrder {
                quizCache[id] = Quiz(quizID: id, cardLoader: cardLoader(id: id))
            } else {
                initialize(id: id)
            }
        }
    }
    
    func initialize(id: QuizID) {
        quizCache.removeValue(forKey: id)
        cardLoaderCache[id] = cardLoader(id: id)
    }
    
    func cardLoader(id: QuizID) -> CardLoader {
        return CardLoader(quizParameters: id.parameters)
    }
}
