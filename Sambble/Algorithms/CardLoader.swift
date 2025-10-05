import Foundation
import Combine

class CardLoader {
    static let blankTileCount = 2
    var cards: [Card]
    
    init(quizDefinition: QuizDefinition, excludeCards: [Card] = []) {
        self.cards = CardLoader.loadCards(
            resource: "nwl23",
            quizDefinition: quizDefinition,
            excludeCards: excludeCards);
    }
    
    func cardAt(index: Double) -> (Int, Card) {
        let index = Int(index * Double(cards.count - 1))
        return (index, cards[index])
    }
    
    func nextCards(count: Int) -> [Card] {
        let count = min(count, cards.count)
        let poppedCards = Array(cards.prefix(count))
        cards.removeFirst(count)
        return poppedCards
    }
    
    private static func loadCards(resource: String, quizDefinition: QuizDefinition, excludeCards: [Card]) -> [Card] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "txt"),
              let data = try? Data(contentsOf: url),
              let content = String(data: data, encoding: .utf8) else { 
            print("[DEBUG] Failed to load resource \(resource)")
            return []
        }
        
        let allWords = Set(content.components(separatedBy: .newlines).map { $0.uppercased() })
        let words = allWords.filter(quizDefinition.filter)
        
        let anagramGroups = Dictionary(grouping: words) { String($0.sorted()) }
        var cards: [(probability: Double, card: Card)] = []
        let excludeSet = Set(excludeCards.map { $0.id })

        for (key, words) in anagramGroups {
            if excludeSet.contains(key) { continue }
            var wordsWithHooks: [Word] = []
            for word in words.sorted() {
                var frontHooks = ""
                var backHooks = ""
                for c in Constants.tileCounts.keys {
                    if allWords.contains(c + word) { frontHooks += c }
                    if allWords.contains(word + c) { backHooks += c }
                }
                wordsWithHooks.append(Word(id: word, frontHooks: frontHooks, backHooks: backHooks))
            }
            cards.append((probability: probabilityWeight(letters: key), card: Card(id: key, words: wordsWithHooks)))
        }
        print("All cards: \(anagramGroups.count), Excluded cards: \(excludeSet.count), Selected cards: \(cards.count)")
        
        return cards.sorted {
                $0.probability != $1.probability
                    ? $0.probability > $1.probability
                    : $0.card.id < $1.card.id
            }
            .map { $0.card }
    }
    
    private static func probabilityWeight(letters: String) -> Double {
        var letterCounts: [Character: Int] = [:]
        for c in letters {
            letterCounts[c, default: 0] += 1
        }

        return probabilityWithBlanks(letterCounts: letterCounts, blanksUsed: 0)
    }

    private static func probabilityWithBlanks(letterCounts: [Character: Int], blanksUsed: Int) -> Double {
        if blanksUsed > blankTileCount { return 0.0 }
        if letterCounts.isEmpty { return 1.0 }

        let remainingBlanks = blankTileCount - blanksUsed
        let letters = Array(letterCounts.keys)
        let firstLetter = letters[0]
        let count = letterCounts[firstLetter]!
        let remainingLetters = letterCounts.filter { $0.key != firstLetter }

        let avail = Constants.tileCounts[String(firstLetter.uppercased())] ?? 0
        var totalProb: Double = 0.0

        let minBlanksNeeded = max(0, count - avail)
        let maxBlanksUsable = min(remainingBlanks, count)

        guard minBlanksNeeded <= maxBlanksUsable else { return 0.0 }

        for blanksForThisLetter in minBlanksNeeded...maxBlanksUsable {
            let regularForThisLetter = count - blanksForThisLetter

            let probForThisChoice = Double(combination(n: avail, k: regularForThisLetter)) *
                                   Double(combination(n: remainingBlanks, k: blanksForThisLetter))

            let probForRest = probabilityWithBlanks(letterCounts: remainingLetters, blanksUsed: blanksUsed + blanksForThisLetter)

            totalProb += probForThisChoice * probForRest
        }

        return totalProb
    }
    
    private static func combination(n: Int, k: Int) -> Int {
        if k > n { return 0 }
        if k == 0 { return 1 }
        var result = 1
        for i in 0..<k {
            result *= (n - i)
            result /= (i + 1)
        }
        return result
    }
}
