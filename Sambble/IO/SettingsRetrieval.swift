//import Foundation
//
//@Observable
//class QuizSelectionViewModel: ObservableObject {
//    @Published var quizCache = QuizCache()
//    @Published var selectedQuiz: QuizID
//
//    init() {
//        let quizCache = QuizCache()
//        self.quizCache = quizCache
//
//        if let savedQuiz = UserDefaults.standard.string(forKey: "selectedQuiz"),
//           let quizID = QuizID(rawValue: savedQuiz) {
//            self.selectedQuiz = quizID
//        } else {
//            self.selectedQuiz = quizCache.quizzes.first!
//        }
//    }
//
//    func saveSelection() {
//        UserDefaults.standard.set(selectedQuiz.rawValue, forKey: "selectedQuiz")
//    }
//}
