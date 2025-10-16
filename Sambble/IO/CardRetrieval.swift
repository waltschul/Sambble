import Foundation
import OrderedCollections
import SwiftCSV

func loadCards(url: URL, quizParameters: QuizParameters) -> OrderedDictionary<String, Card> {
    var words: OrderedDictionary<String, [Word]> = [:]
    (try! CSV<Named>(url: url)).rows
         .filter { quizParameters.filter($0["alphagram"]!) }
         .forEach { row in
             let word = Word(
                 id: row["word"]!,
                 frontHooks: row["front_hooks"]!,
                 backHooks: row["back_hooks"]!,
                 definition: row["definition"]!
             )
             let alphagram = row["alphagram"]!
             words[alphagram, default: []].append(word)
         }
    
    var cards = OrderedDictionary(
        uniqueKeysWithValues: words.map { (alphagram, words) in
            (alphagram, Card(id: alphagram, words: words))
        }
    )
    //TODO is this no-op or not?
    if (!quizParameters.probabilityOrder) {
        cards.shuffle()
    }
    return cards
}
