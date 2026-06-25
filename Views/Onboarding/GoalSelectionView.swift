// MARK: - GoalSelectionView.swift
// NutriAI Pro — Selectarea obiectivului (Pagina 3)
// Platformă: iOS 17+

import SwiftUI

struct GoalSelectionView: View {

    @Binding var vm: OnboardingViewModel
    @State private var carduriApare: Bool = false
    @State private var obiectivHover: Obiectiv? = nil

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {

                // MARK: Header
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)

                    Text("Obiectivul Tău")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Alege ce dorești să realizezi — planul tău se adaptează automat")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // MARK: Info bazat pe IMC
                if vm.categorieIMC != .normal {
                    IMCRecomandareView(categorie: vm.categorieIMC, obiectivRecomandat: obiectivRecomandat)
                        .padding(.horizontal, 24)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // MARK: Carduri Obiective
                VStack(spacing: 14) {
                    ForEach(Array(Obiectiv.allCases.enumerated()), id: \.offset) { index, obiectiv in
                        ObiectivCard(
                            obiectiv: obiectiv,
                            esteSelectat: vm.obiectivSelectat == obiectiv,
                            esteRecomandat: obiectiv == obiectivRecomandat,
                            tdee: vm.tdee,
                            onSelectat: {
                                withAnimation(.spring(duration: 0.3)) {
                                    vm.calculeazaValoriFinale(obiectiv: obiectiv)
                                }
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        )
                        .opacity(carduriApare ? 1 : 0)
                        .offset(y: carduriApare ? 0 : 30)
                        .animation(
                            .spring(duration: 0.5, bounce: 0.2).delay(Double(index) * 0.1),
                            value: carduriApare
                        )
                    }
                }
                .padding(.horizontal, 24)

                // MARK: Preview Macro (dacă obiectiv selectat)
                if let obiectiv = vm.obiectivSelectat {
                    ObiectivMacroPreview(vm: vm, obiectiv: obiectiv)
                        .padding(.horizontal, 24)
                        .transition(.scale.combined(with: .opacity))
                }

                // MARK: Navigare
                HStack(spacing: 14) {
                    Button {
                        vm.mergeInapoi()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(width: 54, height: 54)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        vm.mergeInainte()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Generează Planul")
                                .fontWeight(.bold)
                            Image(systemName: "sparkles")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    vm.obiectivSelectatValid
                                    ? LinearGradient(
                                        colors: vm.obiectivSelectat?.gradient ?? [.purple, .indigo],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                      )
                                    : LinearGradient(
                                        colors: [Color.gray.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                      )
                                )
                                .shadow(
                                    color: vm.obiectivSelectatValid
                                        ? (vm.obiectivSelectat?.gradient.first?.opacity(0.5) ?? .clear)
                                        : .clear,
                                    radius: 14, x: 0, y: 6
                                )
                        }
                    }
                    .disabled(!vm.obiectivSelectatValid)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.1)) {
                carduriApare = true
            }
        }
    }

    // MARK: - Obiectiv Recomandat bazat pe IMC
    var obiectivRecomandat: Obiectiv {
        switch vm.categorieIMC {
        case .subponderal:   return .crestereMusculara
        case .normal:        return .mentinere
        case .supraponderal: return .slabireModerate
        case .obezitate:     return .deficitAgresiv
        }
    }
}

// MARK: - Card Obiectiv
struct ObiectivCard: View {
    let obiectiv: Obiectiv
    let esteSelectat: Bool
    let esteRecomandat: Bool
    let tdee: Double
    let onSelectat: () -> Void

    private var calorii: Double { tdee + obiectiv.ajustareCaloriica }

    var body: some View {
        Button(action: onSelectat) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Icon cu gradient
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: obiectiv.gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .shadow(
                                color: obiectiv.gradient.first?.opacity(0.5) ?? .clear,
                                radius: 8, x: 0, y: 4
                            )

                        Image(systemName: obiectiv.icon)
                            .font(.title3)
                            .foregroundStyle(.white)
                    }

                    // Text info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(obiectiv.rawValue)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)

