import SwiftUI

extension View {
    func shimmer() -> some View {
        self
            .modifier(ShimmerEffect())
    }
}

private struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.6), Color.clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}
