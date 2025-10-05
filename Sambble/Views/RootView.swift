import SwiftUI

#Preview {
    RootView()
}

//TODO deduplicate current cards
struct RootView: View {
    @State private var showSplash = Constants.DEBUG ? false : true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showSplash {
                Image("Sam")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.6)
            } else {
                QuizInitializeView(wordLength: 7)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation() {
                    showSplash = false
                }
            }
        }
    }
}
