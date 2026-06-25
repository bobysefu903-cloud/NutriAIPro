// MARK: - PremiumButton.swift
// NutriAI Pro — Butoane premium refolosibile
// Platformă: iOS 17+ | SwiftUI

import SwiftUI

// MARK: - Buton Premium Principal
struct PremiumButton: View {
    let titlu: String
    let icon: String?
    let culori: [Color]
    var actiune: () -> Void
    var dimensiuneFont: Font
    var estePlin: Bool
    var isDisabled: Bool

    @State private var estaApasat: Bool = false

    init(
        titlu: String,
        icon: String? = nil,
        culori: [Color] = [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
        dimensiuneFont: Font = .headline,
        esteOlin: Bool = true,
        isDisabled: Bool = false,
        actiune: @escaping () -> Void
    ) {
        self.titlu = titlu
        self.icon = icon
        self.culori = culori
        self.dimensiuneFont = dimensiuneFont
        self.esteOlin = esteOlin
        self.isDisabled = isDisabled
        self.actiune = actiune
        self.esteOlin = esteOlin
        self.esteOlin = true
    }

    // Hack: rename param to avoid collision
    var esteOlin: Bool = true

    var body: some View {
        Button {
            guard !isDisabled else { return }
            withAnimation(.spring(duration: 0.2)) { estaApasat = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(duration: 0.2)) { estaApasat = false }
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            actiune()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(dimensiuneFont)
                }
                Text(titlu)
                    .font(dimensiuneFont)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                if esteOlin {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: isDisabled ? [Color.gray.opacity(0.4)] : culori,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: (isDisabled ? Color.clear : culori.first?.opacity(0.5)) ?? .clear,
                            radius: estaApasat ? 6 : 14,
                            x: 0,
                            y: estaApasat ? 2 : 6
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                }
            }
            .scaleEffect(estaApasat ? 0.97 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled)
        .animation(.spring(duration: 0.2), value: estaApasat)
    }
}

// MARK: - Buton Circular (Icon-Only)
struct CircularButton: View {
    let icon: String
    let culori: [Color]
    var dimensiune: CGFloat = 52
    var actiune: () -> Void

    @State private var estaApasat = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.15)) { estaApasat = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(duration: 0.2)) { estaApasat = false }
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            actiune()
        } label: {
            Image(systemName: icon)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: dimensiune, height: dimensiune)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: culori.first?.opacity(0.6) ?? .clear, radius: 8, x: 0, y: 4)
                }
                .scaleEffect(estaApasat ? 0.9 : 1.0)
        }
        .animation(.spring(duration: 0.2), value: estaApasat)
    }
}

// MARK: - Buton Capsulă Mică
struct PillButton: View {
    let titlu: String
    let icon: String?
    let culori: [Color]
    var esteSelectat: Bool
    var actiune: () -> Void

    init(
        titlu: String,
        icon: String? = nil,
        culori: [Color] = [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
        esteSelectat: Bool = false,
        actiune: @escaping () -> Void
    ) {
        self.titlu = titlu
        self.icon = icon
        self.culori = culori
        self.esteSelectat = esteSelectat
        self.actiune = actiune
    }

    var body: some View {
        Button(action: actiune) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(titlu)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(esteSelectat ? .white : .secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(
                        esteSelectat
                        ? LinearGradient(colors: culori, startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay {
                        if !esteSelectat {
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.3), value: esteSelectat)
    }
}

// MARK: - Buton Adaugă (+)
struct AddButton: View {
    var culori: [Color] = [Color(hex: "#34D399"), Color(hex: "#059669")]
    var actiune: () -> Void

    var body: some View {
        Button(action: actiune) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: culori.first?.opacity(0.5) ?? .clear, radius: 8, x: 0, y: 3)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Extensions
extension View {
    /// Efect de apăsare cu scaleEffect și haptic feedback
    func pressEffect(scara: CGFloat = 0.96) -> some View {
        self.buttonStyle(PressEffectStyle(scara: scara))
    }
}

struct PressEffectStyle: ButtonStyle {
    var scara: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scara : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, apasatNou in
                if apasatNou {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}
