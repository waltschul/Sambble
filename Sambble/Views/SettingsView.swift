import SwiftUI

struct SettingsView: View {
    let quizCache: QuizCache
    @EnvironmentObject var settings: SettingsStore
    @State private var showDeleteConfirmation = false
    @State private var showCreateCustomQuiz = false

    private var allIdentifiers: [QuizIdentifier] {
        quizCache.quizzes.map { .builtin($0) } +
        settings.customQuizzes.map { .custom($0) }
    }

    func progressText(for id: QuizIdentifier) -> String {
        let quiz: Quiz?
        switch id {
        case .builtin(let quizID): quiz = quizCache.quizCache[quizID]
        case .custom(let spec): quiz = quizCache.customQuizCache[spec.id]
        }
        guard let quiz else { return "" }
        let nonBoxZeroAnagrams = quiz.score
        let totalAnagrams = quiz.cardLoader.totalWords
        guard totalAnagrams > 0 else { return "0%" }
        let pct = (nonBoxZeroAnagrams * 100) / totalAnagrams
        return "\(pct)%"
    }

    func canDelete(_ id: QuizIdentifier) -> Bool {
        switch id {
        case .custom: return true
        case .builtin: return currentQuiz(for: id) != nil
        }
    }

    func currentQuiz(for id: QuizIdentifier) -> Quiz? {
        switch id {
        case .builtin(let quizID): return quizCache.quizCache[quizID]
        case .custom(let spec): return quizCache.customQuizCache[spec.id]
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: HStack {
                        Text("Quiz").foregroundColor(.blue)
                        Spacer()
                        Button(action: { showCreateCustomQuiz = true }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }) {
                        HStack {
                            Picker("", selection: Binding(
                                get: { settings.selectedQuizIdentifier },
                                set: { settings.selectedQuizIdentifier = $0 }
                            )) {
                                ForEach(allIdentifiers, id: \.self) { identifier in
                                    Text(identifier.displayName).tag(identifier)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .labelsHidden()
                            Spacer()
                            Text(progressText(for: settings.selectedQuizIdentifier))
                                .foregroundColor(.gray)
                            if canDelete(settings.selectedQuizIdentifier) {
                                Button(action: { showDeleteConfirmation = true }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .alert("Delete Quiz", isPresented: $showDeleteConfirmation) {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Delete", role: .destructive) {
                                        deleteSelectedQuiz()
                                    }
                                } message: {
                                    Text("Are you sure you want to delete \"\(settings.selectedQuizIdentifier.displayName)\"? This cannot be undone.")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 2, trailing: 16))
                        .listRowSeparator(.hidden)
                        QuizCardsPreviewView(quiz: currentQuiz(for: settings.selectedQuizIdentifier),
                                            id: settings.selectedQuizIdentifier)
                            .padding(.top, 0)
                    }

                    Toggle("Car Mode", isOn: Binding(
                        get: { settings.carMode },
                        set: { newValue in
                            settings.carMode = newValue
                            if newValue {
                                SilentAudioPlayer.shared.start()
                                MediaCommandManager.shared.start()
                            } else {
                                MediaCommandManager.shared.stop()
                            }
                        }
                    ))
                    .foregroundColor(.blue)

                    ColorPicker(
                        "Theme",
                        selection: Binding(
                            get: { settings.themeColor },
                            set: { settings.themeColor = $0 }
                        ),
                        supportsOpacity: false
                    )
                    .foregroundColor(.blue)
                }
                .background(Color.black)
                .scrollContentBackground(.hidden)
            }
        }
        .sheet(isPresented: $showCreateCustomQuiz) {
            CreateCustomQuizView(quizCache: quizCache)
        }
    }

    private func deleteSelectedQuiz() {
        switch settings.selectedQuizIdentifier {
        case .builtin(let id):
            quizCache.removeQuiz(id: id)
        case .custom(let spec):
            quizCache.removeCustomQuiz(spec: spec)
            settings.selectedQuizIdentifier = .builtin(.SEVENS)
        }
    }
}
