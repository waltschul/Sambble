import Foundation

@Observable
class Quiz: Codable {
    var wordLength: Int
    var cardLoader: CardLoader
    var currentCard: ViewedCard
    var nextCard: ViewedCard
    var cardboxes: [[Card]]
    var count: Int
    var counts: [Int] {
        var counts = cardboxes.map { $0.count }
        counts[currentCard.nextBox] += 1
        counts[nextCard.nextBox] += 1
        return counts
    }
    var score: Int {
        counts.enumerated().reduce(0) { $0 + $1.0 * $1.1 }
    }
    
    init(wordLength: Int) {
        self.wordLength = wordLength
        let cardLoader = CardLoader(wordLength: wordLength)
        self.cardLoader = cardLoader
        cardboxes = Array(repeating: [], count: Constants.NUM_BOXES)
        count = 0
        var cards = cardLoader.nextCards(count: 2)
        currentCard = ViewedCard(card: cards.removeFirst(), box: 0)
        nextCard = ViewedCard(card: cards.removeFirst(), box: 0)
        addCards(count: 5, toBox: 0)
    }
    
    func addCards(count: Int, toBox: Int) {
        let cardsToAdd = cardLoader.nextCards(count: count)
        print("[DEBUG] Adding \(count) cards to box \(toBox): \(cardsToAdd.map { $0.id })")
        cardboxes[toBox].append(contentsOf: cardsToAdd)
    }
    
    func markCard(correct: Bool) {
        let markedCard = currentCard
        
        currentCard = nextCard
        nextCard = popCard()
        cardboxes[markedCard.nextBox].append(markedCard.card)
        
        if counts[0] < 5 {
            addCards(count: 1, toBox: 0)
        }
        saveQuiz(quiz: self)
    }
    
    func popCard() -> ViewedCard {
        count += 1
        var box = 0
        for (i, cardbox) in cardboxes.enumerated() {
            if (count % (1 << i) == 0 && !cardbox.isEmpty) {
                box = i
            }
        }
        
        if (count == 512) {
            count = 0
        }
        
        let card = cardboxes[box].removeFirst()
        print("[DEBUG] popCard: Popped '\(card.id)' from box \(box)")
        return ViewedCard(card: card, box: box)
    }
}

 
