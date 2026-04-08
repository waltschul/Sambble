struct QuizParameters {
    let probabilityOrder: Bool
    let alphagramFilter: ((String) -> Bool)?
    let wordFilter: ((String) -> Bool)?

    /// Convenience init for built-in quizzes that filter on alphagram strings.
    init(probabilityOrder: Bool, filter: @escaping (String) -> Bool) {
        self.probabilityOrder = probabilityOrder
        self.alphagramFilter = filter
        self.wordFilter = nil
    }

    /// Init for PATTERN-mode custom quizzes that filter on individual word strings.
    init(probabilityOrder: Bool, wordFilter: @escaping (String) -> Bool) {
        self.probabilityOrder = probabilityOrder
        self.alphagramFilter = nil
        self.wordFilter = wordFilter
    }
}
