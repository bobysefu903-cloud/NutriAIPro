// MARK: - MacroSummaryView.swift
// NutriAI Pro — Rezumatul final al macronutrienților (Pagina 4)
// Platformă: iOS 17+

import SwiftUI

struct MacroSummaryView: View {

    let vm: OnboardingViewModel
    let onFinalizare: () -> Void

    // MARK: - Animații
    @State private var ringApare: Bool = false
    @State private var rânduriApare: Bool = false
    @State private var confettiActiv: Bool = false
    @State private var scareaButon: CGFloat = 1.0

    // MARK: - Date pentru afișare
    private let macroData: [(String, String, String, [Color], String)] = []

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {

                // MARK: Header Celebrare
                VStack(spacing: 12) {
                    ZStack {
                        // Halo colorat
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        (vm.obiectivSelectat?.gradient.first ?? Color(hex: "#818CF8")).opacity(0.3),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(ringApare ? 1.0 : 0.3)
                            .blur(radius: 10)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: vm.obiectivSelectat?.gradient ?? [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(ringApare ? 1.0 : 0.3)
                    }
                    .padding(.top, 20)
                    .animation(.spring(duration: 0.7, bounce: 0.4), value: ringApare)

                    Text("Planul Tău e Gata! 🎉")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(ringApare ? 1 : 0)
                        .animation(.easeIn(duration: 0.4).delay(0.3), value: ringApare)

                    VStack(spacing: 4) {
                        Text("Obiectiv: \(vm.obiectivSelectat?.rawValue ?? "")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: vm.obiectivSelectat?.gradient ?? [.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Iată targeturile tale zilnice calculate precis")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .opacity(ringApare ? 1 : 0)
                    .animation(.easeIn(duration: 0.4).delay(0.45), value: ringApare)
                }

                // MARK: Ring-uri Macro (Preview)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        MacroRingCard(
                            titlu: "Calorii", consumat: 0, tinta: vm.tintaKcal, unitate: "kcal",
                            culori: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")],
                            icon: "flame.fill", dimensiuneRing: 90, animat: ringApare
                        )
                        MacroRingCard(
                            titlu: "Proteine", consumat: 0, tinta: vm.tintaProteine, unitate: "g",
                            culori: [Color(hex: "#34D399"), Color(hex: "#059669")],
                            icon: "figure.strengthtraining.traditional", dimensiuneRing: 90, animat: false
                        )
                        MacroRingCard(
                            titlu: "Carbohidrați", consumat: 0, tinta: vm.tintaCarbo, unitate: "g",
                            culori: [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")],
                            icon: "leaf.fill", dimensiuneRing: 90, animat: false
                        )
                        MacroRingCard(
                            titlu: "Grăsimi", consumat: 0, tinta: vm.tintaGrasimi, unitate: "g",
                            culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                            icon: "drop.fill", dimensiuneRing: 90, animat: false
                        )
                        MacroRingCard(
                            titlu: "Apă", consumat: 0, tinta: vm.tintaApa, unitate: "ml",
                            culori: [Color(hex: "#38BDF8"), Color(hex: "#0284C7")],
                            icon: "drop.fill", dimensiuneRing: 90, animat: false
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
                .opacity(rânduriApare ? 1 : 0)
                .animation(.easeIn(duration: 0.4).delay(0.5), value: rânduriApare)

                // MARK: Tabel Macronutrienți Detaliat
                GlassCard(cornerRadius: 20, padding: 20) {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Targeturi Zilnice Detaliate")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chart.bar.fill")
                                .foregroundStyle(Color(hex: "#818CF8"))
                        }

                        Divider().background(.white.opacity(0.1))

                        ForEach(macroRanduri, id: \.0) { rând in
                            MacroRândDetaliat(
                                icon: rând.1,
                                label: rând.0,
                                valoare: rând.2,
                                unitate: rând.3,
                                culori: rând.4,
                                procent: rând.5
                            )
                        }

                        Divider().background(.white.opacity(0.08))

                        // Apă
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(Color(hex: "#38BDF8"))
                                .frame(width: 24)
                            Text("Apă")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(Int(vm.tintaApa)) ml")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: "#38BDF8"))
                            Text("/ \(Int(vm.tintaApa / 250)) pahare")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(rânduriApare ? 1 : 0)
                .offset(y: rânduriApare ? 0 : 20)
                .animation(.spring(duration: 0.5).delay(0.6), value: rânduriApare)

                // MARK: Info Box - Distribuție Mese
                GlassCard(cornerRadius: 16, padding: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Distribuție Recomandată pe Mese", systemImage: "calendar.badge.clock")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        let kcalPerMasa = vm.tintaKcal
                        let mese: [(String, Double, String)] = [
                            ("Mic Dejun", kcalPerMasa * 0.25, "25%"),
                            ("Prânz", kcalPerMasa * 0.35, "35%"),
                            ("Cină", kcalPerMasa * 0.30, "30%"),
                            ("Gustare", kcalPerMasa * 0.10, "10%")
                        ]

                        ForEach(mese, id: \.0) { (masa, kcal, procent) in
                            HStack {
                                Text(masa)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(Int(kcal)) kcal")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                Text("(\(procent))")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(rânduriApare ? 1 : 0)
                .animation(.easeIn(duration: 0.4).delay(0.8), value: rânduriApare)

                // MARK: Buton Start App
                VStack(spacing: 12) {
                    Button {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        withAnimation(.spring(duration: 0.15)) { scareaButon = 0.95 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(duration: 0.3)) { scareaButon = 1.0 }
                            onFinalizare()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.title3)
                            Text("Hai să Începem!")
                                .font(.headline)
                                .fontWeight(.black)
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: vm.obiectivSelectat?.gradient
                                            ?? [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(
                                    color: (vm.obiectivSelectat?.gradient.first ?? Color(hex: "#818CF8")).opacity(0.7),
                                    radius: 24, x: 0, y: 10
                                )
                        }
                    }
                    .scaleEffect(scareaButon)

                    Button {
                        vm.mergeInapoi()
                    } label: {
                        Text("← Înapoi la Obiective")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .opacity(rânduriApare ? 1 : 0)
                .animation(.spring(duration: 0.4).delay(1.0), value: rânduriApare)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6).delay(0.1)) { ringApare = true }
            withAnimation(.easeIn(duration: 0.2).delay(0.3)) { rânduriApare = true }
        }
    }

    // MARK: - Date Macro pentru Rânduri
    var macroRanduri: [(String, String, String, String, [Color], Double)] {
        let totalKcal = vm.tintaKcal
        let proteineKcal = vm.tintaProteine * 4
        let carboKcal = vm.tintaCarbo * 4
        let grasimiKcal = vm.tintaGrasimi * 9

        return [
            ("Calorii Total", "flame.fill", "\(Int(totalKcal))", "kcal",
             [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")], 1.0),
            ("Proteine", "figure.strengthtraining.traditional", "\(Int(vm.tintaProteine))", "g",
             [Color(hex: "#34D399"), Color(hex: "#059669")], proteineKcal / totalKcal),
            ("Carbohidrați", "leaf.fill", "\(Int(vm.tintaCarbo))", "g",
             [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")], carboKcal / totalKcal),
            ("Grăsimi", "drop.fill", "\(Int(vm.tintaGrasimi))", "g",
             [Color(hex: "#F59E0B"), Color(hex: "#D97706")], grasimiKcal / totalKcal)
        ]
    }
}

// MARK: - Rând Macro Detaliat
struct MacroRândDetaliat: View {
    let icon: String
    let label: String
    let valoare: String
    let unitate: String
    let culori: [Color]
    let procent: Double

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(
                        LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 24)

                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.white)

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(valoare)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text(unitate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("(\(Int(procent * 100))%)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(width: 36)
            }

            MacroProgressBar(consumat: procent, tinta: 1.0, culori: culori)
        }
    }
}
