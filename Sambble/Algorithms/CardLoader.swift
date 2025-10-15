import Foundation
import Combine
import SwiftCSV

class CardLoader: Codable {
    static let blankTileCount = 2
    var cards: [Card]
    
    init(quizParameters: QuizParameters) {
        let url = Bundle.main.url(forResource: "nwl23", withExtension: "csv")!
        let csv = try! CSV<Named>(url: url)
        self.cards = CardLoader.loadCards(csv: csv, quizParameters: quizParameters);
    }
    
    func nextCards(count: Int) -> [Card] {
        let count = min(count, cards.count)
        let poppedCards = Array(cards.prefix(count))
        cards.removeFirst(count)
        return poppedCards
    }
    
    static func loadCards(csv: CSV<Named>, quizParameters: QuizParameters) -> [Card] {
        // Step 1: Filter rows and map to (alphagram, Word) tuples in one chain
        let wordsWithAlphagram: [(alphagram: String, word: Word)] = csv.rows
            .filter { quizParameters.filter($0["alphagram"]!) }
            .map { row in
                let word = Word(
                    id: row["word"]!,
                    frontHooks: row["front_hooks"]!,
                    backHooks: row["back_hooks"]!,
                    definition: row["definition"]!
                )
                return (row["alphagram"]!, word)
            }

        // Step 2: Group words by alphagram while preserving order
        var seenAlphagrams: [String] = []
        var grouped: [String: [Word]] = [:]

        for entry in wordsWithAlphagram {
            if grouped[entry.alphagram] == nil {
                grouped[entry.alphagram] = [entry.word]
                seenAlphagrams.append(entry.alphagram)
            } else {
                grouped[entry.alphagram]?.append(entry.word)
            }
        }

        // Step 3: Build Cards
        var cards = seenAlphagrams.map { Card(id: $0, words: grouped[$0]!) }

        // Step 4: Shuffle if probabilityOrder is false
        if !quizParameters.probabilityOrder {
            cards.shuffle()
        }

        return cards
    }
}
