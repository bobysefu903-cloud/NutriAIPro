// MARK: - RecipeBuilderView.swift
// NutriAI Pro — Constructor rețetă pas cu pas
// Platformă: iOS 17+

import SwiftUI

struct RecipeBuilderView: View {

    @Bindable var viewModel: RecipeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var paginaCurenta: Int = 0
    @State private var seAfisezaCautare: Bool = false
    // Faza 3 — Barcode Scanner în Builder
    @State private var seAfisezaScannerBuilder: Bool = false
    @State private var codScanatBuilder: String? = nil
    @State private var seAfisezaRezultatScanBuilder: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Progress indicator
                    HStack(spacing: 6) {
                        ForEach(0..<3) { i in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(i <= paginaCurenta
                                      ? LinearGradient(
                                          colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                          startPoint: .leading, endPoint: .trailing
                                        )
                                      : LinearGradient(colors: [Color.white.opacity(0.15)],
                                                       startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(height: 4)
                                .animation(.spring(duration: 0.4), value: paginaCurenta)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    TabView(selection: $paginaCurenta) {

                        // MARK: Pagina 0 — Info Generală
                        BuilderPage0(viewModel: viewModel)
                            .tag(0)

                        // MARK: Pagina 1 — Ingrediente
                        BuilderPage1(
                            viewModel: viewModel,
                            seAfisezaCautare: $seAfisezaCautare,
                            seAfisezaScannerBuilder: $seAfisezaScannerBuilder
                        )
                            .tag(1)

                        // MARK: Pagina 2 — Rezumat & Salvare
                        BuilderPage2(viewModel: viewModel, onSalvare: {
                            viewModel.salveazaRetetaNoua()
                            if !viewModel.seAfisezaEroare {
                                dismiss()
                            }
                        })
                        .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: paginaCurenta)

                    // MARK: Navigare
                    HStack(spacing: 14) {
                        if paginaCurenta > 0 {
                            Button {
                                withAnimation { paginaCurenta -= 1 }
                            } label: {
                                Image(systemName: "arrow.left")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 50, height: 50)
                                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                            }
                        }

                        if paginaCurenta < 2 {
                            Button {
                                withAnimation { paginaCurenta += 1 }
                            } label: {
                                HStack(spacing: 8) {
                                    Text(paginaCurenta == 0 ? "Adaugă Ingrediente" : "Rezumat")
                                        .fontWeight(.bold)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
                            }
                            .disabled(paginaCurenta == 0 && viewModel.retetaNoua.nume.isEmpty)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Rețetă Nouă")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anulează") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        .alert("Eroare", isPresented: $viewModel.seAfisezaEroare) {
            Button("OK") { viewModel.seAfisezaEroare = false }
        } message: {
            Text(viewModel.mesajEroare)
        }
        .sheet(isPresented: $seAfisezaCautare) {
            IngredientSearchView(
                viewModel: viewModel,
                onAdauga: { ingredient, cantitate in
                    viewModel.retetaNoua.adaugaIngredient(ingredient, cantitate: cantitate)
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        // MARK: Scanner Barcode în Builder
        .fullScreenCover(isPresented: $seAfisezaScannerBuilder) {
            BarcodeScannerView(
                onCodDetectat: { cod in
                    codScanatBuilder = cod
                    seAfisezaScannerBuilder = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        seAfisezaRezultatScanBuilder = true
                    }
                },
                onEroare: { _ in seAfisezaScannerBuilder = false },
                onInchide: { seAfisezaScannerBuilder = false }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $seAfisezaRezultatScanBuilder) {
            if let cod = codScanatBuilder {
                BarcodeResultView(
                    barcode: cod,
                    slotImplicit: nil,
                    onAdaugaLaJurnal: { _, _, _ in },  // N/A în context Builder
                    onSalveazaIngredient: { produs, cantitate in
                        let ingredient = produs.asIngredient(cantitate: cantitate)
                        viewModel.retetaNoua.adaugaIngredient(ingredient, cantitate: cantitate)
                        seAfisezaRezultatScanBuilder = false
                        codScanatBuilder = nil
                    },
                    onInchide: {
                        seAfisezaRezultatScanBuilder = false
                        codScanatBuilder = nil
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
            }
        }
    }
}

// MARK: - Pagina 0: Info Generală
struct BuilderPage0: View {
    @Bindable var viewModel: RecipeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Text("Informații Generale")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .padding(.top, 20)

                // Câmp Nume
                VStack(alignment: .leading, spacing: 8) {
                    Label("Numele Rețetei *", systemImage: "textformat")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    TextField("ex: Pui cu Orez și Legume", text: $viewModel.retetaNoua.nume)
                        .textFieldStyle(NutriTextFieldStyle())
                }

                // Câmp Descriere
                VStack(alignment: .leading, spacing: 8) {
                    Label("Descriere", systemImage: "text.alignleft")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    TextField("Adaugă o scurtă descriere...", text: $viewModel.retetaNoua.descriere, axis: .vertical)
                        .lineLimit(3...5)
                        .textFieldStyle(NutriTextFieldStyle())
                }

                // Categorie
                VStack(alignment: .leading, spacing: 10) {
                    Label("Categorie", systemImage: "tag.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(CategorieReteta.allCases, id: \.self) { cat in
                            Button {
                                withAnimation(.spring(duration: 0.3)) {
                                    viewModel.retetaNoua.categorie = cat
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: cat.icon)
                                        .font(.body)
                                    Text(cat.rawValue)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    if viewModel.retetaNoua.categorie == cat {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(Color(hex: "#34D399"))
                                    }
                                }
                                .foregroundStyle(viewModel.retetaNoua.categorie == cat ? .white : .secondary)
                                .padding(12)
                                .background(
                                    viewModel.retetaNoua.categorie == cat
                                    ? Color(hex: "#059669").opacity(0.2)
                                    : Color.white.opacity(0.06),
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            viewModel.retetaNoua.categorie == cat
                                            ? Color(hex: "#34D399").opacity(0.5)
                                            : Color.white.opacity(0.08),
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Porții & Timp
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Porții", systemImage: "person.2.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        Stepper("\(viewModel.retetaNoua.numarPortii) porții",
                                value: $viewModel.retetaNoua.numarPortii,
                                in: 1...20)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Timp (min)", systemImage: "clock.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        Stepper("\(viewModel.retetaNoua.timpPreparare) min",
                                value: $viewModel.retetaNoua.timpPreparare,
                                in: 5...240,
                                step: 5)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

// MARK: - Pagina 1: Ingrediente
struct BuilderPage1: View {
    @Bindable var viewModel: RecipeViewModel
    @Binding var seAfisezaCautare: Bool
    @Binding var seAfisezaScannerBuilder: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Ingrediente")
                .font(.title2)
                .fontWeight(.black)
                .foregroundStyle(.white)
                .padding(.top, 20)

            // MARK: Live Macro Preview
            if !viewModel.retetaNoua.ingredienteAdaugate.isEmpty {
                LiveMacroPreview(builder: viewModel.retetaNoua)
                    .padding(.horizontal, 20)
            }

            // MARK: Lista ingrediente adăugate
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(viewModel.retetaNoua.ingredienteAdaugate.enumerated()), id: \.element.id) { index, ingredient in
                        IngredientAdaugatRow(
                            ingredient: ingredient,
                            onSterge: { viewModel.retetaNoua.stergeIngredient(laIndex: index) },
                            onCantitateChange: { cantitate in
                                viewModel.retetaNoua.actualizeazaCantitate(laIndex: index, cantitate: cantitate)
                            }
                        )
                        .padding(.horizontal, 20)
                    }

                    // Butoane Adaugă Ingredient
                    HStack(spacing: 10) {
                        // Caută în baza de date locală
                        Button {
                            seAfisezaCautare = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.body)
                                Text("Caută Ingredient")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(Color(hex: "#34D399"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(hex: "#059669").opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color(hex: "#34D399").opacity(0.3), lineWidth: 1)
                            )
                        }

                        // Scanează cod de bare (Faza 3)
                        Button {
                            seAfisezaScannerBuilder = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.body)
                                Text("Scanează")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(Color(hex: "#818CF8"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .background(Color(hex: "#4F46E5").opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color(hex: "#818CF8").opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                }
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Pagina 2: Rezumat & Salvare
struct BuilderPage2: View {
    let viewModel: RecipeViewModel
    let onSalvare: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Rezumat Rețetă")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .padding(.top, 20)

                // Info card
                GlassCard(cornerRadius: 18, padding: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: viewModel.retetaNoua.categorie.icon)
                                .font(.title2)
                                .foregroundStyle(Color(hex: "#34D399"))
                            VStack(alignment: .leading) {
                                Text(viewModel.retetaNoua.nume.isEmpty ? "Fără Nume" : viewModel.retetaNoua.nume)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Text(viewModel.retetaNoua.categorie.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(viewModel.retetaNoua.numarPortii) porții")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(viewModel.retetaNoua.timpPreparare) min")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider().background(.white.opacity(0.1))

                        Text("Macro per porție:")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 0) {
                            MacroSummaryCell(label: "Calorii", valoare: Int(viewModel.retetaNoua.kcalPerPortie), unitate: "kcal",
                                            culori: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")])
                            MacroSummaryCell(label: "Proteine", valoare: Int(viewModel.retetaNoua.proteinePerPortie), unitate: "g",
                                            culori: [Color(hex: "#34D399"), Color(hex: "#059669")])
                            MacroSummaryCell(label: "Carbo", valoare: Int(viewModel.retetaNoua.carboPerPortie), unitate: "g",
                                            culori: [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")])
                            MacroSummaryCell(label: "Grăsimi", valoare: Int(viewModel.retetaNoua.grasimiPerPortie), unitate: "g",
                                            culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")])
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Lista ingrediente finale
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(viewModel.retetaNoua.ingredienteAdaugate.count) Ingrediente")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)

                    ForEach(viewModel.retetaNoua.ingredienteAdaugate, id: \.id) { ingredient in
                        HStack {
                            Text(ingredient.nume)
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(Int(ingredient.cantitateGrame))g")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("| \(Int(ingredient.kcalTotal)) kcal")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "#A78BFA"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 20)
                    }
                }

                // Buton Salvare
                Button(action: onSalvare) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("Salvează Rețeta")
                            .fontWeight(.black)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .shadow(color: Color(hex: "#059669").opacity(0.5), radius: 16, x: 0, y: 8)
                }
                .disabled(viewModel.retetaNoua.ingredienteAdaugate.isEmpty || viewModel.retetaNoua.nume.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Live Macro Preview
struct LiveMacroPreview: View {
    let builder: RetetaBuilder

    var body: some View {
        HStack(spacing: 0) {
            MacroSummaryCell(label: "Calorii", valoare: Int(builder.kcalPerPortie), unitate: "kcal",
                            culori: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")])
            MacroSummaryCell(label: "Proteine", valoare: Int(builder.proteinePerPortie), unitate: "g",
                            culori: [Color(hex: "#34D399"), Color(hex: "#059669")])
            MacroSummaryCell(label: "Carbo", valoare: Int(builder.carboPerPortie), unitate: "g",
                            culori: [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")])
            MacroSummaryCell(label: "Grăsimi", valoare: Int(builder.grasimiPerPortie), unitate: "g",
                            culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")])
        }
        .padding(12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct MacroSummaryCell: View {
    let label: String
    let valoare: Int
    let unitate: String
    let culori: [Color]

    var body: some View {
        VStack(spacing: 3) {
            Text("\(valoare)")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing))
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.3), value: valoare)
            Text(unitate)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Rând Ingredient Adăugat (cu slider cantitate)
struct IngredientAdaugatRow: View {
    let ingredient: Ingredient
    let onSterge: () -> Void
    let onCantitateChange: (Double) -> Void

    @State private var cantitate: Double

    init(ingredient: Ingredient, onSterge: @escaping () -> Void, onCantitateChange: @escaping (Double) -> Void) {
        self.ingredient = ingredient
        self.onSterge = onSterge
        self.onCantitateChange = onCantitateChange
        self._cantitate = State(initialValue: ingredient.cantitateGrame)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: ingredient.categorie.icon)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ingredient.nume)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                    Text("\(Int(ingredient.kcalPer100g)) kcal / 100g")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(cantitate))g")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#34D399"))
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.2), value: cantitate)

                Button(action: onSterge) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red.opacity(0.6))
                }
            }

            // Slider cantitate
            Slider(value: $cantitate, in: 5...500, step: 5)
                .tint(Color(hex: "#34D399"))
                .onChange(of: cantitate) { _, noua in
                    onCantitateChange(noua)
                }
        }
        .padding(12)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
    }
}
