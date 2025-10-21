import Foundation

@Observable
final class Quiz: Codable {
    let cardLoader: CardLoader
    
    //Serialized
    //TODO vars still? lets?
    var cardboxes: [[Card]]
    var cardboxAlgorithm: CardboxAlgorithm
    var currentCard: ViewedCard
    var nextCard: ViewedCard
    
    var counts: [Int] {
        var counts = cardboxes.map { $0.count }
        counts[currentCard.newBox] += 1
        counts[nextCard.newBox] += 1
        return counts
    }
    var score: Int {
        let cards = cardboxes.dropFirst().flatMap { $0 } + [
            currentCard.newBox != 0 ? currentCard.card : nil,
            nextCard.newBox != 0 ? nextCard.card : nil
        ].compactMap { $0 }
        return CardLoader.wordCount(cards: cards)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(cardLoader: decoder.userInfo[.cardLoader] as! CardLoader,
                  cardboxes: try container.decode([[Card]].self, forKey: ._cardboxes),
                  cardboxAlgorithm: try container.decode(CardboxAlgorithm.self, forKey: ._cardboxAlgorithm),
                  currentCard: try container.decode(ViewedCard.self, forKey: ._currentCard),
                  nextCard: try container.decode(ViewedCard.self, forKey: ._nextCard))
    }
    
    convenience init(cardLoader: CardLoader, until: Card? = nil) {
        var initialCards = cardLoader.popCards(count: 2)
        self.init(cardLoader: cardLoader,
             cardboxes: Array(repeating: [], count: Constants.NUM_BOXES),
             cardboxAlgorithm: CardboxAlgorithm(),
             currentCard: ViewedCard(card: initialCards.removeFirst()),
             nextCard: ViewedCard(card: initialCards.removeFirst())
        )
        while until != nil && currentCard.card != until {
            advance(correct: true)
        }
    }
    
    init(cardLoader: CardLoader,
         cardboxes: [[Card]],
         cardboxAlgorithm: CardboxAlgorithm,
         currentCard: ViewedCard,
         nextCard: ViewedCard) {
        self.cardLoader = cardLoader
        self.cardboxes = cardboxes
        self.cardboxAlgorithm = cardboxAlgorithm
        self.currentCard = currentCard
        self.nextCard = nextCard
    }
    
    func advance(correct: Bool) {
        currentCard.correct = correct
        addCardsToCardboxZero()
        cycleCard()
    }
    
    func addCardsToCardboxZero() {
        let cardboxZeroDiff = max(Constants.CARDBOX_ZER0_MIN_SIZE - counts[0], 0)
        cardboxes[0].append(contentsOf: cardLoader.popCards(count: cardboxZeroDiff))
    }
    
    func cycleCard() {
        let markedCard = currentCard
        currentCard = nextCard
        
        let nextBox = cardboxAlgorithm.nextCardbox(cardboxes: cardboxes)
        nextCard = ViewedCard(card: cardboxes[nextBox].removeFirst(), box: nextBox)
        cardboxes[markedCard.newBox].append(markedCard.card)
        print("\(markedCard) moved to \(markedCard.newBox). Current card is now \(currentCard), next card is \(nextCard) popped from \(nextBox)")
    }
    
    enum CodingKeys: String, CodingKey {
        case _cardboxes = "cardboxes"
        case _cardboxAlgorithm = "cardboxAlgorithm"
        case _currentCard = "currentCard"
        case _nextCard = "nextCard"
    }
}
