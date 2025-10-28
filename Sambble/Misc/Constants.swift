import Foundation
import SwiftUI

struct Constants {
    #if DEBUG
    static let DEBUG = true
    #else
    static let DEBUG = false
    #endif
    
    static let NUM_BOXES: Int = 10
    static let CARDBOX_ZER0_MIN_SIZE = 5
    static let OVERLAY_PADDING: Double = 16
    static let THEME = Color.mint
    static let GREEN = Color(red: 0.5, green: 1.0, blue: 0.5)
    static let tileCounts: [String: Int] = [
        "A": 9, "B": 2, "C": 2, "D": 4, "E": 12, "F": 2, "G": 3, "H": 2, "I": 9, "J": 1, "K": 1, "L": 4, "M": 2, "N": 6, "O": 8, "P": 2, "Q": 1, "R": 6, "S": 4, "T": 6, "U": 4, "V": 2, "W": 2, "X": 1, "Y": 2, "Z": 1
    ]
    static let PREVIEW_QUIZZES: [QuizID] = [QuizID.THREES, QuizID.SEVENS]
}
