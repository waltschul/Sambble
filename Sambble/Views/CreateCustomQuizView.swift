import SwiftUI

struct CreateCustomQuizView: View {
    let quizCache: QuizCache
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var expression: String = ""
    @State private var mode: MatchMode = .anagram
    @State private var probabilityOrder: Bool = false
    @State private var cardCount: Int? = nil
    @State private var wordCount: Int? = nil
    @State private var isCounting: Bool = false
    @State private var countTask: Task<Void, Never>? = nil

    /// Uppercased, stripped to only valid characters (A-Z and @).
    private var normalizedExpression: String {
        expression.uppercased().filter { $0.isLetter && $0.isASCII || $0 == "@" }
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !normalizedExpression.isEmpty &&
        (cardCount ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Quiz Name")) {
                    TextField("Name", text: $name)
                }

                Section(header: Text("Pattern")) {
                    HStack {
                        TextField("@ = Wildcard", text: $expression)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .onChange(of: expression) { scheduleCount() }
                        Spacer()
                        wordCountView
                    }

                    Picker("Mode", selection: $mode) {
                        ForEach(MatchMode.allCases, id: \.self) { m in
                            Text(m.displayName).tag(m)
                        }
                    }
                    .onChange(of: mode) { scheduleCount() }
                }

                Section {
                    Toggle("Probability Order", isOn: $probabilityOrder)
                }
            }
            .navigationTitle("Custom Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { create() }
                        .disabled(!canCreate)
                }
            }
        }
    }

    @ViewBuilder
    private var wordCountView: some View {
        if isCounting {
            ProgressView().scaleEffect(0.75)
        } else if let words = wordCount {
            if words > 0 {
                Text("\(words) words")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                Text("No matches")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
        }
    }

    private func scheduleCount() {
        countTask?.cancel()
        let expr = normalizedExpression
        guard !expr.isEmpty else {
            isCounting = false
            cardCount = nil
            wordCount = nil
            return
        }
        isCounting = true
        cardCount = nil
        wordCount = nil
        let m = mode
        countTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            let result = await Task.detached(priority: .userInitiated) {
                countMatchingCards(expression: expr, mode: m)
            }.value
            guard !Task.isCancelled else { return }
            cardCount = result.cards
            wordCount = result.words
            isCounting = false
        }
    }

    private func create() {
        let spec = CustomQuizSpec(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            expression: normalizedExpression,
            mode: mode,
            probabilityOrder: probabilityOrder
        )
        quizCache.addCustomQuiz(spec: spec)
        settings.selectedQuizIdentifier = .custom(spec)
        dismiss()
    }
}
