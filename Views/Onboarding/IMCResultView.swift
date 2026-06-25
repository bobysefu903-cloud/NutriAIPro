// MARK: - IMCResultView.swift
// NutriAI Pro — Ecranul cu rezultatele IMC/BMR/TDEE (Pagina 2)
// Platformă: iOS 17+

import SwiftUI

struct IMCResultView: View {

    @Binding var vm: OnboardingViewModel

    // MARK: - Animații
    @State private var inelApare: Bool = false
    @State private var statApare: Bool = false
    @State private var imcValoareAfisata: Double = 0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {

                // MARK: Header
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)

                    Text("Analiza Ta")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Bazat pe datele introduse, iată profilul tău metabolic")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // MARK: IMC Inel Central + Categorie
                VStack(spacing: 16) {
                    ZStack {
                        // Ring IMC
                        AnimatedRing(
                            progres: min(vm.imc / 40.0, 1.0),
                            culori: [vm.categorieIMC.culoare, vm.categorieIMC.culoare.opacity(0.6)],
                            grosime: 16,
                            dimensiune: 160,
                            animat: inelApare
                        )

                        // Conținut central
                        VStack(spacing: 4) {
                            Text("IMC")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .tracking(2)

                            Text(String(format: "%.1f", imcValoareAfisata))
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundStyle(vm.categorieIMC.culoare)
                                .contentTransition(.numericText())

                            Image(systemName: vm.categorieIMC.icon)
                                .font(.caption)
                                .foregroundStyle(vm.categorieIMC.culoare)
                        }
                    }

                    // Categorie Badge
                    HStack(spacing: 8) {
                        Circle()
                            .fill(vm.categorieIMC.culoare)
                            .frame(width: 8, height: 8)

                        Text(vm.categorieIMC.rawValue)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(vm.categorieIMC.culoare.opacity(0.15), in: Capsule())
                    .overlay(Capsule().strokeBorder(vm.categorieIMC.culoare.opacity(0.3), lineWidth: 1))

                    // Mesaj categoria
                    Text(vm.categorieIMC.mesaj)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 10)

                // MARK: IMC Scale vizuală
                IMCScaleView(imc: vm.imc)
                    .padding(.horizontal, 24)
                    .opacity(statApare ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(0.4), value: statApare)

                // MARK: Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    StatCard(
                        titlu: "BMR",
                        valoare: String(format: "%.0f", vm.bmr),
                        unitate: "kcal/zi",
                        subtitlu: "Metabolism Bazal",
                        icon: "flame.fill",
                        culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
                    )
                    StatCard(
                        titlu: "TDEE",
                        valoare: String(format: "%.0f", vm.tdee),
                        unitate: "kcal/zi",
                        subtitlu: "Consum Total Zilnic",
                        icon: "bolt.fill",
                        culori: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")]
                    )
                    StatCard(
                        titlu: "Greutate Ideală",
                        valoare: vm.greutateIdealaText,
                        unitate: "",
                        subtitlu: "Formula Robinson",
                        icon: "target",
                        culori: [Color(hex: "#34D399"), Color(hex: "#059669")]
                    )
                    StatCard(
                        titlu: "Activitate",
                        valoare: vm.nivelActivitate.rawValue,
                        unitate: "",
                        subtitlu: "Multiplicator \(String(format: "×%.2f", vm.nivelActivitate.multiplicator))",
                        icon: vm.nivelActivitate.icon,
                        culori: vm.nivelActivitate.gradient
                    )
                }
                .padding(.horizontal, 24)
                .opacity(statApare ? 1 : 0)
                .offset(y: statApare ? 0 : 20)
                .animation(.spring(duration: 0.6).delay(0.3), value: statApare)

                // MARK: Info Box
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color(hex: "#60A5FA"))

                    Text("**BMR** (Basal Metabolic Rate) = caloriile pe care corpul tău le arde la repaus complet. **TDEE** include activitatea zilnică.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(Color(hex: "#1E3A8A").opacity(0.3), in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color(hex: "#60A5FA").opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .opacity(statApare ? 1 : 0)
                .animation(.easeIn(duration: 0.4).delay(0.6), value: statApare)

                // MARK: Navigare
                HStack(spacing: 14) {
                    // Înapoi
                    Button {
                        vm.mergeInapoi()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(width: 54, height: 54)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    }

                    // Continuă
                    Button {
                        vm.mergeInainte()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Selectează Obiectiv")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(hex: "#059669").opacity(0.5), radius: 14, x: 0, y: 6)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 1.2, bounce: 0.2).delay(0.1)) {
                inelApare = true
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
                statApare = true
            }
            withAnimation(.spring(duration: 1.0).delay(0.3)) {
                imcValoareAfisata = vm.imc
            }
        }
    }
}

// MARK: - Scală IMC Vizuală
struct IMCScaleView: View {
    let imc: Double

    private let categorii: [(String, Color, ClosedRange<Double>)] = [
        ("< 18.5",  Color(hex: "#60A5FA"), 10...18.5),
        ("18.5–25", Color(hex: "#34D399"), 18.5...25),
        ("25–30",   Color(hex: "#F59E0B"), 25...30),
        ("> 30",    Color(hex: "#F87171"), 30...40)
    ]

    private var pozitieIndicator: Double {
        let mapat = (imc - 10) / 30
        return min(max(mapat, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SCALA IMC")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(1.5)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Bare colorate
                    HStack(spacing: 2) {
                        ForEach(0..<categorii.count, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(categorii[i].1)
                                .frame(height: 10)
                        }
                    }
                    .clipShape(Capsule())

                    // Indicator IMC
                    Circle()
                        .fill(.white)
                        .frame(width: 18, height: 18)
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                        .overlay(
                            Circle().strokeBorder(
                                CategorieIMC.dinValoare(imc).culoare,
                                lineWidth: 2.5
                            )
                        )
                        .offset(x: max(0, min(geo.size.width - 18, (geo.size.width - 18) * pozitieIndicator)))
                        .animation(.spring(duration: 0.6), value: imc)
                }
                .frame(height: 18)
            }
            .frame(height: 18)

            // Labels
            HStack {
                Text("Subponderal")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "#60A5FA"))
                Spacer()
                Text("Normal")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "#34D399"))
                Spacer()
                Text("Supraponderal")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "#F59E0B"))
                Spacer()
                Text("Obezitate")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(hex: "#F87171"))
            }
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let titlu: String
    let valoare: String
    let unitate: String
    let subtitlu: String
    let icon: String
    let culori: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(
                        LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Spacer()
                Text(titlu.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            Text(valoare)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !unitate.isEmpty {
                Text(unitate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(subtitlu)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [culori.first?.opacity(0.3) ?? .clear, .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}
