// MARK: - WaterTrackingView.swift
// NutriAI Pro — Tracker hidratare
// Platformă: iOS 17+

import SwiftUI

struct WaterTrackingView: View {

    @Bindable var viewModel: DashboardViewModel
    @State private var seAnimaUnda: Bool = false
    @State private var seAfisezaCustom: Bool = false
    @State private var cantitateCustom: String = ""

    let optiuniRapide: [(String, Double)] = [
        ("☕ Espresso", 30),
        ("🥤 Pahar Mic", 150),
        ("💧 Pahar", 250),
        ("🍶 Sticlă Mică", 500),
        ("🚰 Sticlă Mare", 750)
    ]

    var procentApa: Double {
        guard let profil = viewModel.profil else { return 0 }
        return min(viewModel.apaConsumataML / profil.tintaApa, 1.0)
    }

    var culoareApa: [Color] {
        switch procentApa {
        case ..<0.3: return [Color(hex: "#F87171"), Color(hex: "#DC2626")]
        case 0.3..<0.6: return [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
        default: return [Color(hex: "#38BDF8"), Color(hex: "#0284C7")]
        }
    }

    var body: some View {
        GlassCard(cornerRadius: 20, padding: 18, culoareTinta: Color(hex: "#0284C7")) {
            VStack(spacing: 16) {

                // MARK: Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "drop.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(colors: culoareApa, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )

                        Text("Hidratare")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    // Valori
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(Int(viewModel.apaConsumataML))")
                                .font(.headline)
                                .fontWeight(.black)
                                .foregroundStyle(
                                    LinearGradient(colors: culoareApa, startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .contentTransition(.numericText())
                                .animation(.spring(duration: 0.4), value: viewModel.apaConsumataML)
                            Text("/ \(Int(viewModel.profil?.tintaApa ?? 2500)) ml")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("\(Int(procentApa * 100))% din țintă")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: Bară Progres Apă Animată
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Track
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.08))
                            .frame(height: 20)

                        // Fill cu animație undă
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: culoareApa,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(24, geo.size.width * procentApa), height: 20)
                            .shadow(color: culoareApa.first?.opacity(0.6) ?? .clear, radius: 6, x: 0, y: 0)
                            .animation(.spring(duration: 0.6), value: procentApa)
                            .overlay(alignment: .trailing) {
                                // Efect undă animat
                                Circle()
                                    .fill(.white.opacity(seAnimaUnda ? 0.25 : 0.0))
                                    .frame(width: 16, height: 16)
                                    .scaleEffect(seAnimaUnda ? 1.5 : 1.0)
                                    .animation(
                                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                                        value: seAnimaUnda
                                    )
                                    .padding(.trailing, 2)
                            }

                        // Text procent pe bară
                        if procentApa > 0.15 {
                            Text("\(Int(procentApa * 100))%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.leading, 10)
                        }
                    }
                }
                .frame(height: 20)

                // MARK: Pahare Vizuale
                HStack(spacing: 6) {
                    ForEach(0..<8, id: \.self) { index in
                        let plinPana = viewModel.apaConsumataML / (viewModel.profil?.tintaApa ?? 2500) * 8
                        Image(systemName: Double(index) < plinPana ? "drop.fill" : "drop")
                            .font(.title3)
                            .foregroundStyle(
                                Double(index) < plinPana
                                ? LinearGradient(colors: culoareApa, startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [.white.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                            )
                            .animation(.spring(duration: 0.3).delay(Double(index) * 0.05), value: viewModel.apaConsumataML)
                    }

                    Spacer()

                    Text("≈ \(Int(viewModel.apaConsumataML / 250)) pahare")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // MARK: Butoane Rapide
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(optiuniRapide, id: \.0) { (label, cantitate) in
                            Button {
                                withAnimation(.spring(duration: 0.4)) {
                                    viewModel.adaugaApa(cantitateML: cantitate)
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                VStack(spacing: 4) {
                                    Text(label.components(separatedBy: " ").first ?? "")
                                        .font(.title3)
                                    Text("\(Int(cantitate))ml")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .pressEffect()
                        }

                        // Custom
                        Button {
                            seAfisezaCustom = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(culoareApa.first ?? .blue)
                                Text("Custom")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(culoareApa.first?.opacity(0.12) ?? .clear, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(culoareApa.first?.opacity(0.3) ?? .clear, lineWidth: 1)
                            )
                        }

                        // Reset
                        Button {
                            viewModel.resetApa()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(10)
                                .background(.white.opacity(0.07), in: Circle())
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                seAnimaUnda = true
            }
        }
        .sheet(isPresented: $seAfisezaCustom) {
            VStack(spacing: 20) {
                Text("Adaugă Cantitate Custom")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.top, 20)

                TextField("ml de apă", text: $cantitateCustom)
                    .keyboardType(.numberPad)
                    .textFieldStyle(NutriTextFieldStyle())
                    .padding(.horizontal, 24)

                Button {
                    if let cantitate = Double(cantitateCustom), cantitate > 0 {
                        viewModel.adaugaApa(cantitateML: cantitate)
                        cantitateCustom = ""
                        seAfisezaCustom = false
                    }
                } label: {
                    Text("Adaugă \(cantitateCustom.isEmpty ? "—" : cantitateCustom + " ml")")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color(hex: "#38BDF8"), Color(hex: "#0284C7")],
                                           startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                }
                .padding(.horizontal, 24)
                .disabled(cantitateCustom.isEmpty)

                Spacer()
            }
            .presentationDetents([.height(220)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.ultraThinMaterial)
        }
    }
}
