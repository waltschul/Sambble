import SwiftUI

struct CardView: View {
    let card: ViewedCard
    @EnvironmentObject var settings: SettingsStore
    var color: Color {
        card.checked == .EASY ? settings.themeColor : .white
    }
    @State var definedWords: Set<String> = []
    
    var body: some View {
        VStack {
            Text(card.card.id)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
            Spacer().frame(height: 10)
            if (card.checked != .UNCHECKED) {
                ForEach(card.card.words) { word in
                    VStack(alignment: .center) {
                            HStack(alignment: .bottom) {
                                hookText(text: word.frontHooks, alignment: .trailing)
                                Text(word.id)
                                    .foregroundColor(color)
                                    .debugOutline()
                                hookText(text: word.backHooks, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .highPriorityGesture(TapGesture().onEnded {
                                definedWords.insert(word.id)
                            })
                            .debugOutline()
                            if definedWords.contains(word.id) {
                                Text(word.definition)
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 12))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .italic()
                                    .debugOutline()
                            }
                        }
                }
            }
        }
        .onChange(of: card.card) { _, _ in
            definedWords.removeAll()
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
