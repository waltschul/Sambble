import Foundation

enum MatchMode: String, Codable, CaseIterable {
    case anagram
    case pattern

    var displayName: String {
        switch self {
        case .anagram: return "Anagram"
        case .pattern: return "Pattern"
        }
    }
}

struct CustomQuizSpec: Codable, Identifiable {
    let id: UUID
    var name: String
    let expression: String  // uppercased A-Z + @
    let mode: MatchMode
    let probabilityOrder: Bool

    var parameters: QuizParameters {
        switch mode {
        case .anagram:
            return QuizParameters(probabilityOrder: probabilityOrder,
                                  filter: makeAnagramFilter(expression: expression))
        case .pattern:
            return QuizParameters(probabilityOrder: probabilityOrder,
                                  wordFilter: makePatternFilter(expression: expression))
        }
    }
}

extension CustomQuizSpec: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension CustomQuizSpec: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

// MARK: - Filter constructors

/// Returns a filter that accepts alphagrams which are anagrams of `expression`.
/// `@` in the expression acts as a wildcard matching any single letter.
func makeAnagramFilter(expression: String) -> (String) -> Bool {
    let expr = expression.uppercased()
    let wildcardCount = expr.filter { $0 == "@" }.count
    let literals = expr.filter { $0 != "@" }.sorted()
    let targetLength = expr.count

    return { alphagram in
        guard alphagram.count == targetLength else { return false }
        var remaining = Array(alphagram)
        for ch in literals {
            guard let idx = remaining.firstIndex(of: ch) else { return false }
            remaining.remove(at: idx)
        }
        // remaining.count == wildcardCount (guaranteed by length check)
        return remaining.count == wildcardCount
    }
}

/// Returns a filter that accepts words matching `expression` positionally.
/// `@` in the expression acts as a wildcard matching any single letter.
func makePatternFilter(expression: String) -> (String) -> Bool {
    let pattern = Array(expression.uppercased())
    return { word in
        let chars = Array(word.uppercased())
        guard chars.count == pattern.count else { return false }
        for (p, c) in zip(pattern, chars) {
            if p == "@" { continue }
            if p != c { return false }
        }
        return true
    }
}
