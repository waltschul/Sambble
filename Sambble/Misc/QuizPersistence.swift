import Foundation

func quizFileURL(length: Int) -> URL {
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documents.appendingPathComponent("quiz\(length).json")
}

func saveQuiz(quiz: Quiz) {
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
    let url = quizFileURL(length: length)
    do {
        let data = try Data(contentsOf: url)
        let quiz = try JSONDecoder().decode(Quiz.self, from: data)
        print("[DEBUG] Quiz loaded successfully")
        return quiz
    } catch {
        print("[DEBUG] No quiz at \(url)")
        return Quiz(wordLength: length)
    }
}

func debugPrintJSON<T: Encodable>(_ value: T) {
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(value)
        if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        } else {
            print("Could not convert JSON data to string")
        }
    } catch {
        print("Failed to encode JSON: \(error)")
    }
}