                            if esteRecomandat {
                                Text("RECOMANDAT")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        obiectiv.gradient.first?.opacity(0.8) ?? .clear,
                                        in: Capsule()
                                    )
                            }
                        }

                        Text(obiectiv.descriere)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    // Checkmark dacă selectat
                    ZStack {
                        Circle()
                            .stroke(
                                esteSelectat
                                ? LinearGradient(colors: obiectiv.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                            .frame(width: 24, height: 24)

                        if esteSelectat {
                            Circle()
                                .fill(
                                    LinearGradient(colors: obiectiv.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 16, height: 16)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(duration: 0.3), value: esteSelectat)
                }
                .padding(16)

                // MARK: Preview Calorii (dacă selectat)
                if esteSelectat {
                    Divider()
                        .background(.white.opacity(0.08))

                    HStack(spacing: 0) {
                        VStack(spacing: 2) {
                            Text("\(Int(calorii))")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(colors: obiectiv.gradient, startPoint: .leading, endPoint: .trailing)
                                )
                            Text("kcal/zi țintă")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 1, height: 30)

                        VStack(spacing: 2) {
                            Text(obiectiv.ajustareCaloriica == 0
                                ? "±0"
                                : (obiectiv.ajustareCaloriica > 0 ? "+\(Int(obiectiv.ajustareCaloriica))" : "\(Int(obiectiv.ajustareCaloriica))"))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    obiectiv.ajustareCaloriica > 0
                                    ? Color(hex: "#34D399")
                                    : obiectiv.ajustareCaloriica < 0
                                        ? Color(hex: "#F87171")
                                        : Color(hex: "#818CF8")
                                )
                            Text("ajustare față de TDEE")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        esteSelectat
                        ? obiectiv.gradient.first?.opacity(0.12) ?? .clear
                        : Color.white.opacity(0.05)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        esteSelectat
                        ? LinearGradient(
                            colors: [obiectiv.gradient.first ?? .purple, obiectiv.gradient.first?.opacity(0.3) ?? .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                        : LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: esteSelectat ? 1.5 : 1
                    )
            }
            .shadow(
                color: esteSelectat ? (obiectiv.gradient.first?.opacity(0.2) ?? .clear) : .clear,
                radius: 12, x: 0, y: 6
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.35), value: esteSelectat)
    }
}

// MARK: - Recomandare bazată pe IMC
struct IMCRecomandareView: View {
    let categorie: CategorieIMC
    let obiectivRecomandat: Obiectiv

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.title3)
                .foregroundStyle(Color(hex: "#F59E0B"))

            VStack(alignment: .leading, spacing: 3) {
                Text("Recomandare Personalizată")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#F59E0B"))

                Text("Bazat pe IMC-ul tău (\(categorie.rawValue)), **\(obiectivRecomandat.rawValue)** este cel mai potrivit obiectiv.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color(hex: "#92400E").opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(hex: "#F59E0B").opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview Macro după selecție obiectiv
struct ObiectivMacroPreview: View {
    let vm: OnboardingViewModel
    let obiectiv: Obiectiv

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(
                        LinearGradient(colors: obiectiv.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("Macronutrienți Generați")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer()
                Text("/ zi")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                MiniMacroChip(label: "Calorii", valoare: "\(Int(vm.tintaKcal))", unitate: "kcal",
                              culori: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")])
                MiniMacroChip(label: "Proteine", valoare: "\(Int(vm.tintaProteine))", unitate: "g",
                              culori: [Color(hex: "#34D399"), Color(hex: "#059669")])
                MiniMacroChip(label: "Carbohidrați", valoare: "\(Int(vm.tintaCarbo))", unitate: "g",
                              culori: [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")])
                MiniMacroChip(label: "Grăsimi", valoare: "\(Int(vm.tintaGrasimi))", unitate: "g",
                              culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")])
            }
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct MiniMacroChip: View {
    let label: String
    let valoare: String
    let unitate: String
    let culori: [Color]

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(valoare)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.4), value: valoare)
                    Text(unitate)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(10)
        .background(culori.first?.opacity(0.1) ?? .clear, in: RoundedRectangle(cornerRadius: 12))
    }
}
