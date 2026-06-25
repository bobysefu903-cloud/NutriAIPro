// MARK: - iOS26Extensions.swift
// NutriAI Pro — Extensii și adaptări pentru iOS 26 Liquid Glass
// Specifice pentru iPhone 15 Pro Max (iOS 26)

import SwiftUI

// MARK: - GlassEffect Helpers (iOS 26)
// Wrappers convenienți pentru noile API-uri Liquid Glass

@available(iOS 26, *)
extension View {

    /// Aplică Liquid Glass standard pe iOS 26
    func liquidGlass(cornerRadius: CGFloat = 20) -> some View {
        self.background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .glassEffect()
        }
    }

    /// Aplică Liquid Glass colorat (tinted)
    func liquidGlassTinted(_ culoare: Color, cornerRadius: CGFloat = 20) -> some View {
        self.background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .glassEffect(.regular.tinted(culoare))
        }
    }

    /// Liquid Glass pentru capsule (butoane pill)
    func liquidGlassCapsule() -> some View {
        self.background {
            Capsule()
                .glassEffect()
        }
    }

    /// Liquid Glass pentru cercuri (iconițe, avatare)
    func liquidGlassCircle() -> some View {
        self.background {
            Circle()
                .glassEffect()
        }
    }
}

// MARK: - Dynamic Island Awareness (iPhone 15 Pro Max)
/// Padding adaptat pentru Dynamic Island pe iPhone 15 Pro Max
struct DynamicIslandPadding: ViewModifier {
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: 0)
            }
    }
}

// MARK: - iOS 26 Navigation Bar Styling
/// Configurare NavigationStack adaptată pentru iOS 26 translucent nav bar
struct iOS26NavigationStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                // Pe iOS 26, NavigationStack adoptă automat Liquid Glass
                // Forțăm tema dark pentru consistență
                .preferredColorScheme(.dark)
        } else {
            content
                .preferredColorScheme(.dark)
                .onAppear {
                    // Legacy UIKit appearance pentru iOS 17-25
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.backgroundColor = UIColor(white: 0.05, alpha: 0.9)
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
        }
    }
}

// MARK: - Liquid Glass Button Style (iOS 26)
@available(iOS 26, *)
struct LiquidGlassButtonStyle: ButtonStyle {
    var culori: [Color]
    var cornerRadius: CGFloat

    init(culori: [Color] = [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
         cornerRadius: CGFloat = 16) {
        self.culori = culori
        self.cornerRadius = cornerRadius
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .glassEffect(.regular.tinted(culori.first ?? .purple))
            }
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
    }
}

// MARK: - GlassEffectContainer Wrapper
/// Grupează multiple elemente Liquid Glass pentru blend/morph corect
@available(iOS 26, *)
struct NutriGlassGroup<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GlassEffectContainer {
            content
        }
    }
}

// MARK: - Color Extension (păstrat din implementarea inițială)
extension Color {
    /// Inițializare din hex string (ex: "#818CF8")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - CalculatorNutritie Shim
/// Funcție ajutătoare procentaj (dacă nu e definită în NutritionCalculator)
enum CalculatorNutritie {
    static func procentajProgres(consumat: Double, tinta: Double) -> Double {
        guard tinta > 0 else { return 0 }
        return min(consumat / tinta, 1.0)
    }
}

// MARK: - TabAICoach Enum
enum TabAICoach: String, CaseIterable {
    case nutritie    = "Nutriție"
    case antrenament = "Antrenament"
    case chat        = "Chat"
    case sfaturi     = "Sfaturi"

    var icon: String {
        switch self {
        case .nutritie:    return "fork.knife.circle.fill"
        case .antrenament: return "dumbbell.fill"
        case .chat:        return "message.fill"
        case .sfaturi:     return "lightbulb.fill"
        }
    }
}
