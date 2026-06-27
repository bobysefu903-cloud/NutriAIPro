// MARK: - GlassCard.swift
// NutriAI Pro — Card glassmorfic refolosibil
// Platformă: iOS 17+ | SwiftUI

import SwiftUI

// MARK: - Glass Card
/// Card glassmorfic cu blur, gradient și umbră — componenta UI fundamentală a aplicației
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    var padding: CGFloat
    var opacitate: Double
    var culoareTinta: Color
    var hasBorder: Bool

    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 16,
        opacitate: Double = 0.12,
        culoareTinta: Color = .white,
        hasBorder: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.opacitate = opacitate
        self.culoareTinta = culoareTinta
        self.hasBorder = hasBorder
    }

    var body: some View {
        content
            .padding(padding)
            .background {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .glassEffect()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(culoareTinta.opacity(opacitate))
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(0.6)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [culoareTinta.opacity(0.08), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .overlay {
                if hasBorder {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Gradient Card
/// Card cu gradient colorat ca fundal
struct GradientCard<Content: View>: View {
    let gradient: [Color]
    let content: Content
    var cornerRadius: CGFloat

    init(
        gradient: [Color],
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = gradient
        self.content = content()
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: gradient.first?.opacity(0.5) ?? .clear, radius: 16, x: 0, y: 8)
            }
    }
}

// MARK: - Floating Card (cu animație de levitație)
struct FloatingCard<Content: View>: View {
    let content: Content
    @State private var offset: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = -6
                }
            }
    }
}

// MARK: - Preview Card
struct PreviewMacroCard: View {
    let titlu: String
    let valoare: Double
    let unitate: String
    let culori: [Color]
    let icon: String

    var body: some View {
        GlassCard(cornerRadius: 16, padding: 14, culoareTinta: culori.first ?? .purple) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(titlu)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(valoare))\(unitate)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Shimmer Effect (pentru loading)
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: phase - 0.3),
                        .init(color: .white.opacity(0.4), location: phase),
                        .init(color: .clear, location: phase + 0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1.3
                    }
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Badge
struct Badge: View {
    let text: String
    let culori: [Color]

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: culori,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
    }
}
