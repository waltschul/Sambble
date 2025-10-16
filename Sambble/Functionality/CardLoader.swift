import Foundation
import OrderedCollections

class CardLoader {
    var cards: OrderedDictionary<String, Card>
    
    init(quizParameters: QuizParameters) {
        self.cards = loadCards(url: Bundle.main.url(forResource: "nwl23", withExtension: "csv")!,
                                          quizParameters: quizParameters)
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
