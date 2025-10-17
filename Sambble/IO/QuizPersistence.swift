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
        var data = try Data(contentsOf: url)

        var json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        json.removeValue(forKey: "name")
        
        if var cardboxes = json["cardboxes"] as? [[Any]] {
            for (boxIndex, box) in cardboxes.enumerated() {
                var newBox: [Any] = []
                for (cardIndex, cardItem) in box.enumerated() {
                    if var cardDict = cardItem as? [String: Any], let cardID = cardDict["id"] as? String {
                        // Replace the card dictionary with just its ID (or do any migration)
                        newBox.append(cardID)
                    } else {
                        // Keep original item if it's not a dictionary
                        newBox.append(cardItem)
                    }
                }
                // Replace the old box with the updated one
                cardboxes[boxIndex] = newBox
            }
            // Assign back to the root JSON
            json["cardboxes"] = cardboxes
        }
        
        if var currentCard = json["currentCard"] as? [String: Any],
           let card = currentCard["card"] as? [String: Any],
           let id = card["id"] {
            
            currentCard["card"] = id  // replace dictionary with just the ID
            json["currentCard"] = currentCard  // assign back to the root JSON
        }

        if var nextCard = json["nextCard"] as? [String: Any],
           let card = nextCard["card"] as? [String: Any],
           let id = card["id"] {
            
            nextCard["card"] = id
            json["nextCard"] = nextCard
        }
        
        json["quizID"] = "Sevens"
        json.removeValue(forKey: "cardLoader")

        do {
            data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        } catch {
            print("Failed to serialize JSON: \(error)")
        }
        
//        exit(0)

        let cardLoader = CardLoader(quizParameters: id.parameters)
        let decoder = JSONDecoder()
        decoder.userInfo[.cardLoader] = cardLoader
        let quiz = try decoder.decode(Quiz.self, from: data)
        print("[DEBUG] Quiz loaded successfully from \(url)")
        return quiz
    } catch {
        print("[DEBUG] Couldn't load quiz: \(error)")
        return nil
    }
}

func quizFileURL(id: QuizID) throws -> URL {
    let fileName = "\(id.rawValue)-\(Constants.VERSION).json" //TODO
    let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Sambble")
    return containerURL!.appendingPathComponent(fileName)
}
