import Foundation

func quizFileURL(length: Int) throws -> URL {
    let fileName = "quiz\(length)-\(Constants.VERSION).json"
    let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Sambble")
    return containerURL!.appendingPathComponent(fileName)
}

func saveQuiz(quiz: Quiz) {
    if (Constants.DEBUG) { return }
    do {
        let url = try quizFileURL(length: quiz.wordLength)
        let data = try JSONEncoder().encode(quiz)
        try data.write(to: url)
    } catch {
        print("[DEBUG] Failed to save quiz: \(error)")
    }
}

func loadQuiz(length: Int) -> Quiz? {
    if (Constants.DEBUG) {
        return nil
//        return Quiz(wordLength: length, index: 0)
    }

    do {
        let url = try quizFileURL(length: length)
        let data = try Data(contentsOf: url)
        let quiz = try JSONDecoder().decode(Quiz.self, from: data)
        print("[DEBUG] Quiz loaded successfully from \(url)")
        return quiz
    } catch {
        print("[DEBUG] Couldn't load quiz: \(error)")
        return nil
    }
}
