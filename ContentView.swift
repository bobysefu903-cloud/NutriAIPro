// MARK: - ContentView.swift
// NutriAI Pro — Navigare principală (Tab Bar)
// Platformă: iOS 26+ | Liquid Glass Tab Bar nativ

import SwiftUI
import SwiftData

struct ContentView: View {

    // MARK: - Tab Selection
    @State private var tabSelectat: String = "azi"

    // MARK: - ViewModels
    @State private var dashboardVM = DashboardViewModel()
    @State private var recipeVM    = RecipeViewModel()
    @State private var aiCoachVM   = AICoachViewModel()

    // MARK: - SwiftData
    @Environment(\.modelContext) private var modelContext
    @Query private var profiluri: [ProfilUtilizator]

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                // MARK: iOS 26 — Tab API nativ cu Liquid Glass floating tab bar
                TabView(selection: $tabSelectat) {
                    Tab("Azi", systemImage: "chart.pie.fill", value: "azi") {
                        DashboardView(viewModel: dashboardVM, recipeVM: recipeVM)
                    }
                    Tab("Rețete", systemImage: "fork.knife.circle.fill", value: "retete") {
                        RecipeListView(viewModel: recipeVM, dashboardVM: dashboardVM)
                    }
                    Tab("AI Coach", systemImage: "brain.head.profile.fill", value: "coach") {
                        AICoachView(viewModel: aiCoachVM, dashboardVM: dashboardVM)
                    }
                    Tab("Profil", systemImage: "person.crop.circle.fill", value: "profil") {
                        ProfilView()
                    }
                }
                .tint(Color(hex: "#818CF8"))
            } else {
                // MARK: iOS 17–25 — TabView clasic cu UIAppearance
                TabView(selection: $tabSelectat) {
                    DashboardView(viewModel: dashboardVM, recipeVM: recipeVM)
                        .tabItem { Label("Azi", systemImage: "chart.pie.fill") }
                        .tag("azi")

                    RecipeListView(viewModel: recipeVM, dashboardVM: dashboardVM)
                        .tabItem { Label("Rețete", systemImage: "fork.knife.circle.fill") }
                        .tag("retete")

                    AICoachView(viewModel: aiCoachVM, dashboardVM: dashboardVM)
                        .tabItem { Label("AI Coach", systemImage: "brain.head.profile.fill") }
                        .tag("coach")

                    ProfilView()
                        .tabItem { Label("Profil", systemImage: "person.crop.circle.fill") }
                        .tag("profil")
                }
                .tint(Color(hex: "#818CF8"))
                .onAppear { configureazaTabBarLegacy() }
            }
        }
        .onAppear {
            dashboardVM.configureaza(context: modelContext)
            recipeVM.configureaza(context: modelContext)
            aiCoachVM.configureaza(context: modelContext)

            if profiluri.first != nil {
                recipeVM.creeazaReteteDemo()
            }
        }
    }

    // MARK: - Configurare Tab Bar Legacy (iOS 17–25)
    private func configureazaTabBarLegacy() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(white: 0.05, alpha: 0.95)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Profil View
struct ProfilView: View {

    @Query private var profiluri: [ProfilUtilizator]
    @Environment(\.modelContext) private var modelContext
    var profil: ProfilUtilizator? { profiluri.first }

    @State private var seAfisezaConfirmareReset: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Avatar
                    VStack(spacing: 12) {
                        ZStack {
                            if #available(iOS 26, *) {
                                Circle()
                                    .glassEffect()
                                    .frame(width: 90, height: 90)
                            } else {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                            }

                            Text(String(profil?.numeUtilizator.prefix(1).uppercased() ?? "U"))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: Color(hex: "#818CF8").opacity(0.5), radius: 16, x: 0, y: 8)

                        Text(profil?.numeUtilizator ?? "Utilizator")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Badge(
                            text: profil?.obiectiv.rawValue ?? "—",
                            culori: profil?.obiectiv.gradient ?? [.purple, .indigo]
                        )
                    }
                    .padding(.top, 20)

                    // MARK: Date Biometrice
                    GlassCard {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Date Biometrice")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "person.fill")
                                    .foregroundStyle(Color(hex: "#818CF8"))
                            }

                            Divider().background(.white.opacity(0.1))

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                ProfilStatCard(titlu: "Vârstă", valoare: "\(profil?.varsta ?? 0)", unitate: "ani",
                                               icon: "calendar", culori: [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")])
                                ProfilStatCard(titlu: "Greutate", valoare: String(format: "%.1f", profil?.greutate ?? 0), unitate: "kg",
                                               icon: "scalemass.fill", culori: [Color(hex: "#34D399"), Color(hex: "#059669")])
                                ProfilStatCard(titlu: "Înălțime", valoare: "\(Int(profil?.inaltime ?? 0))", unitate: "cm",
                                               icon: "ruler.fill", culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")])
                                ProfilStatCard(titlu: "IMC", valoare: String(format: "%.1f", profil?.imc ?? 0), unitate: profil?.categorieIMC.rawValue ?? "",
                                               icon: "chart.bar.fill", culori: profil?.categorieIMC.culoare.asGradient() ?? [.green, .teal])
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Targeturi Zilnice
                    GlassCard {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Targeturi Zilnice")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "target")
                                    .foregroundStyle(Color(hex: "#F59E0B"))
                            }

                            Divider().background(.white.opacity(0.1))

                            VStack(spacing: 10) {
                                TargetRow(label: "Calorii", valoare: "\(Int(profil?.tintaKcal ?? 0)) kcal",
                                          culori: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")])
                                TargetRow(label: "Proteine", valoare: "\(Int(profil?.tintaProteine ?? 0)) g",
                                          culori: [Color(hex: "#34D399"), Color(hex: "#059669")])
                                TargetRow(label: "Carbohidrați", valoare: "\(Int(profil?.tintaCarbo ?? 0)) g",
                                          culori: [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")])
                                TargetRow(label: "Grăsimi", valoare: "\(Int(profil?.tintaGrasimi ?? 0)) g",
                                          culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")])
                                TargetRow(label: "Apă", valoare: "\(Int(profil?.tintaApa ?? 0)) ml",
                                          culori: [Color(hex: "#38BDF8"), Color(hex: "#0284C7")])
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Buton Reset
                    Button {
                        seAfisezaConfirmareReset = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Resetează Profilul")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.red.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)

                    Text("NutriAI Pro v1.0 • iOS 26 Liquid Glass Edition\nDate stocate local. Fără abonament necesar.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Resetare Profil", isPresented: $seAfisezaConfirmareReset) {
            Button("Anulează", role: .cancel) {}
            Button("Resetează", role: .destructive) {
                UserDefaults.standard.removeObject(forKey: "onboardingFinalizat")
                NotificationCenter.default.post(name: .resetOnboarding, object: nil)
            }
        } message: {
            Text("Profilul și toate datele vor fi șterse. Ești sigur?")
        }
    }
}

// MARK: - Helper Views
struct ProfilStatCard: View {
    let titlu: String
    let valoare: String
    let unitate: String
    let icon: String
    let culori: [Color]

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(
                    LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            Text(valoare)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            Text("\(titlu)\n\(unitate)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct TargetRow: View {
    let label: String
    let valoare: String
    let culori: [Color]

    var body: some View {
        HStack {
            Circle()
                .fill(LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 8, height: 8)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(valoare)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}

extension Color {
    func asGradient() -> [Color] {
        [self, self.opacity(0.6)]
    }
}
