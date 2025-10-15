import SwiftUI

struct CardboxView: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(quiz.counts.enumerated().dropFirst()), id: \.0) { index, count in
                if count > 0 {
                    HStack {
                        Text("\(index):")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                        Text("\(count)")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }
                }
            }
        }
        .debugOutline()
    }
}
