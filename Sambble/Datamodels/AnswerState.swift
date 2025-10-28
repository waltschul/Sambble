enum AnswerState: Codable {
    case UNCHECKED
    case CHECKED
    case EASY
    
    func nextState() -> AnswerState {
        switch self {
            case .UNCHECKED: return .CHECKED
            case .CHECKED: return .EASY
            case .EASY: return .CHECKED
        }
    }
}
