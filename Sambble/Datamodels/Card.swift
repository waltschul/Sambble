enum CardStatus: String, Codable, Equatable {
    case normal
    case new
    case treat
}

struct Card: Codable, Equatable {
    let id: String
    let words: [Word]
    var status: CardStatus

    init(id: String, words: [Word], status: CardStatus = .normal) {
        self.id = id
        self.words = words
        self.status = status
    }

    init(from decoder: Decoder) throws {
        let id: String
        let status: CardStatus
        do {
            let container = try decoder.singleValueContainer()
            id = try container.decode(String.self)
            status = .normal
        } catch {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            status = try container.decodeIfPresent(CardStatus.self, forKey: .status) ?? .normal
        }
        let cardLoader = decoder.userInfo[.cardLoader] as! CardLoader
        let card = cardLoader.removeCard(id: id)
        self.id = card.id
        self.words = card.words
        self.status = status
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(status, forKey: .status)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case status
    }
}

