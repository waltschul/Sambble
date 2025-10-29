import SwiftUI

#Preview {
    RootView().environmentObject(SettingsStore.shared)
}

struct RootView: View {
    @State var quizCache: QuizCache
    @EnvironmentObject var settings: SettingsStore
    private var selectedQuiz: QuizID {
        settings.selectedQuiz
    }
    
    init() {
        self.quizCache = QuizCache()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    if let existingQuiz = quizCache.quizCache[selectedQuiz] {
                        QuizView(id: selectedQuiz,
                                 quiz: existingQuiz)
                        .overlay(
                            CardboxView(quiz: existingQuiz)
                                .padding(.all),
                            alignment: .topLeading
                        )
                        .overlay(
                            ScoreView(id: selectedQuiz,
                                      quiz: existingQuiz),
                            alignment: .top
                        )
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
                    NavigationLink(destination: SettingsView(quizCache: quizCache, settings: settings)) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                            .foregroundColor(settings.themeColor)
                            .padding(Constants.OVERLAY_PADDING) // increase tappable area
                    }
                    .debugOutline(),
                    alignment: .topTrailing)
            }
        }
    }
}
