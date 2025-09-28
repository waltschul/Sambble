import Foundation

func quizFileURL(length: Int) -> URL {
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documents.appendingPathComponent("quiz\(length)-\(Constants.VERSION).json")
}

func saveQuiz(quiz: Quiz) {
    if (Constants.DEBUG) { return }
    let url = quizFileURL(length: quiz.wordLength)
    do {
        let data = try JSONEncoder().encode(quiz)
        try data.write(to: url)
//        debugPrintJSON(quiz)
    } catch {
        print("[DEBUG] Failed to save quiz to \(url): \(error)")
    }
}

func loadQuiz(length: Int) -> Quiz {
    if Constants.DEBUG { return Quiz(wordLength: length) }
    
    let url = quizFileURL(length: length)
    do {
        let data = try Data(contentsOf: url)
        let quiz = try JSONDecoder().decode(Quiz.self, from: data)
        print("[DEBUG] Quiz loaded successfully from \(url)")
        return quiz
    } catch {
        print("[DEBUG] No quiz at \(url)")
        return Quiz(wordLength: length)
    }
}
