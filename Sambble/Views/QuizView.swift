import SwiftUI

struct QuizView: View {
    @StateObject private var vm: QuizViewModel
    @EnvironmentObject var settings: SettingsStore
    @FocusState private var isFocused: Bool

    init(id: QuizID, quiz: Quiz) {
        _vm = StateObject(wrappedValue: QuizViewModel(id: id, quiz: quiz))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            CardSwipeView(quiz: vm.quiz, index: $vm.index)
                .background(Color.clear.contentShape(Rectangle()).ignoresSafeArea())
                .onTapGesture {
                    vm.handle(.tap)
                }
                .focusable()
                .focused($isFocused)
                .onAppear { isFocused = true }
                .onKeyPress(.leftArrow) {
                    vm.handle(.arrowLeft)
                    return .handled
                }
                .onKeyPress(.rightArrow) {
                    vm.handle(.arrowRight)
                    return .handled
                }
                .onKeyPress(.space) {
                    vm.handle(.tap)
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

            #if DEBUG
            HStack(spacing: 24) {
                Button("⏮ Prev") { vm.handle(.mediaPrev) }
                    .buttonStyle(.bordered)
                Button("⏭ Next") { vm.handle(.mediaNext) }
                    .buttonStyle(.bordered)
            }
            .padding(.bottom, 24)
            #endif
        }
    }
}
