import Foundation
import SwiftSoup

class RatingScraper {
    let url: URL
    
    static let playerIDs: [String: Int] = [
            "Sam Masling": 20234,
            "Dan Wachtell": 2483
        ]
    
    init(player: String) {
        let id = RatingScraper.playerIDs[player]!
        self.url = URL(string: "https://www.cross-tables.com/results.php?p=\(id)")!
    }

    func fetchRating() async -> String {
        do {
            let html = try String(contentsOf: url, encoding: .utf8)
            let doc = try SwiftSoup.parse(html)
            if let ratingElement = try doc.select("span.mainrating").first() {
                let ratingText = try ratingElement.text()
                return ratingText
            }
            return "?"
        } catch {
            return "?"
        }
    }
}
