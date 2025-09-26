import SwiftUI

struct CardView: View {
    let card: ViewedCard
    
    var body: some View {
        VStack {
            Text(card.card.id)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            Spacer().frame(height: 10)
            if (card.checked) {
                ForEach(card.card.words) { word in
                    HStack(alignment: .bottom) {
                        hookText(text: word.frontHooks, alignment: .trailing)
                        Text(word.id).foregroundColor(.white)
                        hookText(text: word.backHooks, alignment: .leading)
                    }
                    .debugOutline()
                }
            }
        }
            .frame(height: 150, alignment: .top)
            .debugOutline()
    }
}

extension CardView {
    func hookText(text: String, alignment: Alignment) -> some View {
        Text(text)
            .foregroundColor(.gray)
            .frame(width: 100, alignment: alignment)
            .font(.system(size: 10))
    }
}
