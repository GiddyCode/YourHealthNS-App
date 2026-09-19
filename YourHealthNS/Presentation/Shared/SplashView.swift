import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    var body: some View {
        Image("NSWordmark")
            .resizable()
            .scaledToFit()
            .frame(width: HealthTheme.wordmarkWidth, height: 80)
            .overlay(alignment: .bottom) {
                if !reduceMotion {
                    Capsule()
                        .fill(LinearGradient(colors: [HealthTheme.brandCyan, HealthTheme.brandGreen], startPoint: .leading, endPoint: .trailing))
                        .frame(width: HealthTheme.microscopeSize, height: 3)
                        .scaleEffect(x: revealed ? 1 : 0, anchor: .leading)
                        .offset(y: HealthTheme.Space.large)
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                GeometryReader { geometry in
                    Image("WaveBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
                .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("YourHealthNS")
            .task {
                guard !reduceMotion else { return }
                withAnimation(.easeOut(duration: 0.6)) {
                    revealed = true
                }
            }
    }
}
