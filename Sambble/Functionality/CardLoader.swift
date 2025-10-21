import Foundation
import OrderedCollections

class CardLoader {
    let totalWords: Int
    var cards: OrderedDictionary<String, Card>
    
    init(quizParameters: QuizParameters) {
        self.cards = loadCards(url: Bundle.main.url(forResource: "nwl23", withExtension: "csv")!,
                                          quizParameters: quizParameters)
        self.totalWords = CardLoader.wordCount(cards: Array(cards.values))
    }
    
    //TODO freq, handle cards empty
    func treat() -> Card? {
        guard !cards.isEmpty else { return nil }
        let halfIndex = cards.count / 2
        let bottomHalfCards = Array(cards.values[halfIndex...])
        return removeCard(id: bottomHalfCards.randomElement()!.id)
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
    
    static func wordCount(cards: [Card]) -> Int {
        return cards.map { $0.words.count }.reduce(0, +)
    }
}

extension CodingUserInfoKey {
    static let cardLoader = CodingUserInfoKey(rawValue: "cardLoader")!
}
