import Foundation

@Observable
class QuizCache {
    let quizzes: [QuizDefinition]
    var quizCache: [String: Quiz] = [:]
    var cardLoaderCache: [String: CardLoader] = [:]

    init(quizzes: [QuizDefinition]) {
        self.quizzes = quizzes
        quizzes.forEach { def in
            let quiz = loadQuiz(id: def.id)
            if let quiz {
                quizCache[def.id] = quiz
            } else {
                addCardLoader(def: def)
            }
        }
    }
    
    func remove(id: String) {
        quizCache.removeValue(forKey: id)
        addCardLoader(def: quizzes.first { $0.id == id }!)
    }
    
    func addCardLoader(def: QuizDefinition) {
        cardLoaderCache[def.id] = CardLoader(quizParameters: def.quizParameters)
    }
}
