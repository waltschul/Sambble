import Foundation

@Observable
class ViewedCard: Codable {
    var card: Card
    var box: Int
    var checked: Bool
    var correct: Bool?
    var nextBox: Int {
        switch correct {
        case .some(true):  return min(box + 1, Constants.NUM_BOXES - 1)
            case .some(false): return max(box - 1, 0)
            case .none:   return box
        }
    }
    
    init(card: Card, box: Int, checked: Bool = false, correct: Bool? = nil) {
        self.card = card
        self.box = box
        self.checked = checked
        self.correct = correct
    }
}
