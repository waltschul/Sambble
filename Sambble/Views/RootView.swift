import SwiftUI

#Preview {
    RootView()
}

struct RootView: View {
    @State var quizCache: QuizCache
    @State var selectedQuiz: QuizID
    
    init() {
        let quizCache = QuizCache()
        self.quizCache = quizCache
        self.selectedQuiz = quizCache.quizzes.first!
        if let selectedQuiz = UserDefaults.standard.string(forKey: "selectedQuiz") {
            self.selectedQuiz = QuizID(rawValue: selectedQuiz)!
        } else {
            self.selectedQuiz = quizCache.quizzes.first!
        }
        
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    if let existingQuiz = quizCache.quizCache[selectedQuiz] {
                        QuizView(quiz: existingQuiz)
                    } else {
                        InitializeView(
                            quizID: selectedQuiz,
                            cardLoader: quizCache.cardLoaderCache[selectedQuiz]!,
                            quizCache: quizCache
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    NavigationLink(destination: SettingsView(selectedQuiz: $selectedQuiz, quizCache: quizCache)) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                            .foregroundColor(Constants.THEME)
                            .contentShape(Rectangle()) // make entire padded area tappable

                    }.padding(.all)
                    .debugOutline(),
                    alignment: .topTrailing)
            }
        }
    }
}
