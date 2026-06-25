// MARK: - BiometricsInputView.swift
// NutriAI Pro — Input biometric (Pagina 1)
// Platformă: iOS 17+

import SwiftUI

struct BiometricsInputView: View {

    @Binding var vm: OnboardingViewModel

    // MARK: - Focus State
    @FocusState private var campFocusat: CampFocusat?

    enum CampFocusat: Hashable {
        case nume, varsta, greutate, inaltime
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {

                // MARK: Header
                VStack(spacing: 8) {
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)

                    Text("Date Personale")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Completează datele tale pentru un plan personalizat 100%")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // MARK: Câmp Nume
                VStack(alignment: .leading, spacing: 8) {
                    Label("Prenumele Tău", systemImage: "person.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    TextField("ex: Andrei", text: $vm.numeUtilizator)
                        .textFieldStyle(NutriTextFieldStyle())
                        .focused($campFocusat, equals: .nume)
                        .submitLabel(.next)
                        .onSubmit { campFocusat = .varsta }
                }
                .padding(.horizontal, 24)

                // MARK: Selecție Gen
                VStack(alignment: .leading, spacing: 12) {
                    Label("Gen", systemImage: "figure.stand")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                        .padding(.horizontal, 24)

                    HStack(spacing: 14) {
                        ForEach(Gen.allCases, id: \.self) { gen in
                            GenButton(
                                gen: gen,
                                esteSelectat: vm.genSelectat == gen,
                                onSelectat: {
                                    withAnimation(.spring(duration: 0.3)) {
                                        vm.genSelectat = gen
                                    }
                                    UISelectionFeedbackGenerator().selectionChanged()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // MARK: Slider Vârstă
                BiometricSlider(
                    titlu: "Vârstă",
                    icon: "calendar",
                    valoare: $vm.varsta,
                    minim: 13,
                    maxim: 90,
                    unitate: "ani",
                    culori: [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")],
                    pas: 1
                )
                .padding(.horizontal, 24)

                // MARK: Slider Greutate
                BiometricSlider(
                    titlu: "Greutate",
                    icon: "scalemass.fill",
                    valoare: $vm.greutate,
                    minim: 40,
                    maxim: 200,
                    unitate: "kg",
                    culori: [Color(hex: "#34D399"), Color(hex: "#059669")],
                    pas: 0.5
                )
                .padding(.horizontal, 24)

                // MARK: Slider Înălțime
                BiometricSlider(
                    titlu: "Înălțime",
                    icon: "ruler.fill",
                    valoare: $vm.inaltime,
                    minim: 140,
                    maxim: 220,
                    unitate: "cm",
                    culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                    pas: 1
                )
                .padding(.horizontal, 24)

                // MARK: IMC Live Preview
                IMCLivePreview(imc: vm.imcLive, categorie: vm.categorieIMCLive)
                    .padding(.horizontal, 24)

                // MARK: Nivel Activitate
                VStack(alignment: .leading, spacing: 14) {
                    Label("Nivel de Activitate", systemImage: "figure.run")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                        .padding(.horizontal, 24)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(NivelActivitate.allCases, id: \.self) { nivel in
                                NivelActivitateCard(
                                    nivel: nivel,
                                    esteSelectat: vm.nivelActivitate == nivel,
                                    onSelectat: {
                                        withAnimation(.spring(duration: 0.3)) {
                                            vm.nivelActivitate = nivel
                                        }
                                        UISelectionFeedbackGenerator().selectionChanged()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }

                // MARK: BMR/TDEE Preview
                BMRTDEEPreview(bmr: vm.bmrLive, tdee: vm.tdeeLive)
                    .padding(.horizontal, 24)

                // MARK: Buton Continuare
                Button {
                    campFocusat = nil
                    vm.mergeInainte()
                } label: {
                    HStack(spacing: 8) {
                        Text("Continuă")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                vm.inputuriBiometriceValide
                                ? LinearGradient(
                                    colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
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
                                color: vm.inputuriBiometriceValide ? Color(hex: "#4F46E5").opacity(0.5) : .clear,
                                radius: 14, x: 0, y: 6
                            )
                    }
                }
                .disabled(!vm.inputuriBiometriceValide)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Buton Gen
struct GenButton: View {
    let gen: Gen
    let esteSelectat: Bool
    let onSelectat: () -> Void

    var body: some View {
        Button(action: onSelectat) {
            HStack(spacing: 10) {
                Image(systemName: gen == .masculin ? "figure.stand" : "figure.stand.dress")
                    .font(.title3)

                Text(gen.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(esteSelectat ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        esteSelectat
                        ? LinearGradient(
                            colors: gen.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
                    .shadow(
                        color: esteSelectat ? (gen.gradient.first?.opacity(0.4) ?? .clear) : .clear,
                        radius: 8, x: 0, y: 4
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        esteSelectat ? .clear : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.3), value: esteSelectat)
    }
}

// MARK: - Slider Biometric Custom
struct BiometricSlider: View {
    let titlu: String
    let icon: String
    @Binding var valoare: Double
    let minim: Double
    let maxim: Double
    let unitate: String
    let culori: [Color]
    var pas: Double = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(titlu, systemImage: icon)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()

                // Valoare cu animație
                Text("\(pas < 1 ? String(format: "%.1f", valoare) : String(Int(valoare))) \(unitate)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(colors: culori, startPoint: .leading, endPoint: .trailing)
                    )
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.3), value: valoare)
            }

            // Slider personalizat
            ZStack(alignment: .leading) {
                // Track fundal
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 8)

                // Progress fill
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(colors: culori, startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(
                            width: geo.size.width * CGFloat((valoare - minim) / (maxim - minim)),
                            height: 8
                        )
                        .shadow(color: culori.first?.opacity(0.5) ?? .clear, radius: 6, x: 0, y: 0)
                }
                .frame(height: 8)
            }
            .overlay(
                Slider(value: $valoare, in: minim...maxim, step: pas)
                    .tint(.clear)
                    .onChange(of: valoare) { _, _ in
                        UISelectionFeedbackGenerator().selectionChanged()
                    }
            )
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - IMC Live Preview
struct IMCLivePreview: View {
    let imc: Double
    let categorie: CategorieIMC

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: categorie.icon)
                .font(.title2)
                .foregroundStyle(categorie.culoare)

            VStack(alignment: .leading, spacing: 2) {
                Text("IMC Preview")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(String(format: "%.1f", imc)) — \(categorie.rawValue)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(categorie.culoare)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.4), value: imc)
            }

            Spacer()

            // Mini bară IMC
            MiniIMCBar(imc: imc)
        }
        .padding(16)
        .background(categorie.culoare.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(categorie.culoare.opacity(0.25), lineWidth: 1)
        )
        .animation(.spring(duration: 0.4), value: imc)
    }
}

// MARK: - Mini IMC Bar
struct MiniIMCBar: View {
    let imc: Double

    private var pozitie: Double {
        // IMC mapare 10 → 40 pe o bară de 0 → 1
        min(max((imc - 10) / 30, 0), 1)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [
                    Color(hex: "#60A5FA"),
                    Color(hex: "#34D399"),
                    Color(hex: "#F59E0B"),
                    Color(hex: "#F87171")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 70, height: 8)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // Indicator
            Circle()
                .fill(.white)
                .frame(width: 14, height: 14)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                .offset(x: max(0, min(56, 56 * pozitie)))
                .animation(.spring(duration: 0.4), value: imc)
        }
        .frame(width: 70)
    }
}

// MARK: - BMR TDEE Preview
struct BMRTDEEPreview: View {
    let bmr: Double
    let tdee: Double

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 4) {
                Text("BMR")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .tracking(1)
                Text("\(Int(bmr))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#818CF8"))
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.3), value: bmr)
                Text("kcal/zi")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(width: 1, height: 40)

            VStack(spacing: 4) {
                Text("TDEE")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .tracking(1)
                Text("\(Int(tdee))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#34D399"))
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.3), value: tdee)
                Text("kcal/zi")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(width: 1, height: 40)

            VStack(spacing: 4) {
                Image(systemName: "info.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Se actualizează")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                Text("în timp real")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Card Nivel Activitate
struct NivelActivitateCard: View {
    let nivel: NivelActivitate
    let esteSelectat: Bool
    let onSelectat: () -> Void

    var body: some View {
        Button(action: onSelectat) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            esteSelectat
                            ? LinearGradient(colors: nivel.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: nivel.icon)
                        .font(.title3)
                        .foregroundStyle(esteSelectat ? .white : .secondary)
                }

                Text(nivel.rawValue)
                    .font(.caption)
                    .fontWeight(esteSelectat ? .semibold : .regular)
                    .foregroundStyle(esteSelectat ? .white : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 80)

                Text(nivel.descriere)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
                    .lineLimit(2)
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(esteSelectat ? nivel.gradient.first?.opacity(0.15) ?? .clear : Color.clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        esteSelectat
                        ? LinearGradient(colors: nivel.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: esteSelectat ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.3), value: esteSelectat)
    }
}

// MARK: - TextField Style Personalizat
struct NutriTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
            )
            .foregroundStyle(.white)
            .font(.body)
    }
}
