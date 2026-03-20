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
    private var wordFontSize: CGFloat { isLandscape ? 24 : 17 }
    private var hookFontSize: CGFloat { isLandscape ? 14 : 10 }
    private var definitionFontSize: CGFloat { isLandscape ? 16 : 12 }

    var body: some View {
        VStack(spacing: 0) {
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
                    Group {
                        if isLandscape && card.card.words.count > 5 {
                            // Two columns for landscape with many anagrams
                            let leftWords = card.card.words.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
                            let rightWords = card.card.words.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element }
                            let hookWidth = Self.maxHookWidth(words: card.card.words, hookFontSize: hookFontSize)
                            HStack {
                                Spacer()
                                HStack(alignment: .top, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(leftWords) { word in
                                            wordRow(word: word, hookWidth: hookWidth)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(rightWords) { word in
                                            wordRow(word: word, hookWidth: hookWidth)
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                        } else {
                            // Single column (portrait or <= 5 anagrams)
                            VStack(alignment: .center, spacing: 4) {
                                let hookWidth = Self.maxHookWidth(words: card.card.words, hookFontSize: hookFontSize)
                                ForEach(card.card.words) { word in
                                    wordRow(word: word, hookWidth: hookWidth)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 8)
                        }
                    }
                } else {
                    Color.clear
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: card.card) { _, _ in
            definedWords.removeAll()
        }
        .debugOutline()
    }
}

extension CardView {
    static func maxHookWidth(words: [Word], hookFontSize: CGFloat) -> CGFloat {
        let maxLen = words.flatMap { [$0.frontHooks.count, $0.backHooks.count] }.max() ?? 0
        let scale = hookFontSize * 0.7  // generous so hook text doesn’t wrap
        return max(24, CGFloat(maxLen) * scale)
    }

    func hookText(text: String, alignment: Alignment, size: CGFloat, width: CGFloat) -> some View {
        Text(text)
            .foregroundColor(.gray)
            .font(.system(size: size))
            .lineLimit(1)
            .frame(width: width, alignment: alignment)
    }
    
    func wordRow(word: Word, hookWidth: CGFloat = 100) -> some View {
        VStack(alignment: .center) {
            HStack(alignment: .firstTextBaseline) {
                hookText(text: word.frontHooks, alignment: .trailing, size: hookFontSize, width: hookWidth)
                Text(word.id)
                    .font(.system(size: wordFontSize)) 
                    .foregroundColor(color)
                    .debugOutline()
                hookText(text: word.backHooks, alignment: .leading, size: hookFontSize, width: hookWidth)
            }
            .fixedSize(horizontal: true, vertical: false)
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
