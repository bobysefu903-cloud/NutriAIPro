// MARK: - WelcomeView.swift
// NutriAI Pro — Ecranul de bun venit (Pagina 0)
// Platformă: iOS 17+

import SwiftUI

struct WelcomeView: View {

    @Binding var vm: OnboardingViewModel

    // MARK: - Stări Animație
    @State private var logoApare: Bool = false
    @State private var titluApare: Bool = false
    @State private var featuresApare: Bool = false
    @State private var butonApare: Bool = false
    @State private var logoRotatie: Double = 0
    @State private var logoScara: Double = 0.5

    // MARK: - Features
    let features: [(icon: String, titlu: String, descriere: String, culori: [Color])] = [
        ("brain.head.profile.fill", "AI Coach Personal", "Plan de nutriție și antrenament generat cu inteligență artificială",
         [Color(hex: "#818CF8"), Color(hex: "#4F46E5")]),
        ("chart.pie.fill", "Tracking Precis", "Urmărești caloriile, macronutrienții și hidratarea în timp real",
         [Color(hex: "#34D399"), Color(hex: "#059669")]),
        ("heart.fill", "Sincronizare HealthKit", "Calorii arse și pași sincronizați automat din Apple Health",
         [Color(hex: "#F87171"), Color(hex: "#B91C1C")]),
        ("fork.knife.circle.fill", "Rețete Personalizate", "Construiește și salvează rețetele tale cu un singur tap",
         [Color(hex: "#F59E0B"), Color(hex: "#D97706")])
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {

                // MARK: Hero Section
                VStack(spacing: 24) {
                    Spacer(minLength: 40)

                    // Logo Animat
                    ZStack {
                        // Halo exterior
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#818CF8").opacity(Double(3 - i) * 0.1),
                                            Color(hex: "#4F46E5").opacity(0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                                .frame(
                                    width: CGFloat(100 + i * 30),
                                    height: CGFloat(100 + i * 30)
                                )
                                .scaleEffect(logoApare ? 1 : 0.3)
                                .opacity(logoApare ? 1 : 0)
                                .animation(
                                    .spring(duration: 0.8, bounce: 0.3)
                                    .delay(0.1 + Double(i) * 0.08),
                                    value: logoApare
                                )
                        }

                        // Icon container
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5"), Color(hex: "#7C3AED")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)
                                .shadow(color: Color(hex: "#4F46E5").opacity(0.7), radius: 24, x: 0, y: 12)

                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                        }
                        .scaleEffect(logoApare ? logoScara : 0.3)
                        .rotationEffect(.degrees(logoRotatie))
                        .animation(.spring(duration: 0.8, bounce: 0.4), value: logoApare)
                    }
                    .padding(.bottom, 8)

                    // MARK: Titlu & Subtitle
                    VStack(spacing: 12) {
                        Group {
                            Text("Nutri")
                                .foregroundStyle(.white) +
                            Text("AI Pro")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#818CF8"), Color(hex: "#A78BFA")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .opacity(titluApare ? 1 : 0)
                        .offset(y: titluApare ? 0 : 20)
                        .animation(.spring(duration: 0.6, bounce: 0.3).delay(0.3), value: titluApare)

                        Text("Coachul tău de nutriție și fitness\npowered by Inteligență Artificială")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .opacity(titluApare ? 1 : 0)
                            .offset(y: titluApare ? 0 : 15)
                            .animation(.spring(duration: 0.6).delay(0.45), value: titluApare)
                    }

                    Spacer(minLength: 10)
                }
                .frame(minHeight: 280)

                // MARK: Features Grid
                VStack(spacing: 14) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        FeatureRow(
                            icon: feature.icon,
                            titlu: feature.titlu,
                            descriere: feature.descriere,
                            culori: feature.culori
                        )
                        .opacity(featuresApare ? 1 : 0)
                        .offset(x: featuresApare ? 0 : -30)
                        .animation(
                            .spring(duration: 0.5, bounce: 0.2)
                            .delay(0.5 + Double(index) * 0.1),
                            value: featuresApare
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)

                // MARK: Buton Start
                VStack(spacing: 12) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        vm.mergeInainte()
                    } label: {
                        HStack(spacing: 10) {
                            Text("Hai să Începem!")
                                .font(.headline)
                                .fontWeight(.bold)

                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5"), Color(hex: "#7C3AED")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(hex: "#4F46E5").opacity(0.6), radius: 20, x: 0, y: 8)
                        }
                    }
                    .pressEffect()
                    .opacity(butonApare ? 1 : 0)
                    .offset(y: butonApare ? 0 : 20)
                    .animation(.spring(duration: 0.5).delay(1.0), value: butonApare)

                    Text("🔒 Datele tale rămân pe dispozitiv. Fără cloud, fără abonament.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .opacity(butonApare ? 1 : 0)
                        .animation(.easeIn(duration: 0.4).delay(1.2), value: butonApare)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            logoApare = true
            logoScara = 1.0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { titluApare = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { featuresApare = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { butonApare = true }

            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                logoRotatie = 360
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let titlu: String
    let descriere: String
    let culori: [Color]

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: culori.first?.opacity(0.4) ?? .clear, radius: 8, x: 0, y: 4)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(titlu)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(descriere)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}
