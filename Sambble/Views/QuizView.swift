import SwiftUI

struct QuizView: View {
    @StateObject private var vm: QuizViewModel
    @EnvironmentObject var settings: SettingsStore

    init(id: QuizID, quiz: Quiz) {
        _vm = StateObject(wrappedValue: QuizViewModel(id: id, quiz: quiz))
    }

    var body: some View {
        CardSwipeView(quiz: vm.quiz, index: $vm.index)
            .background(Color.clear.contentShape(Rectangle()).ignoresSafeArea())
            .onTapGesture {
                vm.handleCardAnswer()
            }
            .onChange(of: vm.index) { _, newIndex in
                vm.quiz.index = newIndex
            }
            .onChange(of: settings.carMode) { _, newValue in
                if newValue {
                    vm.registerMediaCommands()
                }
            }
    }
}
