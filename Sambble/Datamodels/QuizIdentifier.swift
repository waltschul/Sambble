import Foundation

/// A type-safe identifier that can refer to either a built-in quiz or a user-created custom quiz.
enum QuizIdentifier {
    case builtin(QuizID)
    case custom(CustomQuizSpec)

    var displayName: String {
        switch self {
        case .builtin(let id): return id.rawValue
        case .custom(let spec): return spec.name
        }
    }

    var parameters: QuizParameters {
        switch self {
        case .builtin(let id): return id.parameters
        case .custom(let spec): return spec.parameters
        }
    }

    var probabilityOrder: Bool { parameters.probabilityOrder }

    /// The UUID of the custom spec, if this is a custom quiz.
    var customUUID: UUID? {
        if case .custom(let spec) = self { return spec.id }
        return nil
    }
}

// MARK: - Hashable & Equatable

extension QuizIdentifier: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .builtin(let id):
            hasher.combine(0)
            hasher.combine(id.rawValue)
        case .custom(let spec):
            hasher.combine(1)
            hasher.combine(spec.id)
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.builtin(let a), .builtin(let b)): return a == b
        case (.custom(let a), .custom(let b)): return a.id == b.id
        default: return false
        }
    }
}

// MARK: - Codable

extension QuizIdentifier: Codable {
    private enum CodingKeys: String, CodingKey {
        case builtin, custom
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let id = try container.decodeIfPresent(QuizID.self, forKey: .builtin) {
            self = .builtin(id)
        } else if let spec = try container.decodeIfPresent(CustomQuizSpec.self, forKey: .custom) {
            self = .custom(spec)
        } else {
            self = .builtin(.SEVENS)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .builtin(let id):
            try container.encode(id, forKey: .builtin)
        case .custom(let spec):
            try container.encode(spec, forKey: .custom)
        }
    }
}
