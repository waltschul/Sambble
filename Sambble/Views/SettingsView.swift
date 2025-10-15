import SwiftUI

struct SettingsView: View {
    @Binding var selectedQuiz: QuizID
    let quizCache: QuizCache
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Quiz").foregroundColor(Color.blue)) {
                        HStack {
                            Picker("", selection: $selectedQuiz) {
                                ForEach(quizCache.quizzes, id: \.self) { quizDef in
                                    Text(quizDef.rawValue)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(Constants.THEME)
                                        .tag(quizDef)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .labelsHidden()
                            
                            Spacer() // pushes the button to the right
                            
                            if (selectedQuiz.parameters.probabilityOrder) {
                                Button(action: { quizCache.initialize(id: selectedQuiz) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.white)              // icon color
                                        .padding(10)                          // make tappable area bigger
                                        .background(Color.red)                // background color
                                        .clipShape(Circle())                  // circular button
                                        .shadow(radius: 2)                    // subtle shadow for depth
                                }
                                .buttonStyle(PlainButtonStyle())              // avoid default button styling
                            }
                        }
                    }
                }
                .background(Color.black)
                .scrollContentBackground(.hidden)
            }
        }
        .onChange(of: selectedQuiz) { _, newValue in
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedQuiz")
        }
    }
}
