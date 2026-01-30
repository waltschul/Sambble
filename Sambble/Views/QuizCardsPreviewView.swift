import SwiftUI

struct QuizCardsPreviewView: View {
    let quiz: Quiz?
    let quizID: QuizID?
    @EnvironmentObject var settings: SettingsStore

    private func cardsInBox(_ boxIndex: Int) -> [Card] {
        guard let quiz else { return [] }
        var cards = quiz.cardboxes[boxIndex]
        if quiz.currentCard.newBox == boxIndex {
            cards.append(quiz.currentCard.card)
        }
        if quiz.nextCard.newBox == boxIndex {
            cards.append(quiz.nextCard.card)
        }
        return cards
    }

    var body: some View {
        Group {
            if let quiz {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(quiz.cardboxes.indices), id: \.self) { boxIndex in
                            let cards = cardsInBox(boxIndex)
                            if !cards.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .center, spacing: 8) {
                                        Text("Box \(boxIndex)")
                                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                            .foregroundColor(settings.themeColor)
                                        Spacer(minLength: 0)
                                        if boxIndex == 0, let quizID {
                                            Text("Size: \(quiz.cardboxZeroSize)")
                                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                                .foregroundColor(.gray)
                                            Slider(
                                                value: Binding(
                                                    get: { Double(quiz.cardboxZeroSize) },
                                                    set: { newVal in
                                                        quiz.cardboxZeroSize = Int(newVal)
                                                        persistQuiz(id: quizID, quiz: quiz)
                                                    }
                                                ),
                                                in: 5...100,
                                                step: 1
                                            )
                                            .frame(maxWidth: 120)
                                        }
                                    }
                                    ForEach(cards, id: \.id) { card in
                                        CardPreviewRow(card: card, showAnagrams: boxIndex != 0)
                                            .environmentObject(settings)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 220)
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Text("No quiz loaded")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
        }
    }
}

private struct CardPreviewRow: View {
    let card: Card
    let showAnagrams: Bool
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(card.id)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            if showAnagrams {
                Text(card.words.map(\.id).joined(separator: " "))
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(.gray)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }
}
