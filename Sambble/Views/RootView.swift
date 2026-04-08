import SwiftUI

#Preview {
    RootView().environmentObject(SettingsStore.shared)
}

struct RootView: View {
    @State var quizCache: QuizCache
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var selectedIdentifier: QuizIdentifier {
        settings.selectedQuizIdentifier
    }

    init() {
        self.quizCache = QuizCache()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    quizContent
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    NavigationLink(destination: SettingsView(quizCache: quizCache)) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                            .foregroundColor(settings.themeColor)
                            .padding(Constants.OVERLAY_PADDING)
                    }
                    .debugOutline(),
                    alignment: .topTrailing)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                persistActiveQuiz()
            }
        }
    }

    @ViewBuilder
    private var quizContent: some View {
        switch selectedIdentifier {
        case .builtin(let id):
            if let quiz = quizCache.quizCache[id] {
                quizViewWithOverlays(identifier: selectedIdentifier, quiz: quiz)
            } else {
                InitializeView(
                    id: selectedIdentifier,
                    cardLoader: CardLoader(quizParameters: id.parameters),
                    quizCache: quizCache
                )
            }
        case .custom(let spec):
            if let quiz = quizCache.customQuizCache[spec.id] {
                quizViewWithOverlays(identifier: selectedIdentifier, quiz: quiz)
            } else {
                InitializeView(
                    id: selectedIdentifier,
                    cardLoader: CardLoader(quizParameters: spec.parameters),
                    quizCache: quizCache
                )
            }
        }
    }

    @ViewBuilder
    private func quizViewWithOverlays(identifier: QuizIdentifier, quiz: Quiz) -> some View {
        QuizView(id: identifier, quiz: quiz)
            .id(ObjectIdentifier(quiz))
            .overlay(
                Group {
                    if verticalSizeClass != .compact {
                        CardboxView(quiz: quiz)
                            .padding(.all)
                    }
                },
                alignment: .topLeading
            )
            .overlay(
                ScoreView(id: identifier, quiz: quiz),
                alignment: .top
            )
    }

    private func persistActiveQuiz() {
        switch selectedIdentifier {
        case .builtin(let id):
            if let quiz = quizCache.quizCache[id] { persistQuiz(id: id, quiz: quiz) }
        case .custom(let spec):
            if let quiz = quizCache.customQuizCache[spec.id] { persistCustomQuiz(spec: spec, quiz: quiz) }
        }
    }
}
