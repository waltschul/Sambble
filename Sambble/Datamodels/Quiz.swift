import Foundation

@Observable
final class Quiz: Codable {
    let cardLoader: CardLoader
    var cardboxAlgorithm: CardboxAlgorithm
    var cardboxes: [[Card]]
    var currentCard: ViewedCard
    var nextCard: ViewedCard
    var counts: [Int] {
        var counts = cardboxes.map { $0.count }
        counts[currentCard.newBox] += 1
        counts[nextCard.newBox] += 1
        return counts
    }
    
    var score: Int {
        return counts.dropFirst().reduce(0, +)
    }

    //TODO maybe just serialize the whole cardLoader is easier
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let cardboxAlgorithm = try container.decode(CardboxAlgorithm.self, forKey: ._cardboxAlgorithm)
        let cardboxes = try container.decode([[Card]].self, forKey: ._cardboxes)
        let currentCard = try container.decode(ViewedCard.self, forKey: ._currentCard)
        let nextCard = try container.decode(ViewedCard.self, forKey: ._nextCard)
        let cardLoader = CardLoader(wordLength: wordLength, excludeCards: cardboxes.flatMap { $0 } + [currentCard.card, nextCard.card])
        self.init(cardLoader: cardLoader,
                  cardboxAlgorithm: cardboxAlgorithm,
                  cardboxes: cardboxes,
                  currentCard: currentCard,
                  nextCard: nextCard)
    }
    
    convenience init(cardLoader: CardLoader, index: Int) {
        var initialCards = cardLoader.nextCards(count: 2)
        let currentCard = ViewedCard(card: initialCards.removeFirst())
        let nextCard = ViewedCard(card: initialCards.removeFirst())
        self.init(cardLoader: cardLoader,
                  cardboxAlgorithm: CardboxAlgorithm(),
                  cardboxes: Array(repeating: [], count: Constants.NUM_BOXES),
                  currentCard: currentCard,
                  nextCard: nextCard)

        for _ in 0..<index+1 {
            advance(correct: index != 0)    
        }
    }
    
    private init(cardLoader: CardLoader,
                 cardboxAlgorithm: CardboxAlgorithm,
                 cardboxes: [[Card]],
                 currentCard: ViewedCard,
                 nextCard: ViewedCard) {
        self.cardboxAlgorithm = cardboxAlgorithm
        self.cardboxes = cardboxes
        self.currentCard = currentCard
        self.nextCard = nextCard
        self.cardLoader = cardLoader
    }
    
    func advance(correct: Bool) {
        currentCard.correct = correct
        addCardsToCardboxZero()
        cycleCard()
    }
    
    private func addCardsToCardboxZero() {
        let cardboxZeroDiff = max(Constants.CARDBOX_ZER0_MIN_SIZE - counts[0], 0)
        cardboxes[0].append(contentsOf: cardLoader.nextCards(count: cardboxZeroDiff))
    }
    
    private func cycleCard() {
        let markedCard = currentCard
        currentCard = nextCard
        
        let nextBox = cardboxAlgorithm.nextCardbox(cardboxes: cardboxes)
        nextCard = ViewedCard(card: cardboxes[nextBox].removeFirst(), box: nextBox)
        cardboxes[markedCard.newBox].append(markedCard.card)
        print("\(markedCard) moved to \(markedCard.newBox). Current card is now \(currentCard), next card is \(nextCard) popped from \(nextBox)")
    }
    
    enum CodingKeys: String, CodingKey {
        case _wordLength = "wordLength"
        case _cardboxAlgorithm = "cardboxAlgorithm"
        case _currentCard = "currentCard"
        case _nextCard = "nextCard"
        case _cardboxes = "cardboxes"
    }
}
