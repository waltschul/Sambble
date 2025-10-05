struct QuizDefinition {
    let name: String
    let probabiltyOrder: Bool
    let filter: (String) -> Bool
}
