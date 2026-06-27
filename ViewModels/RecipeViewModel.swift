// MARK: - RecipeViewModel.swift
// NutriAI Pro — ViewModel pentru rețete și baza de date alimente
// Platformă: iOS 17+ | MVVM | SwiftData

import Foundation
import SwiftUI
import SwiftData

// MARK: - ViewModel Rețete
@Observable
final class RecipeViewModel {

    // MARK: - Referință Context
    private var modelContext: ModelContext?

    // MARK: - Rețete
    var retete: [Reteta] = []
    var reteteFiltrate: [Reteta] = []
    var textCautareReteta: String = "" {
        didSet { filtreazaRetete() }
    }
    var categorieFiltrare: CategorieReteta? = nil {
        didSet { filtreazaRetete() }
    }

    // MARK: - Builder Rețetă
    var retetaNoua: RetetaBuilder = RetetaBuilder()
    var seAfisezaBuilderReteta: Bool = false
    var seAfisezaCautareIngredient: Bool = false
    var retetaSelectata: Reteta? = nil
    var seAfisezaDetaliiReteta: Bool = false

    // MARK: - Ingrediente Disponibile
    var toateIngredientele: [Ingredient] = BazaDateAlimente.alimente
    var ingredienteFiltrate: [Ingredient] = BazaDateAlimente.alimente
    var textCautareIngredient: String = "" {
        didSet { filtreazaIngrediente() }
    }
    var categorieCautareIngredient: CategorieIngredient? = nil {
        didSet { filtreazaIngrediente() }
    }

    // MARK: - Stare UI
    var mesajConfirmare: String? = nil
    var seAfisezaMesajConfirmare: Bool = false
    var seAfisezaEroare: Bool = false
    var mesajEroare: String = ""

    // MARK: - Slot pentru log rapid
    var slotLogRapid: SlotMasa = .pranz
    var seAfisezaLogRapid: Bool = false
    var retetaDeLogatRapid: Reteta? = nil

    // MARK: - Init
    init() {
        self.ingredienteFiltrate = toateIngredientele
        self.reteteFiltrate = []
    }

    // MARK: - Configurare
    func configureaza(context: ModelContext) {
        self.modelContext = context
        incarcaRetete()
    }

