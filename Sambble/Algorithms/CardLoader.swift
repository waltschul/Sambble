import Foundation
import Combine

//TODO somewhat AI-written
class CardLoader: Codable {
    private static let tileCounts: [String: Int] = [
        "A": 9, "B": 2, "C": 2, "D": 4, "E": 12, "F": 2, "G": 3, "H": 2, "I": 9, "J": 1, "K": 1, "L": 4, "M": 2, "N": 6, "O": 8, "P": 2, "Q": 1, "R": 6, "S": 4, "T": 6, "U": 4, "V": 2, "W": 2, "X": 1, "Y": 2, "Z": 1
    ]
    private var wordLength: Int
    private var index = 0
    private lazy var cards: [Card] = CardLoader.loadCards(resource: "nwl23", wordLength: wordLength)
    
    enum CodingKeys: String, CodingKey {
        case index, wordLength
    }

    init(wordLength: Int) {
        self.wordLength = wordLength
    }
    
    func nextCards(count: Int) -> [Card] {
        let to = index+count
        print("[DEBUG] Requesting \(count) cards from \(index) to \(to)")
        let cards = Array(cards[index..<to])
        index += count
        return cards
    }
    
    private static func loadCards(resource: String, wordLength: Int) -> [Card] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "txt"),
              let data = try? Data(contentsOf: url),
              let content = String(data: data, encoding: .utf8) else { 
            print("[DEBUG] Failed to load resource \(resource)")
            return []
        }
        
        let allWords = content.components(separatedBy: .newlines).map { $0.uppercased() };
        let words = allWords.filter { $0.count == wordLength }
        let wordsPlusOne = Set(allWords.filter { $0.count == wordLength + 1})
        
        let anagramGroups = Dictionary(grouping: words) { String($0.sorted()) }
        var cards : [Card] = []
        
        for (key, words) in anagramGroups {
            var wordsWithHooks: [Word] = []
            for word in words.sorted() {
                var frontHooks = ""
                var backHooks = ""
                for c in tileCounts.keys {
                    if wordsPlusOne.contains(c + word) { frontHooks += c }
                    if wordsPlusOne.contains(word + c) { backHooks += c }
                }
                wordsWithHooks.append(Word(id: word, frontHooks: frontHooks, backHooks: backHooks))
            }
            cards.append(Card(
                id: key,
                words: wordsWithHooks,
                probability: probabilityWeight(letters: key)
            ))
        }
        print("[DEBUG] Created \(cards.count) cards of length \(wordLength) from \(resource)")
        return cards.sorted { $0.probability > $1.probability }
    }
    
    private static func probabilityWeight(letters: String) -> Double {
        var letterCounts: [Character: Int] = [:]
        for c in letters {
            letterCounts[c, default: 0] += 1
        }
        var prob: Double = 1.0
        for (c, count) in letterCounts {
            let avail = tileCounts[String(c.uppercased())] ?? 0
            if count > avail { return 0.0 }
            prob *= Double(combination(n: avail, k: count))
        }
        return prob
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
