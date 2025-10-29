class CardboxAlgorithm: Codable {
    var count: Int = 0;
    
    func nextCardbox(cardboxes: [[Card]]) -> Int {
        count += 1
        print("[DEBUG] count: \(count), cardboxes states: \(cardboxes.map { $0.count })")
        let cardbox = Array(cardboxes.enumerated())
            .lastIndex { !$1.isEmpty && count % (1 << $0) == 0 }
            ?? cardboxes.lastIndex { !$0.isEmpty }!
        print("[DEBUG] Selecting cardbox \(cardbox) for count \(count)")
        if count == 1 << Constants.NUM_BOXES {
            count = 0
        }
        return cardbox
    }
}
