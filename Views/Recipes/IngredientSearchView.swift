// MARK: - IngredientSearchView.swift
// NutriAI Pro — Căutare și selecție ingredient
// Platformă: iOS 17+

import SwiftUI

struct IngredientSearchView: View {

    @Bindable var viewModel: RecipeViewModel
    @Environment(\.dismiss) private var dismiss

    let onAdauga: (Ingredient, Double) -> Void

    @State private var ingredientSelectat: Ingredient? = nil
    @State private var cantitateSelectata: Double = 100
    @State private var seAfisezaConfirmare: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Search
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Caută ingredient...", text: $viewModel.textCautareIngredient)
                            .foregroundStyle(.white)
                        if !viewModel.textCautareIngredient.isEmpty {
                            Button { viewModel.textCautareIngredient = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    .padding()

                    // MARK: Filtre Categorie
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            PillButton(
                                titlu: "Toate",
                                esteSelectat: viewModel.categorieCautareIngredient == nil,
                                actiune: { viewModel.categorieCautareIngredient = nil }
                            )
                            ForEach(CategorieIngredient.allCases, id: \.self) { cat in
                                PillButton(
                                    titlu: cat.rawValue,
                                    icon: cat.icon,
                                    esteSelectat: viewModel.categorieCautareIngredient == cat,
                                    actiune: {
                                        withAnimation {
                                            viewModel.categorieCautareIngredient = viewModel.categorieCautareIngredient == cat ? nil : cat
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)

                    Divider().background(.white.opacity(0.08))

                    // MARK: Lista Ingrediente
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.ingredienteFiltrate, id: \.id) { ingredient in
                                IngredientSelectieRow(
                                    ingredient: ingredient,
                                    esteSelectat: ingredientSelectat?.id == ingredient.id,
                                    onSelectat: {
                                        withAnimation(.spring(duration: 0.3)) {
                                            if ingredientSelectat?.id == ingredient.id {
                                                ingredientSelectat = nil
                                            } else {
                                                ingredientSelectat = ingredient
                                                cantitateSelectata = 100
                                            }
                                        }
                                        UISelectionFeedbackGenerator().selectionChanged()
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // MARK: Panel Confirmare (dacă ingredient selectat)
                    if let ingredient = ingredientSelectat {
                        IngredientConfirmPanel(
                            ingredient: ingredient,
                            cantitate: $cantitateSelectata,
                            onAdauga: {
                                onAdauga(ingredient, cantitateSelectata)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                dismiss()
                            },
                            onAnuleaza: {
                                withAnimation { ingredientSelectat = nil }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Alege Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Închide") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Rând Ingredient Selectabil
struct IngredientSelectieRow: View {
    let ingredient: Ingredient
    let esteSelectat: Bool
    let onSelectat: () -> Void

    var body: some View {
        Button(action: onSelectat) {
            HStack(spacing: 14) {
                // Categorie Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            esteSelectat
                            ? LinearGradient(colors: [Color(hex: "#34D399"), Color(hex: "#059669")],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.1)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: ingredient.categorie.icon)
                        .font(.body)
                        .foregroundStyle(esteSelectat ? .white : .secondary)
                }

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(ingredient.nume)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text("\(Int(ingredient.kcalPer100g)) kcal")
                            .foregroundStyle(.secondary)
                        Text("P:\(Int(ingredient.proteinePer100g))g")
                            .foregroundStyle(Color(hex: "#34D399").opacity(0.8))
                        Text("C:\(Int(ingredient.carboPer100g))g")
                            .foregroundStyle(Color(hex: "#60A5FA").opacity(0.8))
                        Text("G:\(Int(ingredient.grasimiPer100g))g")
                            .foregroundStyle(Color(hex: "#F59E0B").opacity(0.8))
                    }
                    .font(.caption2)
                }

                Spacer()

                // Checkmark
                if esteSelectat {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color(hex: "#34D399"))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(12)
            .background(
                esteSelectat
                ? Color(hex: "#059669").opacity(0.12)
                : Color.white.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        esteSelectat ? Color(hex: "#34D399").opacity(0.4) : Color.white.opacity(0.06),
                        lineWidth: esteSelectat ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.3), value: esteSelectat)
    }
}

// MARK: - Panel Confirmare Cantitate
struct IngredientConfirmPanel: View {
    let ingredient: Ingredient
    @Binding var cantitate: Double
    let onAdauga: () -> Void
    let onAnuleaza: () -> Void

    var kcalCalculate: Double { ingredient.kcalPer100g * cantitate / 100 }
    var proteineCalculate: Double { ingredient.proteinePer100g * cantitate / 100 }
    var carboCalculate: Double { ingredient.carboPer100g * cantitate / 100 }
    var grasimiCalculate: Double { ingredient.grasimiPer100g * cantitate / 100 }

    var body: some View {
        VStack(spacing: 16) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(.secondary.opacity(0.5))
                .frame(width: 36, height: 4)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ingredient.nume)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text(ingredient.categorie.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onAnuleaza) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: Slider Cantitate
            VStack(spacing: 8) {
                HStack {
                    Text("Cantitate")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(cantitate)) g")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "#34D399"))
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.2), value: cantitate)
                }

                Slider(value: $cantitate, in: 5...500, step: 5)
                    .tint(Color(hex: "#34D399"))

                // Butoane rapide cantitate
                HStack(spacing: 8) {
                    ForEach([25, 50, 100, 150, 200], id: \.self) { gram in
                        Button {
                            withAnimation(.spring(duration: 0.2)) { cantitate = Double(gram) }
                        } label: {
                            Text("\(gram)g")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(cantitate == Double(gram) ? .white : .secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    cantitate == Double(gram)
                                    ? Color(hex: "#34D399").opacity(0.4)
                                    : Color.white.opacity(0.08),
                                    in: Capsule()
                                )
                        }
                    }
                }
            }

            // MARK: Preview Macro Calculat
            HStack(spacing: 0) {
                ConfirmMacroCell(label: "kcal", valoare: Int(kcalCalculate), culoare: Color(hex: "#A78BFA"))
                ConfirmMacroCell(label: "Proteine", valoare: Int(proteineCalculate), culoare: Color(hex: "#34D399"))
                ConfirmMacroCell(label: "Carbo", valoare: Int(carboCalculate), culoare: Color(hex: "#60A5FA"))
                ConfirmMacroCell(label: "Grăsimi", valoare: Int(grasimiCalculate), culoare: Color(hex: "#F59E0B"))
            }
            .padding(12)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))

            // MARK: Buton Adaugă
            Button(action: onAdauga) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Adaugă \(Int(cantitate))g \(ingredient.nume)")
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .fontWeight(.bold)
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
                .shadow(color: Color(hex: "#059669").opacity(0.5), radius: 10, x: 0, y: 5)
            }
            .pressEffect()
        }
        .padding(20)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 24)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: -10)
    }
}

struct ConfirmMacroCell: View {
    let label: String
    let valoare: Int
    let culoare: Color

    var body: some View {
        VStack(spacing: 3) {
            Text("\(valoare)")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(culoare)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
