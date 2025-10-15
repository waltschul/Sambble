enum QuizID: String, CaseIterable {
    case THREES = "Threes"
    case FOURS = "Fours"
    case JKQXZ_FIVES = "JKQXZ Fives"
    case SEVENS = "Sevens"
    case EIGHTS = "Eights"
    case FIVE_VOWEL_EIGHTS = "5 Vowel Eights"

    var parameters: QuizParameters {
        switch self {
        case .THREES:
            return QuizParameters(probabilityOrder: false, filter: { $0.count == 3 })
        case .FOURS:
            return QuizParameters(probabilityOrder: false, filter: { $0.count == 4 })
        case .JKQXZ_FIVES:
            return QuizParameters(probabilityOrder: false, filter: { $0.count == 5 && $0.contains { "JKQXZ".contains($0) } })
        case .SEVENS:
            return QuizParameters(probabilityOrder: true, filter: { $0.count == 7 })
        case .EIGHTS:
            return QuizParameters(probabilityOrder: true, filter: { $0.count == 8 })
        case .FIVE_VOWEL_EIGHTS:
            return QuizParameters(probabilityOrder: true, filter: {
                $0.count == 8 && $0.filter { "AEIOU".contains($0.uppercased()) }.count == 5
            })
        }
    }
}
