struct Word: Codable, Identifiable, Equatable {
    let id: String
    let frontHooks: String
    let backHooks: String
    let definition: String
}