    // MARK: - Încărcare Rețete din SwiftData
    func incarcaRetete() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Reteta>(
            sortBy: [SortDescriptor(\.dataCreare, order: .reverse)]
        )
        retete = (try? context.fetch(descriptor)) ?? []
        filtreazaRetete()
    }

    // MARK: - Filtrare Rețete
    private func filtreazaRetete() {
        var rezultat = retete

        // Filtrare categorie
        if let cat = categorieFiltrare {
            rezultat = rezultat.filter { $0.categorie == cat }
        }

        // Căutare după nume
        if !textCautareReteta.trimmingCharacters(in: .whitespaces).isEmpty {
            let text = textCautareReteta.lowercased()
            rezultat = rezultat.filter {
                $0.nume.lowercased().contains(text) ||
                $0.descriere.lowercased().contains(text)
            }
        }

        reteteFiltrate = rezultat
    }

    // MARK: - Filtrare Ingrediente
    func filtreazaIngrediente() {
        var rezultat = toateIngredientele

        if let cat = categorieCautareIngredient {
            rezultat = rezultat.filter { $0.categorie == cat }
        }

        if !textCautareIngredient.trimmingCharacters(in: .whitespaces).isEmpty {
            let text = textCautareIngredient.lowercased()
            rezultat = rezultat.filter { $0.nume.lowercased().contains(text) }
        }

        ingredienteFiltrate = rezultat
    }

    // MARK: - Salvare Rețetă Nouă
    func salveazaRetetaNoua() {
        guard !retetaNoua.nume.trimmingCharacters(in: .whitespaces).isEmpty else {
            mesajEroare = "Rețeta trebuie să aibă un nume."
            seAfisezaEroare = true
            return
        }

        guard !retetaNoua.ingredienteAdaugate.isEmpty else {
            mesajEroare = "Adaugă cel puțin un ingredient."
            seAfisezaEroare = true
            return
        }

        guard let context = modelContext else { return }

        let reteta = Reteta(
            nume: retetaNoua.nume,
            descriere: retetaNoua.descriere,
            categorie: retetaNoua.categorie,
            numarPortii: retetaNoua.numarPortii,
            timpPreparare: retetaNoua.timpPreparare,
            ingrediente: retetaNoua.ingredienteAdaugate
        )

        context.insert(reteta)

        do {
            try context.save()
            incarcaRetete()
            retetaNoua = RetetaBuilder()  // Reset builder
            seAfisezaBuilderReteta = false

            withAnimation(.spring(duration: 0.4)) {
                mesajConfirmare = "Rețeta \"\(reteta.nume)\" a fost salvată! 🎉"
                seAfisezaMesajConfirmare = true
            }

            Task {
                try? await Task.sleep(for: .seconds(3))
                withAnimation { seAfisezaMesajConfirmare = false }
            }

        } catch {
            mesajEroare = "Eroare la salvarea rețetei: \(error.localizedDescription)"
            seAfisezaEroare = true
        }
    }

    // MARK: - Șterge Rețetă
    func stergeReteta(_ reteta: Reteta) {
        guard let context = modelContext else { return }
        context.delete(reteta)
        try? context.save()
        withAnimation { incarcaRetete() }
    }

    // MARK: - Salvează Ingredient Nou (din Barcode Scanner)
    /// Salvează un ingredient scanat în baza de date locală SwiftData
    func salveazaIngredientNou(_ ingredient: Ingredient) {
        guard let context = modelContext else {
            // Dacă nu avem context, adaugă doar în lista în memorie
            toateIngredientele.append(ingredient)
            filtreazaIngrediente()
            return
        }
        context.insert(ingredient)
        try? context.save()
        toateIngredientele.append(ingredient)
        filtreazaIngrediente()
    }

    // MARK: - Toggle Preferată
    func togglePreferata(_ reteta: Reteta) {
        withAnimation(.spring(duration: 0.3)) {
            reteta.estePreferata.toggle()
        }
        try? modelContext?.save()
    }

    // MARK: - Log Rapid Rețetă → Jurnal
    func logheazaRetetaRapid(
        _ reteta: Reteta,
        laSlot slot: SlotMasa,
        portii: Double = 1,
        dashboardVM: DashboardViewModel
    ) {
        dashboardVM.adaugaReteta(reteta, laSlot: slot, portii: portii)

        withAnimation(.spring(duration: 0.4)) {
            mesajConfirmare = "\(reteta.nume) adăugat la \(slot.rawValue) ✅"
            seAfisezaMesajConfirmare = true
        }

        Task {
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation { seAfisezaMesajConfirmare = false }
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - Creare Rețete Demo (la primul launch)
    func creeazaReteteDemo() {
        guard let context = modelContext, retete.isEmpty else { return }

        for reteta in Reteta.reteteDemoPerCreare() {
            context.insert(reteta)
        }
        try? context.save()
        incarcaRetete()
    }

    // MARK: - Statistici
    var totalRetete: Int { retete.count }
    var reteteFavorite: [Reteta] { retete.filter { $0.estePreferata } }
    var reteteDupaTip: [CategorieReteta: [Reteta]] {
        Dictionary(grouping: retete, by: { $0.categorie })
    }

    // MARK: - Căutare Inteligentă
    func cautaIngredientSimilar(text: String) -> [Ingredient] {
        let text = text.lowercased()
        return toateIngredientele.filter {
            $0.nume.lowercased().contains(text) ||
            $0.categorie.rawValue.lowercased().contains(text)
        }.prefix(10).map { $0 }
    }
}

// MARK: - Builder Rețetă
/// Stare temporară pentru construirea unei rețete noi
@Observable
class RetetaBuilder {
    var nume: String = ""
    var descriere: String = ""
    var categorie: CategorieReteta = .principala
    var numarPortii: Int = 1
    var timpPreparare: Int = 30
    var ingredienteAdaugate: [Ingredient] = []

    // MARK: - Calcule Live
    var kcalTotal: Double { ingredienteAdaugate.reduce(0) { $0 + $1.kcalTotal } }
    var proteineTotal: Double { ingredienteAdaugate.reduce(0) { $0 + $1.proteineTotal } }
    var carboTotal: Double { ingredienteAdaugate.reduce(0) { $0 + $1.carboTotal } }
    var grasimiTotal: Double { ingredienteAdaugate.reduce(0) { $0 + $1.grasimiTotal } }

    var kcalPerPortie: Double { guard numarPortii > 0 else { return 0 }; return kcalTotal / Double(numarPortii) }
    var proteinePerPortie: Double { guard numarPortii > 0 else { return 0 }; return proteineTotal / Double(numarPortii) }
    var carboPerPortie: Double { guard numarPortii > 0 else { return 0 }; return carboTotal / Double(numarPortii) }
    var grasimiPerPortie: Double { guard numarPortii > 0 else { return 0 }; return grasimiTotal / Double(numarPortii) }

    func adaugaIngredient(_ ingredient: Ingredient, cantitate: Double) {
        let copie = ingredient.copie(cantitate: cantitate)
        withAnimation(.spring(duration: 0.3)) {
            ingredienteAdaugate.append(copie)
        }
    }

    func stergeIngredient(laIndex index: Int) {
        guard index < ingredienteAdaugate.count else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            ingredienteAdaugate.remove(at: index)
        }
    }

    func actualizeazaCantitate(laIndex index: Int, cantitate: Double) {
        guard index < ingredienteAdaugate.count else { return }
        ingredienteAdaugate[index].cantitateGrame = cantitate
    }
}
