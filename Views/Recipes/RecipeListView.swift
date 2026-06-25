// MARK: - RecipeListView.swift
// NutriAI Pro — Lista de rețete salvate
// Platformă: iOS 17+

import SwiftUI

struct RecipeListView: View {

    @Bindable var viewModel: RecipeViewModel
    @Bindable var dashboardVM: DashboardViewModel

    @State private var seAfisezaBuilder: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: Search Bar
                        HStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                TextField("Caută rețete...", text: $viewModel.textCautareReteta)
                                    .foregroundStyle(.white)
                                if !viewModel.textCautareReteta.isEmpty {
                                    Button {
                                        viewModel.textCautareReteta = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal)

                        // MARK: Filtre Categorie
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                PillButton(
                                    titlu: "Toate",
                                    icon: "square.grid.2x2.fill",
                                    esteSelectat: viewModel.categorieFiltrare == nil,
                                    actiune: { viewModel.categorieFiltrare = nil }
                                )

                                ForEach(CategorieReteta.allCases, id: \.self) { cat in
                                    PillButton(
                                        titlu: cat.rawValue,
                                        icon: cat.icon,
                                        esteSelectat: viewModel.categorieFiltrare == cat,
                                        actiune: {
                                            withAnimation(.spring(duration: 0.3)) {
                                                viewModel.categorieFiltrare = viewModel.categorieFiltrare == cat ? nil : cat
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }

                        // MARK: Stats Summary
                        if !viewModel.retete.isEmpty {
                            RecipeStatsBand(viewModel: viewModel)
                                .padding(.horizontal)
                        }

                        // MARK: Rețete Favorite (dacă există)
                        if !viewModel.reteteFavorite.isEmpty && viewModel.textCautareReteta.isEmpty && viewModel.categorieFiltrare == nil {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Favorite", systemImage: "heart.fill")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.reteteFavorite) { reteta in
                                            RetetaFavoritCard(
                                                reteta: reteta,
                                                onLog: { slot in
                                                    viewModel.logheazaRetetaRapid(reteta, laSlot: slot,
                                                                                   dashboardVM: dashboardVM)
                                                },
                                                onToggleFavorita: {
                                                    viewModel.togglePreferata(reteta)
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        // MARK: Lista Rețete
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(viewModel.textCautareReteta.isEmpty && viewModel.categorieFiltrare == nil
                                     ? "Toate Rețetele (\(viewModel.totalRetete))"
                                     : "Rezultate (\(viewModel.reteteFiltrate.count))")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(.horizontal)

                            if viewModel.reteteFiltrate.isEmpty && !viewModel.retete.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 36))
                                        .foregroundStyle(.secondary)
                                    Text("Nicio rețetă găsită")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    Text("Încearcă o altă căutare sau elimină filtrele")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)

                            } else if viewModel.retete.isEmpty {
                                RetetaGoalaView(onCreare: { seAfisezaBuilder = true })
                                    .padding(.horizontal)

                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.reteteFiltrate) { reteta in
                                        RetetaCardRow(
                                            reteta: reteta,
                                            onLog: { slot in
                                                viewModel.logheazaRetetaRapid(reteta, laSlot: slot,
                                                                               dashboardVM: dashboardVM)
                                            },
                                            onToggleFavorita: { viewModel.togglePreferata(reteta) },
                                            onSterge: { viewModel.stergeReteta(reteta) }
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.top, 12)
                }
                .animation(.spring(duration: 0.4), value: viewModel.reteteFiltrate.count)

                // MARK: Confirmare Toast
                if viewModel.seAfisezaMesajConfirmare, let mesaj = viewModel.mesajConfirmare {
                    VStack {
                        Spacer()
                        ToastView(mesaj: mesaj)
                            .padding(.bottom, 100)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Rețetele Mele")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        seAfisezaBuilder = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
        }
        .sheet(isPresented: $seAfisezaBuilder) {
            RecipeBuilderView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

// MARK: - Card Rețetă în Listă
struct RetetaCardRow: View {
    let reteta: Reteta
    let onLog: (SlotMasa) -> Void
    let onToggleFavorita: () -> Void
    let onSterge: () -> Void

    @State private var seAfisezaLogMenu: Bool = false
    @State private var seAfisezaConfirmareStergere: Bool = false

    var body: some View {
        GlassCard(cornerRadius: 18, padding: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)

                        Image(systemName: reteta.icon)
                            .font(.title3)
                            .foregroundStyle(.white)
                    }

                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(reteta.nume)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            if reteta.estePreferata {
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }

                        HStack(spacing: 6) {
                            Badge(text: reteta.categorie.rawValue,
                                  culori: [Color(hex: "#4F46E5"), Color(hex: "#7C3AED")])

                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(reteta.timpPreparare) min")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Macro Mini
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(reteta.kcalPerPortie))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "#A78BFA"))
                        Text("kcal/porție")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)

                // MARK: Macro Bar
                HStack(spacing: 16) {
                    MicroMacroStat(label: "P", valoare: Int(reteta.proteinePerPortie), unitate: "g",
                                   culoare: Color(hex: "#34D399"))
                    MicroMacroStat(label: "C", valoare: Int(reteta.carboPerPortie), unitate: "g",
                                   culoare: Color(hex: "#60A5FA"))
                    MicroMacroStat(label: "G", valoare: Int(reteta.grasimiPerPortie), unitate: "g",
                                   culoare: Color(hex: "#F59E0B"))

                    Spacer()

                    // Acțiuni
                    HStack(spacing: 8) {
                        Button(action: onToggleFavorita) {
                            Image(systemName: reteta.estePreferata ? "heart.fill" : "heart")
                                .font(.body)
                                .foregroundStyle(reteta.estePreferata ? .red : .secondary)
                        }

                        Button {
                            seAfisezaLogMenu = true
                        } label: {
                            Label("Log", systemImage: "plus.circle.fill")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: Capsule()
                                )
                        }
                        .pressEffect()

                        Button {
                            seAfisezaConfirmareStergere = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.body)
                                .foregroundStyle(.red.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
        .confirmationDialog("Adaugă la Masă", isPresented: $seAfisezaLogMenu, titleVisibility: .visible) {
            ForEach(SlotMasa.allCases) { slot in
                Button(slot.rawValue) { onLog(slot) }
            }
            Button("Anulează", role: .cancel) {}
        }
        .alert("Sterge Rețeta", isPresented: $seAfisezaConfirmareStergere) {
            Button("Anulează", role: .cancel) {}
            Button("Șterge", role: .destructive) { onSterge() }
        } message: {
            Text("Ești sigur că vrei să ștergi rețeta \"\(reteta.nume)\"?")
        }
    }
}

// MARK: - Micro Macro Stat
struct MicroMacroStat: View {
    let label: String
    let valoare: Int
    let unitate: String
    let culoare: Color

    var body: some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(culoare)
            Text("\(valoare)\(unitate)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Card Favorit (horizontal scroll)
struct RetetaFavoritCard: View {
    let reteta: Reteta
    let onLog: (SlotMasa) -> Void
    let onToggleFavorita: () -> Void

    @State private var seAfisezaLogMenu: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: reteta.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            Text(reteta.nume)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(2)
                .frame(width: 100)

            Text("\(Int(reteta.kcalPerPortie)) kcal")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button {
                seAfisezaLogMenu = true
            } label: {
                Text("Adaugă")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                       startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
            }
        }
        .padding(14)
        .frame(width: 130)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color(hex: "#818CF8").opacity(0.3), lineWidth: 1)
        )
        .confirmationDialog("Adaugă \(reteta.nume) la:", isPresented: $seAfisezaLogMenu, titleVisibility: .visible) {
            ForEach(SlotMasa.allCases) { slot in
                Button(slot.rawValue) { onLog(slot) }
            }
            Button("Anulează", role: .cancel) {}
        }
    }
}

// MARK: - Placeholder când nu există rețete
struct RetetaGoalaView: View {
    let onCreare: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                Text("Nicio Rețetă Salvată")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Creează prima ta rețetă personalizată și logg-o cu un singur tap!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onCreare) {
                Label("Creează Prima Rețetă", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: Color(hex: "#059669").opacity(0.5), radius: 12, x: 0, y: 6)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Stats Band Rețete
struct RecipeStatsBand: View {
    let viewModel: RecipeViewModel

    var body: some View {
        HStack(spacing: 0) {
            RecipeStat(valoare: "\(viewModel.totalRetete)", label: "Rețete", icon: "fork.knife.circle.fill",
                       culori: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")])

            Divider().background(.white.opacity(0.08)).frame(height: 30)

            RecipeStat(valoare: "\(viewModel.reteteFavorite.count)", label: "Favorite", icon: "heart.fill",
                       culori: [Color(hex: "#F87171"), Color(hex: "#B91C1C")])

            Divider().background(.white.opacity(0.08)).frame(height: 30)

            RecipeStat(valoare: "\(viewModel.reteteDupaTip.keys.count)", label: "Categorii", icon: "square.grid.2x2.fill",
                       culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")])
        }
        .padding(14)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct RecipeStat: View {
    let valoare: String
    let label: String
    let icon: String
    let culori: [Color]

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(alignment: .leading, spacing: 1) {
                Text(valoare)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Toast View
struct ToastView: View {
    let mesaj: String

    var body: some View {
        Text(mesaj)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                .ultraThinMaterial,
                in: Capsule()
            )
            .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 1))
            .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
    }
}
