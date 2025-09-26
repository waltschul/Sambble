struct Card: Codable {
    let id: String
    let words: [Word]
    let probability: Double
}

struct Word: Codable, Identifiable {
    let id: String
    let frontHooks: String
    let backHooks: String
}
