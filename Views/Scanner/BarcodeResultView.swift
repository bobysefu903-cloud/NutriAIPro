// MARK: - BarcodeResultView.swift
// NutriAI Pro — Sheet cu rezultatul scanării + logare instant
// Faza 3 | iOS 26 Liquid Glass + fallback iOS 17+

import SwiftUI

// MARK: - BarcodeResultView
/// Sheet prezentat după scanarea cu succes — afișează produsul și permite logarea
struct BarcodeResultView: View {

    // MARK: - Input
    let barcode: String
    let slotImplicit: SlotMasa?

    // MARK: - Callbacks
    var onAdaugaLaJurnal: (ScannedProduct, Double, SlotMasa) -> Void
    var onSalveazaIngredient: (ScannedProduct, Double) -> Void
    var onInchide: () -> Void

    // MARK: - State
    @State private var stare: StareFetch = .seIncarca
    @State private var produs: ScannedProduct? = nil
    @State private var eroare: ScannerError? = nil
    @State private var cantitateGrame: Double = 100
    @State private var slotSelectat: SlotMasa = .pranz
    @State private var seAfisezaSlotPicker: Bool = false
    @State private var seAfisezaConfirmareLog: Bool = false
    @State private var seAfisezaToast: Bool = false
    @State private var mesajToast: String = ""

    // MARK: - Stări Fetch
    enum StareFetch {
        case seIncarca
        case succes
        case eroare
    }

    var body: some View {
        ZStack {
            // Fundal
            Color.black.opacity(0.01)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle drag indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(.secondary.opacity(0.5))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // MARK: Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Produs Scanat")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text(barcode)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospaced()
                    }
                    Spacer()
                    Button(action: onInchide) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                Divider().background(.white.opacity(0.08))

                // MARK: Conținut principal
                ScrollView {
                    VStack(spacing: 20) {
                        switch stare {
                        case .seIncarca:
                            LoadingProductView()
                        case .succes:
                            if let produs {
                                ProductSuccessView(
                                    produs: produs,
                                    cantitateGrame: $cantitateGrame
                                )
                            }
                        case .eroare:
                            ErrorProductView(
                                eroare: eroare,
                                barcode: barcode,
                                onRetry: { Task { await incarcaProdus() } },
                                onInchide: onInchide
                            )
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }

                // MARK: Action Buttons (vizibile doar la succes)
                if stare == .succes, let produs {
                    Divider().background(.white.opacity(0.08))

                    VStack(spacing: 12) {

                        // MARK: Preview Macro Calculat
                        MacroCalculatPreview(produs: produs, cantitate: cantitateGrame)

                        // MARK: Buton Adaugă la Masă
                        Button {
                            seAfisezaConfirmareLog = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Adaugă la \(slotSelectat.rawValue)")
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background {
                                if #available(iOS 26, *) {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .glassEffect(.regular.tinted(Color(hex: "#34D399")))
                                } else {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color(hex: "#059669").opacity(0.5), radius: 14, x: 0, y: 6)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        // MARK: Butoane Secundare
                        HStack(spacing: 12) {
                            // Schimbă slot
                            Button {
                                seAfisezaSlotPicker = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: slotSelectat.icon)
                                    Text(slotSelectat.rawValue)
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "#818CF8"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(hex: "#4F46E5").opacity(0.15), in: Capsule())
                                .overlay(Capsule().strokeBorder(Color(hex: "#818CF8").opacity(0.3), lineWidth: 1))
                            }

                            Spacer()

                            // Salvează ca Ingredient
                            Button {
                                onSalveazaIngredient(produs, cantitateGrame)
                                mesajToast = "✅ Ingredient salvat!"
                                withAnimation { seAfisezaToast = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { seAfisezaToast = false }
                                    onInchide()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "bookmark.fill")
                                    Text("Salvează Ingredient")
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(.white.opacity(0.08), in: Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }

            // MARK: Toast
            if seAfisezaToast {
                VStack {
                    Spacer()
                    ToastView(mesaj: mesajToast)
                        .padding(.bottom, 120)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .task {
            await incarcaProdus()
        }
        .onAppear {
            slotSelectat = slotImplicit ?? .pranz
        }
        .confirmationDialog(
            "Adaugă \(Int(cantitateGrame))g la Masa:",
            isPresented: $seAfisezaConfirmareLog,
            titleVisibility: .visible
        ) {
            ForEach(SlotMasa.allCases) { slot in
                Button(slot.rawValue) {
                    slotSelectat = slot
                    if let produs {
                        onAdaugaLaJurnal(produs, cantitateGrame, slot)
                        mesajToast = "✅ Adăugat la \(slot.rawValue)!"
                        withAnimation { seAfisezaToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            onInchide()
                        }
                    }
                }
            }
            Button("Anulează", role: .cancel) {}
        }
        .confirmationDialog(
            "Alege Masa",
            isPresented: $seAfisezaSlotPicker,
            titleVisibility: .visible
        ) {
            ForEach(SlotMasa.allCases) { slot in
                Button(slot.rawValue) { slotSelectat = slot }
            }
            Button("Anulează", role: .cancel) {}
        }
    }

    // MARK: - Fetch Produs
    private func incarcaProdus() async {
        stare = .seIncarca
        eroare = nil

        do {
            let rezultat = try await FoodDatabaseService.shared.cautaProdus(barcode: barcode)
            await MainActor.run {
                produs = rezultat
                // Dacă produsul are o porție specificată, o folosim implicit
                if let portieCantitate = rezultat.cantitateGramePorţie {
                    cantitateGrame = min(portieCantitate, 500)
                }
                stare = .succes
            }
        } catch let err as ScannerError {
            await MainActor.run {
                eroare = err
                stare = .eroare
            }
        } catch {
            await MainActor.run {
                eroare = .rețeaIndisponibilă
                stare = .eroare
            }
        }
    }
}

// MARK: - Loading State View
struct LoadingProductView: View {
    @State private var rotatie: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color(hex: "#818CF8").opacity(0.2), lineWidth: 3)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#818CF8"), Color(hex: "#34D399")],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotatie))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotatie)

                Image(systemName: "barcode.viewfinder")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "#818CF8"))
            }

            VStack(spacing: 8) {
                Text("Se caută produsul...")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Se conectează la Open Food Facts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Shimmer placeholder
            VStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.08))
                    .frame(height: 20)
                    .shimmer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.06))
                    .frame(height: 14)
                    .shimmer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.04))
                    .frame(height: 14)
                    .frame(maxWidth: .infinity * 0.6)
                    .shimmer()
            }
            .padding(.horizontal, 40)
        }
        .padding(40)
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotatie = 360
            }
        }
    }
}

