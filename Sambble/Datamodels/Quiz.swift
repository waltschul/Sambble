import Foundation

@Observable
final class Quiz: Codable {
    var name: String
    var cardLoader: CardLoader
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
    
    init(name: String, cardLoader: CardLoader, until: Card? = nil) {
        var initialCards = cardLoader.nextCards(count: 2)
        self.name = name
        self.cardboxAlgorithm = CardboxAlgorithm()
        self.cardboxes = Array(repeating: [], count: Constants.NUM_BOXES)
        self.currentCard = ViewedCard(card: initialCards.removeFirst())
        self.nextCard = ViewedCard(card: initialCards.removeFirst())
        self.cardLoader = cardLoader
        while until != nil && currentCard.card != until {
            advance(correct: true)
        }
        saveQuiz(quiz: self)
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
        case _name = "name"
        case _cardLoader = "cardLoader"
        case _cardboxAlgorithm = "cardboxAlgorithm"
        case _currentCard = "currentCard"
        case _nextCard = "nextCard"
        case _cardboxes = "cardboxes"
    }
}
