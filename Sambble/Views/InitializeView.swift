import SwiftUI

struct InitializeView: View {
    let cardLoader: CardLoader
    @State var value: Double = 0
    @Binding var quiz: Quiz?
    private var card: (index: Int, card: Card) {
        cardLoader.cardAt(index: value)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Slider(value: $value, in: 0...1)
                    .accentColor(.blue) // Fill color
                    .padding()
                Text("\(card.0 + 1) / \(cardLoader.cards.count)").foregroundColor(.white)
                CardView(card: ViewedCard(card: card.1, checked: true))
                Button(action: {
                    makeQuiz()
                }) {
                    Text("Create Quiz")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            
        }
    }
    
    func makeQuiz() {
        quiz = Quiz(wordLength: cardLoader.wordLength, index: card.0)
    }
}
