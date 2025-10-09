import SwiftUI

#Preview {
    RootView(quizCache: QuizCache(quizzes: Constants.PREVIEW_QUIZZES))
}

struct RootView: View {
    @State var quizCache: QuizCache
    @State var selectedQuiz: String
    
    init(quizCache: QuizCache) {
        self.quizCache = quizCache
        self.selectedQuiz = quizCache.quizzes.first!.id
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
                            name: selectedQuiz,
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
                    }.padding(.trailing),
                    alignment: .topTrailing)
            }
        }
    }
}
