import Foundation

@Observable
class ViewedCard: Codable {
    var card: Card
    var box: Int
    var checked: Bool
    var correct: Bool?
    var newBox: Int {
        switch correct {
        case .some(true):  return min(box + 1, Constants.NUM_BOXES - 1)
            case .some(false): return 0
            case .none:   return box
        }
    }
    
    init(card: Card, box: Int = 0, checked: Bool = false, correct: Bool? = nil) {
        self.card = card
        self.box = box
        self.checked = checked
        self.correct = correct
    }
    
    enum CodingKeys: String, CodingKey {
        case _card = "card"
        case _box = "box"
        case _checked = "checked"
    }
}

extension ViewedCard: CustomStringConvertible {
    var description: String {
        "\(card.id)"
    }
}
