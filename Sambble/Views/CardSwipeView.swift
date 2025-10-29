import SwiftUI

struct CardSwipeView: View {
    let quiz: Quiz
    @Binding var index: Int
    @State var showCorrectFlash: Bool = false
    @EnvironmentObject var settings: SettingsStore
    var flashColor: Color {
        switch index {
        case 0: return settings.themeColor
        case 2: return Color(red: 1.0, green: 0.5, blue: 0.5)
        default: return .clear
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $index) {
                CardView(card: quiz.nextCard).tag(0)
                CardView(card: quiz.currentCard).tag(1)
                CardView(card: quiz.nextCard).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .disabled(quiz.currentCard.checked == .UNCHECKED || index != 1)
            .debugOutline()
            .onChange(of: index) { _, newIndex in
                quiz.currentCard.correct = CorrectState(rawValue: newIndex)!
                if newIndex != 1 {
                    withAnimation(.easeIn(duration: 0.1)) {
                        showCorrectFlash = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showCorrectFlash = false
                        }
                    }
                }
            }

            // Flash overlay around the edges
            if showCorrectFlash {
                RoundedRectangle(cornerRadius: 50)
                    .stroke(flashColor, lineWidth: 15)
//                    .padding(10)
                    .shadow(color: flashColor, radius: 50)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .opacity(0.5)
                    .animation(.easeInOut(duration: 0.3), value: showCorrectFlash)
                    .allowsHitTesting(false)
            }
        }
    }
}
