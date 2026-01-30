import SwiftUI

struct SettingsView: View {
    let quizCache: QuizCache
    @EnvironmentObject var settings: SettingsStore

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
                                    Text(quizDef.rawValue)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .tag(quizDef)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .labelsHidden()
                            
                            Spacer()
                            Button(action: { quizCache.removeQuiz(id: settings.selectedQuiz) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        QuizCardsPreviewView(quiz: quizCache.quizCache[settings.selectedQuiz], quizID: settings.selectedQuiz)
                            .padding(.top, 4)
                    }
                    
                    ColorPicker(
                        "Select Theme Color",
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
