import SwiftUI

struct CardView: View {
    let card: ViewedCard
    @State private var definedWords: Set<String> = [] // Track revealed word IDs
    
    var body: some View {
        VStack {
            Text(card.card.id)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            Spacer().frame(height: 10)
            if (card.checked) {
                ForEach(card.card.words) { word in
                    VStack(alignment: .center) {
                            HStack(alignment: .bottom) {
                                hookText(text: word.frontHooks, alignment: .trailing)
                                Text(word.id)
                                    .foregroundColor(.white)
                                    .debugOutline()
                                hookText(text: word.backHooks, alignment: .leading)
                            }
                        //TODO inconsistent?
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if (card.checked) {
                                    definedWords.insert(word.id)
                                }
                            }
                            .debugOutline()
                            
                            if definedWords.contains(word.id) {
                                Text(word.definition)
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.top, 2)
                                    .debugOutline()
                            }
                        }
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
