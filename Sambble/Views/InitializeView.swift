import SwiftUI

struct InitializeView: View {
    let quizID: QuizID
    let cardLoader: CardLoader
    let quizCache: QuizCache
    @State var value: Double = 0
    var index: Int {
        min(Int(value), cardLoader.cards.count - 1)
    }
    var card: Card {
        cardLoader.cards[index]
    }
    
    var body: some View {
        VStack {
            Button(action: { makeQuiz() }) {
                Image(systemName: "text.book.closed.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Circle().fill(Constants.THEME))
                    .shadow(radius: 4)
            }
            .padding(.bottom, 8)
            .debugOutline()
            Text("\(String(index + 1)) / \(String(cardLoader.cards.count))")
                .foregroundColor(.white)
                .debugOutline()
            Slider(value: $value, in: 0...Double(cardLoader.cards.count))
                .accentColor(Constants.THEME)
                .frame(height: 0)
                .padding()
                .debugOutline()
            CardView(card: ViewedCard(card: card, checked: true))
        }
        .debugOutline()
    }
    
    func makeQuiz() {
        quizCache.quizCache[quizID] = Quiz(name: quizID.rawValue,
                                           cardLoader: cardLoader,
                                           until: card)
    }
}