// MARK: - Success State View
struct ProductSuccessView: View {
    let produs: ScannedProduct
    @Binding var cantitateGrame: Double

    var body: some View {
        VStack(spacing: 20) {
            // MARK: Header produs
            VStack(spacing: 12) {
                // Icon produs (sau imagine dacă există)
                ZStack {
                    if #available(iOS 26, *) {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .glassEffect()
                            .frame(width: 80, height: 80)
                    } else {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                    }

                    Image(systemName: "cart.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 6) {
                    Text(produs.numeProdus)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    if !produs.brand.isEmpty {
                        Text(produs.brand)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Barcode
                    Text(produs.barcode)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.06), in: Capsule())
                }
            }
            .padding(.horizontal, 20)

            // MARK: Tabel Macro per 100g
            MacroTabelPer100g(produs: produs)
                .padding(.horizontal, 20)

            // MARK: Selector Cantitate
            CantitateSelector(
                produs: produs,
                cantitate: $cantitateGrame
            )
            .padding(.horizontal, 20)

            // MARK: Nutrienți Bonus (fibre, zahăr)
            if produs.fibrePer100g > 0 || produs.zaharPer100g > 0 {
                NutrientiBonusView(produs: produs, cantitate: cantitateGrame)
                    .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Tabel Macro per 100g
struct MacroTabelPer100g: View {
    let produs: ScannedProduct

    let macros: [(String, String, [Color], String)] = []

    var body: some View {
        GlassCard(cornerRadius: 16, padding: 16) {
            VStack(spacing: 12) {
                HStack {
                    Text("Valori Nutriționale")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("per 100g")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider().background(.white.opacity(0.08))

                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {
                    GridRow {
                        MacroGridCell(label: "Calorii", valoare: produs.kcalPer100g, unitate: "kcal",
                                      culori: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")])
                        MacroGridCell(label: "Proteine", valoare: produs.proteinePer100g, unitate: "g",
                                      culori: [Color(hex: "#34D399"), Color(hex: "#059669")])
                    }
                    GridRow {
                        MacroGridCell(label: "Carbohidrați", valoare: produs.carboPer100g, unitate: "g",
                                      culori: [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")])
                        MacroGridCell(label: "Grăsimi", valoare: produs.grasimiPer100g, unitate: "g",
                                      culori: [Color(hex: "#F59E0B"), Color(hex: "#D97706")])
                    }
                }
            }
        }
    }
}

// MARK: - Celulă Macro în Grid
struct MacroGridCell: View {
    let label: String
    let valoare: Double
    let unitate: String
    let culori: [Color]

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(String(format: "%.1f", valoare))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(unitate)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(culori.first?.opacity(0.1) ?? .clear, in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Selector Cantitate
struct CantitateSelector: View {
    let produs: ScannedProduct
    @Binding var cantitate: Double

    let cantitatiRapide: [(String, Double)] = [
        ("50g", 50), ("100g", 100), ("150g", 150), ("200g", 200), ("250g", 250)
    ]

    var body: some View {
        GlassCard(cornerRadius: 16, padding: 16) {
            VStack(spacing: 12) {
                HStack {
                    Text("Cantitate")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(Int(cantitate)) g")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundStyle(Color(hex: "#34D399"))
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.2), value: cantitate)
                }

                // Dacă există porție specificată pe produs
                if let porţie = produs.marimePorţie {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Porție recomandată: \(porţie)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Slider
                Slider(value: $cantitate, in: 5...500, step: 5)
                    .tint(Color(hex: "#34D399"))

                // Butoane rapide
                HStack(spacing: 6) {
                    ForEach(cantitatiRapide, id: \.1) { (label, val) in
                        Button {
                            withAnimation(.spring(duration: 0.2)) { cantitate = val }
                        } label: {
                            Text(label)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(cantitate == val ? .white : .secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    cantitate == val
                                    ? Color(hex: "#34D399").opacity(0.35)
                                    : Color.white.opacity(0.07),
                                    in: Capsule()
                                )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview Macro Calculat (în action bar)
struct MacroCalculatPreview: View {
    let produs: ScannedProduct
    let cantitate: Double

    var body: some View {
        HStack(spacing: 0) {
            MiniCalcCell(label: "kcal", valoare: produs.kcal(pentruGrame: cantitate),
                         culoare: Color(hex: "#A78BFA"))
            MiniCalcCell(label: "P", valoare: produs.proteine(pentruGrame: cantitate),
                         culoare: Color(hex: "#34D399"))
            MiniCalcCell(label: "C", valoare: produs.carbo(pentruGrame: cantitate),
                         culoare: Color(hex: "#60A5FA"))
            MiniCalcCell(label: "G", valoare: produs.grasimi(pentruGrame: cantitate),
                         culoare: Color(hex: "#F59E0B"))
        }
        .padding(10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct MiniCalcCell: View {
    let label: String
    let valoare: Double
    let culoare: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.0f", valoare))
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(culoare)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.3), value: valoare)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Nutrienți Bonus
struct NutrientiBonusView: View {
    let produs: ScannedProduct
    let cantitate: Double

    var body: some View {
        HStack(spacing: 12) {
            if produs.fibrePer100g > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Text("Fibre: \(String(format: "%.1f", produs.fibrePer100g * cantitate / 100))g")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if produs.zaharPer100g > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "cube.fill")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#F59E0B"))
                    Text("Zahăr: \(String(format: "%.1f", produs.zaharPer100g * cantitate / 100))g")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Error State View
struct ErrorProductView: View {
    let eroare: ScannerError?
    let barcode: String
    let onRetry: () -> Void
    let onInchide: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 10) {
                Text("Produs Negăsit")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(eroare?.errorDescriptionRomana ?? "Codul de bare nu a putut fi identificat în baza de date.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            VStack(spacing: 12) {
                Button(action: onRetry) {
                    Label("Încearcă din Nou", systemImage: "arrow.clockwise")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                }

                Button(action: onInchide) {
                    Text("Scanează Alt Produs")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 30)

            // Notă informativă
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Produsele din România pot fi uneori absente din Open Food Facts. Poți adăuga manual ingredientul.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
        }
        .padding(20)
    }
}
