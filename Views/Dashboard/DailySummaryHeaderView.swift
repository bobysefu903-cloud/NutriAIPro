// MARK: - DailySummaryHeaderView.swift
// NutriAI Pro — Header dashboard cu salut și status zilnic
// Platformă: iOS 17+

import SwiftUI

struct DailySummaryHeaderView: View {
    @Bindable var viewModel: DashboardViewModel
    @State private var salutApare: Bool = false

    var body: some View {
        GlassCard(cornerRadius: 20, padding: 18) {
            VStack(spacing: 14) {
                // MARK: Top Row — Salut + Status
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.salutPersonalizat)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .opacity(salutApare ? 1 : 0)
                            .offset(x: salutApare ? 0 : -20)

                        Text(viewModel.dataFormatayta)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .opacity(salutApare ? 1 : 0)
                            .animation(.easeIn(duration: 0.3).delay(0.1), value: salutApare)
                    }

                    Spacer()

                    // Status Badge
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.statusProgres.icon)
                            .font(.caption)
                        Text(viewModel.statusProgres.text)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(viewModel.statusProgres.culoare)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.statusProgres.culoare.opacity(0.15), in: Capsule())
                }

                Divider().background(.white.opacity(0.08))

                // MARK: Stats Row
                HStack(spacing: 0) {
                    // Consumate
                    DashboardStat(
                        valoare: "\(Int(viewModel.kcalConsumate))",
                        unitate: "kcal",
                        label: "Consumate",
                        culori: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")]
                    )

                    Divider()
                        .background(.white.opacity(0.1))
                        .frame(height: 36)

                    // Rămase
                    DashboardStat(
                        valoare: "\(Int(viewModel.kcalRamase))",
                        unitate: "kcal",
                        label: "Rămase",
                        culori: viewModel.kcalRamase < 200
                            ? [Color(hex: "#F87171"), Color(hex: "#B91C1C")]
                            : [Color(hex: "#34D399"), Color(hex: "#059669")]
                    )

                    Divider()
                        .background(.white.opacity(0.1))
                        .frame(height: 36)

                    // Target
                    DashboardStat(
                        valoare: "\(Int(viewModel.kcalTinta))",
                        unitate: "kcal",
                        label: "Target Azi",
                        culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.5).delay(0.2)) {
                salutApare = true
            }
        }
    }
}

// MARK: - Stat Element
struct DashboardStat: View {
    let valoare: String
    let unitate: String
    let label: String
    let culori: [Color]

    var body: some View {
        VStack(spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(valoare)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.4), value: valoare)

                Text(unitate)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - HealthKit Stats
struct HealthKitStatsView: View {
    @Bindable var viewModel: DashboardViewModel

    var body: some View {
        GlassCard(cornerRadius: 18, padding: 16, culoareTinta: Color(hex: "#EF4444")) {
            HStack(spacing: 14) {
                // Icon Apple Health
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#F87171"), Color(hex: "#B91C1C")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Apple Health")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Spacer()

                // Stats
                HStack(spacing: 16) {
                    if viewModel.pasi > 0 {
                        HealthStatMini(
                            icon: "figure.walk",
                            valoare: viewModel.pasi > 999
                                ? String(format: "%.1fk", Double(viewModel.pasi) / 1000)
                                : "\(viewModel.pasi)",
                            label: "pași",
                            culoare: Color(hex: "#34D399")
                        )
                    }

                    if viewModel.caloriiArse > 0 {
                        HealthStatMini(
                            icon: "flame.fill",
                            valoare: "\(Int(viewModel.caloriiArse))",
                            label: "kcal",
                            culoare: Color(hex: "#F97316")
                        )
                    }

                    if viewModel.distantaKm > 0 {
                        HealthStatMini(
                            icon: "arrow.triangle.branch",
                            valoare: String(format: "%.1f", viewModel.distantaKm),
                            label: "km",
                            culoare: Color(hex: "#60A5FA")
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Health Stat Mini
struct HealthStatMini: View {
    let icon: String
    let valoare: String
    let label: String
    let culoare: Color

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(culoare)
            Text(valoare)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
    }
}
