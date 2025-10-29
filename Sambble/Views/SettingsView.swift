import SwiftUI

struct SettingsView: View {
    let quizCache: QuizCache
    @EnvironmentObject var settings: SettingsStore
    
    @State private var cardboxZeroSizeLocal: Double
    @State private var easyAnswerShiftLocal: Double

    init(quizCache: QuizCache, settings: SettingsStore) {
        self.quizCache = quizCache
        _cardboxZeroSizeLocal = State(initialValue: Double(settings.cardboxZeroSize))
        _easyAnswerShiftLocal = State(initialValue: Double(settings.easyAnswerShift))
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
                    }
                    
                    Section(header: Text("Cardbox 0 Size").foregroundColor(.blue)) {
                        VStack(alignment: .leading) {
                            Slider(value: $cardboxZeroSizeLocal, in: 5...100, step: 1) { isEditing in
                                if !isEditing {
                                    settings.cardboxZeroSize = Int(cardboxZeroSizeLocal)
                                }
                            }
                            Text("\(Int(cardboxZeroSizeLocal))")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section(header: Text("Shift easy cards by # boxes").foregroundColor(.blue)) {
                        VStack(alignment: .leading) {
                            Slider(
                                value: $easyAnswerShiftLocal,
                                in: 5...9,
                                step: 1
                            ) { isEditing in
                                if !isEditing {
                                    settings.easyAnswerShift = Int(easyAnswerShiftLocal)
                                }
                            }
                            Text("\(Int(easyAnswerShiftLocal))")
                                .foregroundColor(.gray)
                        }
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
