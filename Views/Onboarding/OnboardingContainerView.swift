// MARK: - OnboardingContainerView.swift
// NutriAI Pro — Container pentru fluxul de onboarding
// Platformă: iOS 17+

import SwiftUI
import SwiftData

struct OnboardingContainerView: View {

    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext

    // MARK: - ViewModel
    @State private var vm = OnboardingViewModel()

    // MARK: - Callback
    var onFinalizare: () -> Void

    var body: some View {
        ZStack {
            // MARK: Fundal Animat
            FundaleAnimatGradient()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Bară Progres
                if vm.paginaCurenta > 0 {
                    BaraProgresOnboarding(paginaCurenta: vm.paginaCurenta, totalPagini: 5)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(duration: 0.4), value: vm.paginaCurenta)
                }

                // MARK: Conținut Pagini
                TabView(selection: $vm.paginaCurenta) {

                    WelcomeView(vm: $vm)
                        .tag(0)

                    BiometricsInputView(vm: $vm)
                        .tag(1)

                    IMCResultView(vm: $vm)
                        .tag(2)

                    GoalSelectionView(vm: $vm)
                        .tag(3)

                    MacroSummaryView(vm: $vm, onFinalizare: {
                        vm.finalizeazaOnboarding(context: modelContext)
                        onFinalizare()
                    })
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: vm.paginaCurenta)
            }
        }
        .alert("Atenție", isPresented: $vm.seAfisezaEroare) {
            Button("OK") { vm.seAfisezaEroare = false }
        } message: {
            Text(vm.mesajEroare)
        }
    }
}

// MARK: - Bară Progres
struct BaraProgresOnboarding: View {
    let paginaCurenta: Int
    let totalPagini: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1..<totalPagini, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        index <= paginaCurenta
                        ? LinearGradient(
                            colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                    )
                    .frame(height: 4)
                    .animation(.spring(duration: 0.4), value: paginaCurenta)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Fundal Animat cu Gradient
struct FundaleAnimatGradient: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black

            // Blob 1
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#4F46E5").opacity(0.4), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -80, y: -200 + phase * 20)
                .blur(radius: 30)

            // Blob 2
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#7C3AED").opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: 120, y: 200 - phase * 15)
                .blur(radius: 40)

            // Blob 3
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#059669").opacity(0.2), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: -60, y: 350 + phase * 10)
                .blur(radius: 35)

            // Noise overlay pentru textură
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.1)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }
}
