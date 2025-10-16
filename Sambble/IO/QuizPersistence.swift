import Foundation

func persistQuiz(quiz: Quiz) {
    if (Constants.DEBUG) { return }
    do {
        let url = try quizFileURL(id: quiz.quizID)
        let data = try JSONEncoder().encode(quiz)
        try data.write(to: url)
    } catch {
        print("[DEBUG] Failed to save quiz: \(error)")
    }
}

func loadQuiz(id: QuizID) -> Quiz? {
    if (Constants.DEBUG) {
        return nil
    }

    do {
        let url = try quizFileURL(id: id)
        let data = try Data(contentsOf: url)
        let quiz = try JSONDecoder().decode(Quiz.self, from: data)
        print("[DEBUG] Quiz loaded successfully from \(url)")
        return quiz
    } catch {
        print("[DEBUG] Couldn't load quiz: \(error)")
        return nil
    }
}

func quizFileURL(id: QuizID) throws -> URL {
    let fileName = "\(id)-\(Constants.VERSION).json"
    let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Sambble")
    return containerURL!.appendingPathComponent(fileName)
}
