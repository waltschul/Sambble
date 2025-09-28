import SwiftUI

struct DebugOutline: ViewModifier {
    func body(content: Content) -> some View {
        content
            .border(Constants.DEBUG ? Color.red : Color.clear)
    }
}

extension View {
    func debugOutline() -> some View {
        self.modifier(DebugOutline())
    }
}

func clearDocuments() {
    let fm = FileManager.default
    let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first!

    do {
        let files = try fm.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil)
        for file in files {
            try fm.removeItem(at: file)
        }
        print("Cleared Documents directory")
    } catch {
        print("Failed to clear documents: \(error)")
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

