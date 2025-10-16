import Foundation

@Observable
final class Quiz: Codable {
    let cardboxAlgorithm: CardboxAlgorithm = CardboxAlgorithm()
    let cardLoader: CardLoader
    
    //Serialized
    var quizID: QuizID
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
        return (cardboxes
            .dropFirst()
            .flatMap { $0 } +
        [currentCard.newBox != 0 ? currentCard.card : nil, nextCard.newBox != 0 ? nextCard.card : nil]
            .compactMap { $0 }).reduce(0) { $0 + $1.words.count }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quizID, forKey: ._quizID)
        try container.encode(currentCard, forKey: ._currentCard)
        try container.encode(nextCard, forKey: ._nextCard)
        
        let cardIDs = cardboxes.map { $0.map { $0.id } }
        try container.encode(cardIDs, forKey: ._cardboxes)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let quizID = try container.decode(QuizID.self, forKey: ._quizID)
        let cardLoader = CardLoader(quizParameters: quizID.parameters)
        self.init(quizID: quizID,
                  cardLoader: cardLoader,
                  cardboxes: (try container.decode([[String]].self, forKey: ._cardboxes)).map { $0.compactMap { cardLoader.removeCard(id: $0)} },
                  currentCard: try container.decode(ViewedCard.self, forKey: ._currentCard),
                  nextCard: try container.decode(ViewedCard.self, forKey: ._nextCard))
    }
    
    convenience init(quizID: QuizID, cardLoader: CardLoader, until: Card? = nil) {
        var initialCards = cardLoader.popCards(count: 2)
        self.init(quizID: quizID,
             cardLoader: cardLoader,
             cardboxes: Array(repeating: [], count: Constants.NUM_BOXES),
             currentCard: ViewedCard(card: initialCards.removeFirst()),
             nextCard: ViewedCard(card: initialCards.removeFirst())
        )
        while until != nil && currentCard.card != until {
            advance(correct: true)
        }
        persistQuiz(quiz: self)
    }
    
    init(quizID: QuizID, cardLoader: CardLoader, cardboxes: [[Card]], currentCard: ViewedCard, nextCard: ViewedCard) {
        self.quizID = quizID
        self.cardLoader = cardLoader
        self.cardboxes = cardboxes
        self.currentCard = currentCard
        self.nextCard = nextCard
    }
    
    func advance(correct: Bool) {
        currentCard.correct = correct
        addCardsToCardboxZero()
        cycleCard()
    }
    
    private func addCardsToCardboxZero() {
        let cardboxZeroDiff = max(Constants.CARDBOX_ZER0_MIN_SIZE - counts[0], 0)
        cardboxes[0].append(contentsOf: cardLoader.popCards(count: cardboxZeroDiff))
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
        case _quizID = "quizID"
        case _currentCard = "currentCard"
        case _nextCard = "nextCard"
        case _cardboxes = "cardboxes"
    }
}
