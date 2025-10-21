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
            print (selectedQuiz)
            self.selectedQuiz = QuizID(rawValue: selectedQuiz)!
        } else {
            print (UserDefaults.standard.string(forKey: "selectedQuiz"))
            self.selectedQuiz = quizCache.quizzes.first!
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    if let existingQuiz = quizCache.quizCache[selectedQuiz] {
                        QuizView(id: selectedQuiz, quiz: existingQuiz)
                    } else {
                        InitializeView(
                            quizID: selectedQuiz,
                            cardLoader: CardLoader(quizParameters: selectedQuiz.parameters),
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
                            .padding(Constants.OVERLAY_PADDING) // increase tappable area
                    }
                    .debugOutline(),
                    alignment: .topTrailing)
            }
        }
    }
}
