import Foundation
import OrderedCollections

class CardLoader {
    let totalWords: Int
    let probabilityOrder: Bool
    var cards: OrderedDictionary<String, Card>

    init(quizParameters: QuizParameters) {
        self.probabilityOrder = quizParameters.probabilityOrder
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
    
    func popCards(count: Int, allowTreats: Bool = true) -> [Card] {
        let limit = min(count, cards.count)
        var result: [Card] = []
        let treatChance = Constants.DEBUG ? 2 : 50
        for _ in 0..<limit {
            guard !cards.isEmpty else { break }
            if allowTreats && probabilityOrder, Int.random(in: 0..<treatChance) == 0, cards.count > 1, let t = treat() {
                result.append(Card(id: t.id, words: t.words, status: .treat))
            } else {
                let key = cards.keys.first!
                let first = cards.removeValue(forKey: key)!
                result.append(Card(id: first.id, words: first.words, status: .new))
            }
        }
        return result
    }
    
    static func wordCount(cards: [Card]) -> Int {
        return cards.map { $0.words.count }.reduce(0, +)
    }
}

extension CodingUserInfoKey {
    static let cardLoader = CodingUserInfoKey(rawValue: "cardLoader")!
}
