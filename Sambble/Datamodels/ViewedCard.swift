import Foundation

@Observable
class ViewedCard: Codable {
    var card: Card
    var box: Int
    var checked: AnswerState
    var correct: CorrectState

    var newBox: Int {
        switch correct {
            //TODO configurable
            case .CORRECT:  return min(box + (checked == .EASY ? 5 : 1), Constants.NUM_BOXES - 1)
            case .INCORRECT: return 0
            case .UNANSWERED:   return box
        }
    }
    
    init(card: Card,
         box: Int = 0,
         checked: AnswerState = AnswerState.UNCHECKED,
         correct: CorrectState = CorrectState.UNANSWERED) {
        self.card = card
        self.box = box
        self.checked = checked
        self.correct = correct
    }
    
    //TODO backwards compat -- remove after Sam and Katie get it
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode card and box normally
        let card = try container.decode(Card.self, forKey: ._card)
        let box = try container.decode(Int.self, forKey: ._box)
        
        // Decode checked: try enum first, fall back to old Bool
        let checked: AnswerState
        if let newChecked = try? container.decode(AnswerState.self, forKey: ._checked) {
            checked = newChecked
        } else if let oldChecked = try? container.decode(Bool.self, forKey: ._checked) {
            checked = oldChecked ? .CHECKED : .UNCHECKED
        } else {
            checked = .UNCHECKED
        }
        
        // Decode correct: try enum first, fall back to old Bool
        let correct: CorrectState
        if let newCorrect = try? container.decode(CorrectState.self, forKey: ._correct) {
            correct = newCorrect
        } else if let oldCorrect = try? container.decode(Bool?.self, forKey: ._correct) {
            correct = oldCorrect == true ? .CORRECT :
                      oldCorrect == false ? .INCORRECT : .UNANSWERED
        } else {
            correct = .UNANSWERED
        }
        
        self.init(card: card, box: box, checked: checked, correct: correct)
    }
    
    enum CodingKeys: String, CodingKey {
        case _card = "card"
        case _box = "box"
        case _checked = "checked"
        case _correct = "correct"
    }
}

extension ViewedCard: CustomStringConvertible {
    var description: String {
        "\(card.id)"
    }
}
