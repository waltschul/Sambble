class CardboxAlgorithm: Codable {
    var count: Int = 0
    var incrementFlag: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case count
        case incrementFlag
    }
    
    init() {
        self.count = 0
        self.incrementFlag = false
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = (try? container.decode(Int.self, forKey: .count)) ?? 0
        incrementFlag = (try? container.decode(Bool.self, forKey: .incrementFlag)) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(incrementFlag, forKey: .incrementFlag)
    }
    
    func nextCardbox(cardboxes: [[Card]], moreNewWords: Bool = false) -> Int {
        if !moreNewWords {
            count += 1
        } else {
            if count % 2 != 0 {
                // Odd count - alternate between incrementing and staying
                if incrementFlag {
                    count += 1
                    incrementFlag = false
                } else {
                    incrementFlag = true
                }
            } else {
                // Even count - always increment
                count += 1
            }
        }
        
        print("[DEBUG] count: \(count), incrementFlag: \(incrementFlag), cardboxes states: \(cardboxes.map { $0.count })")
        
        let cardbox = Array(cardboxes.enumerated())
            .lastIndex { !$1.isEmpty && count % (1 << $0) == 0 }
            ?? cardboxes.firstIndex { !$0.isEmpty }!
        print("[DEBUG] Selecting cardbox \(cardbox) for count \(count)")
        if count == 1 << Constants.NUM_BOXES {
            count = 0
            incrementFlag = false
        }
        return cardbox
    }
}
