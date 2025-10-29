import SwiftUI

struct CardboxView: View {
    let quiz: Quiz
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(quiz.counts.enumerated()), id: \.0) { index, count in
                if count > 0 {
                    HStack {
                        Text("\(index):")
                            .foregroundColor(settings.themeColor)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                        Text("\(count)")
                            .foregroundColor(settings.themeColor)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }
                }
            }
        }
        .debugOutline()
    }
}
