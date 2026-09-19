import Foundation
import SwiftUI

struct MicroscopeLoadingMark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    private let fieldSize = HealthTheme.microscopeSize + HealthTheme.Space.regular * 2
    private let dotColors = [HealthTheme.brandBlue, HealthTheme.brandCyan, HealthTheme.brandGreen]

    var body: some View {
        Group {
            if reduceMotion || scenePhase != .active {
                mark(progress: nil)
            } else {
                // The timeline ends when the loading view leaves the screen.
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                    let progress = context.date.timeIntervalSinceReferenceDate
                        .truncatingRemainder(dividingBy: 1.8) / 1.8
                    mark(progress: progress)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func mark(progress: Double?) -> some View {
        VStack(spacing: HealthTheme.Space.regular) {
            ZStack {
                Circle().fill(.white)

                Image("Microscope")
                    .resizable()
                    .scaledToFit()
                    .frame(width: HealthTheme.microscopeSize, height: HealthTheme.microscopeSize)

                if let progress {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [.clear, HealthTheme.brandCyan, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(height: 3)
                        .offset(y: CGFloat(progress - 0.5) * HealthTheme.microscopeSize)
                        .opacity(sin(progress * .pi))
                }
            }
            .frame(width: fieldSize, height: fieldSize)
            .clipShape(Circle())
            .overlay {
                Circle().strokeBorder(HealthTheme.brandCyan.opacity(0.3), lineWidth: 3)
            }

            HStack(spacing: HealthTheme.Space.regular) {
                ForEach(dotColors.indices, id: \.self) { index in
                    Circle()
                        .fill(dotColors[index])
                        .frame(width: 10, height: 10)
                        .opacity(dotOpacity(index: index, progress: progress))
                }
            }
        }
    }

    private func dotOpacity(index: Int, progress: Double?) -> Double {
        guard let progress else { return 1 }
        let wave = (cos((progress - Double(index) / 3) * 2 * .pi) + 1) / 2
        return 0.3 + 0.7 * wave
    }
}
