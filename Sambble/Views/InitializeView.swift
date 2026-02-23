import SwiftUI

struct InitializeView: View {
    let quizID: QuizID
    let cardLoader: CardLoader
    let quizCache: QuizCache
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State var value: Double = 0
    private var isLandscape: Bool { verticalSizeClass == .compact }
    private var topSpacerLength: CGFloat { isLandscape ? 80 : 220 }
    var index: Int {
        min(Int(value), cardLoader.cards.count - 1)
    }
    var card: Card {
        cardLoader.cards.elements[index].value
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: topSpacerLength)
            Button(action: { makeQuiz() }) {
                Image(systemName: "text.book.closed.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Circle().fill(settings.themeColor))
                    .shadow(radius: 4)
            }
            .padding(.bottom, 8)
            Text("\(String(index + 1)) / \(String(cardLoader.cards.count))")
                .foregroundColor(.white)
            Slider(value: $value, in: 0...Double(cardLoader.cards.count))
                .accentColor(settings.themeColor)
                .frame(height: 0)
                .padding()
            CardView(card: ViewedCard(card: card, checked: AnswerState.CHECKED))
                .frame(maxHeight: 600)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func makeQuiz() {
        quizCache.quizCache[quizID] = Quiz(cardLoader: cardLoader, until: card)
    }
}
