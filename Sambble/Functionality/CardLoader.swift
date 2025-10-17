import Foundation
import OrderedCollections

class CardLoader {
    let quizParameters: QuizParameters
    
    lazy var cards: OrderedDictionary<String, Card> = {
            loadCards(url: Bundle.main.url(forResource: "nwl23", withExtension: "csv")!,
                      quizParameters: self.quizParameters)}()
        
    init(quizParameters: QuizParameters) {
        self.quizParameters = quizParameters
    }
    
    func removeCard(id: String) -> Card {
        return cards.removeValue(forKey: id)!
    }
    
    func popCards(count: Int) -> [Card] {
        let count = min(count, cards.count)
        let poppedCards = cards.prefix(count).map { $0.value }
        cards.removeFirst(count)
        return poppedCards
    }
}

extension CodingUserInfoKey {
    static let cardLoader = CodingUserInfoKey(rawValue: "cardLoader")!
}
