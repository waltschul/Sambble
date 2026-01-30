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

    /// Adds long-press share only when condition is true; otherwise no-op.
    func shareOnLongPress(when condition: Bool, items: [Any]) -> some View {
        modifier(ConditionalLongPressShareModifier(condition: condition, items: items))
    }
}

struct LongPressShareModifier: ViewModifier {
    let items: [Any]
    @State private var showShareSheet = false

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .highPriorityGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        showShareSheet = true
                    }
            )
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: items)
            }
    }
}

struct ConditionalLongPressShareModifier: ViewModifier {
    let condition: Bool
    let items: [Any]
    @State private var showShareSheet = false

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .highPriorityGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        if condition, !items.isEmpty {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            showShareSheet = true
                        }
                    }
            )
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: items)
            }
    }
}
