struct Card: Codable, Equatable {
    let id: String
    let words: [Word]

    init(id: String, words: [Word]) {
        self.id = id
        self.words = words
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let id = try container.decode(String.self)
        let cardLoader = decoder.userInfo[.cardLoader] as! CardLoader
        self = cardLoader.removeCard(id: id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}

