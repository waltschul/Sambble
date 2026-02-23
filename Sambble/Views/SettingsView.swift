import SwiftUI

struct SettingsView: View {
    let quizCache: QuizCache
    @EnvironmentObject var settings: SettingsStore
    @State private var showDeleteConfirmation = false
    
    func progressText(for quizID: QuizID) -> String {
        guard let quiz = quizCache.quizCache[quizID] else {
            return ""
        }
        let nonBoxZeroAnagrams = quiz.score
        let totalAnagrams = quiz.cardLoader.totalWords
        guard totalAnagrams > 0 else { return "0%" }
        let pct = (nonBoxZeroAnagrams * 100) / totalAnagrams
        return "\(pct)%"
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    // Existing quiz picker
                    Section(header: Text("Quiz").foregroundColor(.blue)) {
                        HStack {
                            Picker("", selection: Binding(
                                get: { settings.selectedQuiz },
                                set: { settings.selectedQuiz = $0 }
                            )) {
                                ForEach(quizCache.quizzes, id: \.self) { quizDef in
                                    Text(quizDef.rawValue).tag(quizDef)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .labelsHidden()
                            Spacer()
                            Text(progressText(for: settings.selectedQuiz))
                                .foregroundColor(.gray)
                            if quizCache.quizCache[settings.selectedQuiz] != nil {
                                Button(action: { showDeleteConfirmation = true }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .alert("Delete Quiz", isPresented: $showDeleteConfirmation) {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Delete", role: .destructive) {
                                        quizCache.removeQuiz(id: settings.selectedQuiz)
                                    }
                                } message: {
                                    Text("Are you sure you want to delete \"\(settings.selectedQuiz.rawValue)\"? This cannot be undone.")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 2, trailing: 16))
                        .listRowSeparator(.hidden)
                        QuizCardsPreviewView(quiz: quizCache.quizCache[settings.selectedQuiz], quizID: settings.selectedQuiz)
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
    }
}
