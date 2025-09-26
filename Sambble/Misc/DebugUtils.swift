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
