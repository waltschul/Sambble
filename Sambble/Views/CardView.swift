import SwiftUI

struct CardView: View {
    let card: ViewedCard
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    var color: Color {
        card.checked == .EASY ? settings.themeColor : .white
    }
    @State var definedWords: Set<String> = []
    private var isLandscape: Bool { verticalSizeClass == .compact }
    private var cardIdFontSize: CGFloat { isLandscape ? 80 : 48 }
    private var wordFontSize: CGFloat { isLandscape ? 22 : 17 }
    private var hookFontSize: CGFloat { isLandscape ? 14 : 10 }
    private var definitionFontSize: CGFloat { isLandscape ? 16 : 12 }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: isLandscape ? 100 : 300)
            HStack {
                Spacer(minLength: 0)
                ZStack(alignment: .topTrailing) {
                    Text(card.card.id)
                        .font(.system(size: cardIdFontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                    if card.card.status == .treat {
                        Image(systemName: "birthday.cake")
                            .font(.system(size: 16))
                            .foregroundColor(settings.themeColor)
                            .padding(.top, 4)
                            .offset(x: 24)
                    } else if card.card.status == .new {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundColor(settings.themeColor)
                            .padding(.top, 4)
                            .offset(x: 24)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .shareOnLongPress(when: card.card.status == .treat, items: ["My Sambble treat is \(card.card.id), yum! 😋"])
            Spacer().frame(height: 10)
            Group {
                if card.checked != .UNCHECKED {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(card.card.words) { word in
                                VStack(alignment: .center) {
                                    HStack(alignment: .bottom) {
                                        hookText(text: word.frontHooks, alignment: .trailing, size: hookFontSize)
                                        Text(word.id)
                                            .font(.system(size: wordFontSize, design: .monospaced))
                                            .foregroundColor(color)
                                            .debugOutline()
                                        hookText(text: word.backHooks, alignment: .leading, size: hookFontSize)
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
                                            .font(.system(size: definitionFontSize))
                                            .multilineTextAlignment(.center)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .italic()
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .debugOutline()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                } else {
                    Color.clear
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: card.card) { _, _ in
            definedWords.removeAll()
        }
        .debugOutline()
    }
}

extension CardView {
    func hookText(text: String, alignment: Alignment, size: CGFloat = 10) -> some View {
        Text(text)
            .foregroundColor(.gray)
            .frame(width: 100, alignment: alignment)
            .font(.system(size: size))
    }
}
