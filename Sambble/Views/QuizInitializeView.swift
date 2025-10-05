import SwiftUI

#Preview {
    QuizInitializeView(wordLength: 7)
}

//TODO maybe should have datamodel
struct QuizInitializeView: View {
    private let wordLength: Int
    private let quizDefinition: QuizDefinition
    @State private var quiz: Quiz?
    
    init(wordLength: Int) {
        self.wordLength = wordLength
        self._quiz = State(initialValue: loadQuiz(length: wordLength))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if (quiz == nil) {
                InitializeView(cardLoader: CardLoader(wordLength: wordLength), quiz: $quiz)
            }
            else {
                QuizView(quiz: quiz!)
            }
        }
    }
}
