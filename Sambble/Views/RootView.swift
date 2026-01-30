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
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let insets = geo.safeAreaInsets
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Group {
                        if isLandscape {
                            HStack(alignment: .top, spacing: 0) {
                                if let existingQuiz = quizCache.quizCache[selectedQuiz] {
                                    CardboxView(quiz: existingQuiz)
                                        .padding()
                                        .padding(.top, insets.top)
                                        .padding(.leading, insets.leading)
                                }
                                mainContent(isLandscape: isLandscape, safeArea: insets)
                            }
                        } else {
                            mainContent(isLandscape: isLandscape, safeArea: insets)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea(.all)
                    .overlay(
                        NavigationLink(destination: SettingsView(quizCache: quizCache)) {
                            Image(systemName: "gearshape")
                                .imageScale(.large)
                                .foregroundColor(settings.themeColor)
                                .padding(Constants.OVERLAY_PADDING) // increase tappable area
                        }
                        .padding(.top, insets.top)
                        .padding(.trailing, insets.trailing)
                        .debugOutline(),
                        alignment: .topTrailing)
                    
                }
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func mainContent(isLandscape: Bool, safeArea: EdgeInsets) -> some View {
        if let existingQuiz = quizCache.quizCache[selectedQuiz] {
            QuizView(id: selectedQuiz, quiz: existingQuiz)
                .id(ObjectIdentifier(existingQuiz))
                .overlay(alignment: .topLeading) {
                    if !isLandscape {
                        CardboxView(quiz: existingQuiz)
                            .padding(.all)
                            .padding(.top, safeArea.top)
                            .padding(.leading, safeArea.leading)
                    }
                }
                .overlay(alignment: .top) {
                    ScoreView(id: selectedQuiz, quiz: existingQuiz)
                        .padding(.top, safeArea.top)
                }
        } else {
            InitializeView(
                quizID: selectedQuiz,
                cardLoader: CardLoader(quizParameters: selectedQuiz.parameters),
                quizCache: quizCache
            )
        }
    }
}
