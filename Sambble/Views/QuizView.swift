import SwiftUI

struct QuizView: View {
    @StateObject private var vm: QuizViewModel
    @EnvironmentObject var settings: SettingsStore
    @FocusState private var isFocused: Bool

    init(id: QuizID, quiz: Quiz) {
        _vm = StateObject(wrappedValue: QuizViewModel(id: id, quiz: quiz))
    }

    var body: some View {
        CardSwipeView(quiz: vm.quiz, index: $vm.index)
            .background(Color.clear.contentShape(Rectangle()).ignoresSafeArea())
            .onTapGesture {
                vm.handleCardAnswer()
            }
            .focusable()
            .focused($isFocused)
            .onAppear { isFocused = true }
            .onKeyPress(.leftArrow) {
                if vm.quiz.currentCard.checked == .UNCHECKED {
                    vm.handleCardAnswer()
                } else {
                    vm.index = 2
                    vm.handleCardAnswer()
                }
                return .handled
            }
            .onKeyPress(.rightArrow) {
                if vm.quiz.currentCard.checked == .UNCHECKED {
                    vm.handleCardAnswer()
                } else {
                    vm.index = 0
                    vm.handleCardAnswer()
                }
                return .handled
            }
            .onKeyPress(.space) {
                vm.handleCardAnswer()
                return .handled
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
