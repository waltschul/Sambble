import Foundation

func persistQuiz(id: QuizID, quiz: Quiz) {
    if (Constants.DEBUG) { return }
    do {
        let url = try quizFileURL(id: id)
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
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("[DEBUG] Quiz file doesn't exist for \(id.rawValue)")
            return nil
        }
        let data = try Data(contentsOf: url)
        let cardLoader = CardLoader(quizParameters: id.parameters)
        let decoder = JSONDecoder()
        decoder.userInfo[.cardLoader] = cardLoader
        let quiz = try decoder.decode(Quiz.self, from: data)
        print("[DEBUG] Quiz loaded from \(url)")
        return quiz
    } catch {
        print("[DEBUG] ⚠️ DECODE FAILURE for quiz \(id.rawValue) - file exists but couldn't decode. File preserved.")
        print("[DEBUG] Error details: \(error.localizedDescription)")
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("[DEBUG] Missing key: \(key.stringValue) at \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("[DEBUG] Type mismatch for \(type) at \(context.codingPath)")
            case .valueNotFound(let type, let context):
                print("[DEBUG] Value not found for \(type) at \(context.codingPath)")
            case .dataCorrupted(let context):
                print("[DEBUG] Data corrupted at \(context.codingPath): \(context.debugDescription)")
            @unknown default:
                print("[DEBUG] Unknown decoding error")
            }
        }
        return nil
    }
}

func quizFileURL(id: QuizID) throws -> URL {
    let fileName = "\(id).json"
    let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Sambble")
    return containerURL!.appendingPathComponent(fileName)
}

func quizFileExists(id: QuizID) -> Bool {
    if Constants.DEBUG { return false }
    guard let url = try? quizFileURL(id: id) else { return false }
    return FileManager.default.fileExists(atPath: url.path)
}

func printQuizToDebug(id: QuizID, quiz: Quiz) {
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(quiz)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("\n========== QUIZ: \(id.rawValue) ==========")
            print(jsonString)
            print("========== END QUIZ: \(id.rawValue) ==========\n")
        }
    } catch {
        print("[DEBUG] Failed to encode quiz \(id.rawValue): \(error)")
    }
}
