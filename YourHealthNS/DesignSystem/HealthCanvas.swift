import SwiftUI

struct HealthCanvas: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                HealthTheme.canvas

                if colorScheme == .light && geometry.size.width < geometry.size.height * 0.7 {
                    Image("WaveBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                        .clipped()
                } else {
                    // A portrait bitmap would crop its waves excessively on wide layouts.
                    DecorativeWaves()
                        .frame(height: min(geometry.size.height * 0.24, 220))
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

private struct DecorativeWaves: View {
    var body: some View {
        ZStack {
            WaveShape(isRising: true)
                .fill(HealthTheme.brandGreen.opacity(0.18))
            WaveShape(isRising: false)
                .fill(HealthTheme.brandCyan.opacity(0.24))
        }
    }
}

private struct WaveShape: Shape {
    let isRising: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.height * (isRising ? 0.6 : 0.3)))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.height * (isRising ? 0.12 : 0.6)),
            control1: CGPoint(x: rect.width * 0.38, y: rect.height * 1.1),
            control2: CGPoint(x: rect.width * 0.64, y: rect.height * (isRising ? -0.15 : 0.1))
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
