import Foundation
import OrderedCollections
import SwiftCSV

func loadCards(url: URL, quizParameters: QuizParameters) -> OrderedDictionary<String, Card> {
    var words: OrderedDictionary<String, [Word]> = [:]
    (try! CSV<Named>(url: url)).rows
         .filter { quizParameters.alphagramFilter?($0["alphagram"]!) ?? true }
         .forEach { row in
             let word = Word(
                 id: row["word"]!,
                 frontHooks: row["front_hooks"]! + (row["is_front_hook"]! == "1" ? "•" : ""),
                 backHooks: (row["is_back_hook"]! == "1" ? "•" : "") + row["back_hooks"]!,
                 definition: row["definition"]!
             )
             let alphagram = row["alphagram"]!
             words[alphagram, default: []].append(word)
         }

    // Post-grouping word filter: keep a card only if at least one word matches.
    if let wf = quizParameters.wordFilter {
        words = words.filter { _, wordList in wordList.contains { wf($0.id) } }
    }

    var cards = OrderedDictionary(
        uniqueKeysWithValues: words.map { (alphagram, words) in
            (alphagram, Card(id: alphagram, words: words))
        }
    )
    if (!quizParameters.probabilityOrder) {
        cards.shuffle()
    }
    return cards
}

// MARK: - Lightweight CSV index for real-time counting

/// Minimal alphagram/word pairs loaded once for fast custom quiz counting.
/// Only the first two CSV columns are read — no hooks or definitions.
private let allCSVPairs: [(alphagram: String, word: String)] = {
    guard let url = Bundle.main.url(forResource: "nwl23", withExtension: "csv"),
          let content = try? String(contentsOf: url, encoding: .utf8) else { return [] }
    var result: [(String, String)] = []
    result.reserveCapacity(90_000)
    var firstLine = true
    content.enumerateLines { line, _ in
        if firstLine { firstLine = false; return }
        // Extract alphagram (col 0) and word (col 1) without parsing the full row.
        guard let c1 = line.firstIndex(of: ",") else { return }
        let alphagram = String(line[line.startIndex..<c1])
        let afterC1 = line.index(after: c1)
        guard afterC1 < line.endIndex else { return }
        let rest = line[afterC1...]
        let word: String
        if let c2 = rest.firstIndex(of: ",") {
            word = String(rest[rest.startIndex..<c2])
        } else {
            word = String(rest)
        }
        result.append((alphagram, word))
    }
    return result
}()

/// Returns the number of matching cards (alphagrams) and total words across those cards.
/// Runs synchronously — call from a background Task for UI use.
func countMatchingCards(expression: String, mode: MatchMode) -> (cards: Int, words: Int) {
    guard !expression.isEmpty else { return (0, 0) }

    var matchingAlphagrams = Set<String>()

    switch mode {
    case .anagram:
        let filter = makeAnagramFilter(expression: expression)
        for (alphagram, _) in allCSVPairs where filter(alphagram) {
            matchingAlphagrams.insert(alphagram)
        }
    case .pattern:
        let filter = makePatternFilter(expression: expression)
        for (alphagram, word) in allCSVPairs where filter(word) {
            matchingAlphagrams.insert(alphagram)
        }
    }

    let totalWords = allCSVPairs.filter { matchingAlphagrams.contains($0.alphagram) }.count
    return (matchingAlphagrams.count, totalWords)
}
