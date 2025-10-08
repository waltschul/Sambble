import Foundation

func quizFileURL(id: String) throws -> URL {
    let fileName = "\(id)-\(Constants.VERSION).json"
    let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Sambble")
    return containerURL!.appendingPathComponent(fileName)
}

func saveQuiz(quiz: Quiz) {
    if (Constants.DEBUG) { return }
    do {
        let url = try quizFileURL(id: quiz.name)
        let data = try JSONEncoder().encode(quiz)
        try data.write(to: url)
    } catch {
        print("[DEBUG] Failed to save quiz: \(error)")
    }
}

func loadQuiz(id: String) -> Quiz? {
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
