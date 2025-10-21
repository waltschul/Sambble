import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension View {
    /// Adds a long-press gesture to show a share sheet with the provided text or items.
    func shareOnLongPress(items: [Any]) -> some View {
        modifier(LongPressShareModifier(items: items))
    }
}

struct LongPressShareModifier: ViewModifier {
    let items: [Any]
    @State private var showShareSheet = false

    func body(content: Content) -> some View {
        content
            .onLongPressGesture {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showShareSheet = true
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: items)
            }
    }
}
