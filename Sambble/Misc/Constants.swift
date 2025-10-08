import Foundation
import SwiftUI

struct Constants {
    #if DEBUG
    static let DEBUG = true
    #else
    static let DEBUG = false
    #endif
    
    static var VERSION = 0
    static let NUM_BOXES: Int = 10
    static let CARDBOX_ZER0_MIN_SIZE = 5
    static let OVERLAY_PADDING: Double = 16
    static let THEME = Color.mint
    static let tileCounts: [String: Int] = [
        "A": 9, "B": 2, "C": 2, "D": 4, "E": 12, "F": 2, "G": 3, "H": 2, "I": 9, "J": 1, "K": 1, "L": 4, "M": 2, "N": 6, "O": 8, "P": 2, "Q": 1, "R": 6, "S": 4, "T": 6, "U": 4, "V": 2, "W": 2, "X": 1, "Y": 2, "Z": 1
    ]
    
    static let THREES = QuizDefinition(id: "Threes", quizParameters: QuizParameters(probabilityOrder: false, filter: { $0.count == 3}))
    static let FOURS = QuizDefinition(id: "Fours", quizParameters: QuizParameters(probabilityOrder: false, filter: { $0.count == 4}))
    static let FIVES = QuizDefinition(id: "JKQXZ Fives", quizParameters: QuizParameters(probabilityOrder: false, filter: { $0.count == 5 && $0.contains { "JKQXZ".contains($0) } }))
    static let SEVENS = QuizDefinition(id: "Sevens", quizParameters: QuizParameters(probabilityOrder: true, filter: { $0.count == 7 }))
    static let EIGHTS = QuizDefinition(id: "Eights", quizParameters: QuizParameters(probabilityOrder: true, filter: { $0.count == 8 }))
    static let QUIZZES: [QuizDefinition] = [THREES, FOURS, FIVES, SEVENS, EIGHTS]
    static let PREVIEW_QUIZZES: [QuizDefinition] = [THREES, FIVES]
}
