// MARK: - DashboardView.swift
// NutriAI Pro — Dashboard-ul zilnic principal
// Platformă: iOS 17+

import SwiftUI
import SwiftData

struct DashboardView: View {

    @Bindable var viewModel: DashboardViewModel
    @Bindable var recipeVM: RecipeViewModel

    @State private var seAfisezaAdaugaMasa: Bool = false
    @State private var slotSelectatPentruAdaugare: SlotMasa = .micDejun
    @State private var seAfisezaApaSheet: Bool = false
    // Faza 3 — Barcode Scanner
    @State private var seAfisezaScanner: Bool = false
    @State private var codScanat: String? = nil
    @State private var seAfisezaRezultatScan: Bool = false
    @State private var eroareScanner: ScannerError? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: Fundal
                Color.black.ignoresSafeArea()

                // Gradient subtil de fundal
                LinearGradient(
                    colors: [
                        Color(hex: "#0F0B1E"),
                        Color.black,
                        Color(hex: "#0B1219")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {

                        // MARK: Header
                        DailySummaryHeaderView(viewModel: viewModel)
                            .padding(.horizontal)

                        // MARK: Inel Central Calorii
                        HStack {
                            Spacer()
                            CentralCaloriesRing(
                                consumate: viewModel.kcalConsumate,
                                tinta: viewModel.kcalTinta,
                                caloriiArse: viewModel.caloriiArse,
                                animat: viewModel.seAnimaRings
                            )
                            Spacer()
                        }
                        .padding(.vertical, 8)

                        // MARK: Ring-uri Macro (scroll orizontal)
                        GlassCard(cornerRadius: 20, padding: 20) {
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Macronutrienți")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("rămase azi")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                HStack(spacing: 0) {
                                    MacroRingCard(
                                        titlu: "Proteine",
                                        consumat: viewModel.proteineConsumate,
                                        tinta: viewModel.profil?.tintaProteine ?? 0,
                                        unitate: "g",
                                        culori: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                        icon: "figure.strengthtraining.traditional",
                                        animat: viewModel.seAnimaRings
                                    )

                                    MacroRingCard(
                                        titlu: "Carbo",
                                        consumat: viewModel.carboConsumate,
                                        tinta: viewModel.profil?.tintaCarbo ?? 0,
                                        unitate: "g",
                                        culori: [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")],
                                        icon: "leaf.fill",
                                        animat: viewModel.seAnimaRings
                                    )

                                    MacroRingCard(
                                        titlu: "Grăsimi",
                                        consumat: viewModel.grasimiConsumate,
                                        tinta: viewModel.profil?.tintaGrasimi ?? 0,
                                        unitate: "g",
                                        culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                        icon: "drop.fill",
                                        animat: viewModel.seAnimaRings
                                    )

                                    MacroRingCard(
                                        titlu: "Apă",
                                        consumat: viewModel.apaConsumataML,
                                        tinta: viewModel.profil?.tintaApa ?? 2500,
                                        unitate: "ml",
                                        culori: [Color(hex: "#38BDF8"), Color(hex: "#0284C7")],
                                        icon: "drop.fill",
                                        animat: viewModel.seAnimaRings
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)

                        // MARK: Tracker Apă Rapid
                        WaterTrackingView(viewModel: viewModel)
                            .padding(.horizontal)

                        // MARK: Statistici HealthKit
                        if viewModel.caloriiArse > 0 || viewModel.pasi > 0 {
                            HealthKitStatsView(viewModel: viewModel)
                                .padding(.horizontal)
                        }

                        // MARK: Sloturi Mese
                        VStack(spacing: 14) {
                            HStack {
                                Text("Mesele de Azi")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(viewModel.textRezumatZi)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)

                            ForEach(SlotMasa.allCases) { slot in
                                MealSlotCardView(
                                    slot: slot,
                                    intrari: viewModel.jurnalAzi?.intrari(pentruSlot: slot) ?? [],
                                    onAdauga: {
                                        slotSelectatPentruAdaugare = slot
                                        seAfisezaAdaugaMasa = true
                                    },
                                    onSterge: { index in
                                        viewModel.stergeIntrare(laIndex: index, dinSlot: slot)
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.sincronizeazaHealthKit()
                }
            }
            .navigationTitle(viewModel.salutPersonalizat)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(viewModel.dataFormatayta)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Buton Sincronizare HealthKit
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.sincronizeazaHealthKit() }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.body)
                            .foregroundStyle(Color(hex: "#818CF8"))
                    }
                }

                // Buton Scanner Barcode
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        seAfisezaScanner = true
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .font(.body)
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
        .sheet(isPresented: $seAfisezaAdaugaMasa) {
            AdaugaLaMasaSheet(
                slot: slotSelectatPentruAdaugare,
                recipeVM: recipeVM,
                dashboardVM: viewModel
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.ultraThinMaterial)
        }
        // MARK: Scanner Barcode (fullscreen camera)
        .fullScreenCover(isPresented: $seAfisezaScanner) {
            BarcodeScannerView(
                onCodDetectat: { cod in
                    codScanat = cod
                    seAfisezaScanner = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        seAfisezaRezultatScan = true
                    }
                },
                onEroare: { eroare in
                    eroareScanner = eroare
                    seAfisezaScanner = false
                },
                onInchide: {
                    seAfisezaScanner = false
                }
            )
            .ignoresSafeArea()
        }
        // MARK: Rezultat Scanare
        .sheet(isPresented: $seAfisezaRezultatScan) {
            if let cod = codScanat {
                BarcodeResultView(
                    barcode: cod,
                    slotImplicit: slotSelectatPentruAdaugare,
                    onAdaugaLaJurnal: { produs, cantitate, slot in
                        let intrare = produs.asIntrare(slot: slot, cantitate: cantitate)
                        viewModel.adaugaIntrareDirecta(intrare)
                    },
                    onSalveazaIngredient: { produs, cantitate in
                        let ingredient = produs.asIngredient(cantitate: cantitate)
                        recipeVM.salveazaIngredientNou(ingredient)
                    },
                    onInchide: {
                        seAfisezaRezultatScan = false
                        codScanat = nil
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
            }
        }
    }
}

// MARK: - Sheet: Adaugă la Masă
struct AdaugaLaMasaSheet: View {
    let slot: SlotMasa
    @Bindable var recipeVM: RecipeViewModel
    @Bindable var dashboardVM: DashboardViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var tabSelectat: Int = 0
    @State private var portiiSelectate: Double = 1.0

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Adaugă la \(slot.rawValue)")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(slot.oraSugerate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()

            // Tab Selector
            HStack(spacing: 0) {
                ForEach(["Rețetele Mele", "Ingrediente"], id: \.self) { tab in
                    let index = tab == "Rețetele Mele" ? 0 : 1
                    Button {
                        withAnimation(.spring(duration: 0.3)) { tabSelectat = index }
                    } label: {
                        Text(tab)
                            .font(.subheadline)
                            .fontWeight(tabSelectat == index ? .semibold : .regular)
                            .foregroundStyle(tabSelectat == index ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background {
                                if tabSelectat == index {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "#4F46E5").opacity(0.6))
                                        .matchedGeometryEffect(id: "tabUnderline", in: .init())
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider().background(.white.opacity(0.08))

            // Conținut Tab
            if tabSelectat == 0 {
                // REȚETE
                if recipeVM.retete.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                        Text("Nicio rețetă salvată")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Mergi la tabul Rețete pentru a crea prima ta rețetă!")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(recipeVM.retete) { reteta in
                                RetetaQuickLogRow(
                                    reteta: reteta,
                                    slot: slot,
                                    onLog: {
                                        recipeVM.logheazaRetetaRapid(reteta, laSlot: slot,
                                                                      portii: portiiSelectate,
                                                                      dashboardVM: dashboardVM)
                                        dismiss()
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            } else {
                // INGREDIENTE
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(BazaDateAlimente.alimente.prefix(20), id: \.id) { ingredient in
                            IngredientQuickRow(ingredient: ingredient, onAdauga: {
                                dashboardVM.adaugaIngredient(ingredient, laSlot: slot)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                dismiss()
                            })
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Rețetă Quick Log Row
struct RetetaQuickLogRow: View {
    let reteta: Reteta
    let slot: SlotMasa
    let onLog: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: slot.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)

                Image(systemName: reteta.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(reteta.nume)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Text("\(Int(reteta.kcalPerPortie)) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text("\(Int(reteta.proteinePerPortie))g P")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#34D399"))
                    Text("\(Int(reteta.carboPerPortie))g C")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#60A5FA"))
                    Text("\(Int(reteta.grasimiPerPortie))g G")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#F59E0B"))
                }
            }

            Spacer()

            // Buton Log
            Button(action: onLog) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(colors: slot.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .pressEffect()
        }
        .padding(12)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Ingredient Quick Row
struct IngredientQuickRow: View {
    let ingredient: Ingredient
    let onAdauga: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(ingredient.categorie.icon)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.nume)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Text("\(Int(ingredient.kcalPer100g)) kcal | \(Int(ingredient.proteinePer100g))g P per 100g")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onAdauga) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color(hex: "#34D399"))
            }
        }
        .padding(10)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
    }
}
