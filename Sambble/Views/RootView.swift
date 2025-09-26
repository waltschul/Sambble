import SwiftUI

struct RootView_Preview: PreviewProvider {
    static let previewQuiz: Quiz = {
        Constants.DEBUG = true
        clearDocuments()
        return loadQuiz(length: 7)
    }()
    
    static var previews: some View {
        RootView(quiz: previewQuiz)
    }
}

struct RootView: View {
    let quiz: Quiz
    @State private var showSplash = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if !showSplash {
                QuizView(quiz: quiz)
            }
            
            if showSplash {
                Image("Sam")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.6)
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
