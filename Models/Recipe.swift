// MARK: - Recipe.swift
// NutriAI Pro — Modelul de rețetă (SwiftData @Model)
// Platformă: iOS 17+ | SwiftUI | SwiftData

import Foundation
import SwiftData

/// O rețetă personalizată, salvată de utilizator, cu un set de ingrediente.
@Model
final class Reteta {

    // MARK: - Identificare
    var id: UUID
    var nume: String
    var descriere: String
    var categorie: CategorieReteta
    var icon: String
    var dataCreare: Date
    var numarPortii: Int

    // MARK: - Ingrediente
    var ingrediente: [Ingredient]

    // MARK: - Macronutrienți Calculați (per porție)
    var kcalPerPortie: Double {
        guard numarPortii > 0 else { return 0 }
        return ingrediente.reduce(0) { $0 + $1.kcalTotal } / Double(numarPortii)
    }
    var proteinePerPortie: Double {
        guard numarPortii > 0 else { return 0 }
        return ingrediente.reduce(0) { $0 + $1.proteineTotal } / Double(numarPortii)
    }
    var carboPerPortie: Double {
        guard numarPortii > 0 else { return 0 }
        return ingrediente.reduce(0) { $0 + $1.carboTotal } / Double(numarPortii)
    }
    var grasimiPerPortie: Double {
        guard numarPortii > 0 else { return 0 }
        return ingrediente.reduce(0) { $0 + $1.grasimiTotal } / Double(numarPortii)
    }

    // MARK: - Totaluri Rețetă (toate porțiile)
    var kcalTotal: Double { ingrediente.reduce(0) { $0 + $1.kcalTotal } }
    var proteineTotal: Double { ingrediente.reduce(0) { $0 + $1.proteineTotal } }
    var carboTotal: Double { ingrediente.reduce(0) { $0 + $1.carboTotal } }
    var grasimiTotal: Double { ingrediente.reduce(0) { $0 + $1.grasimiTotal } }

    // MARK: - Tag-uri
    var estePreferata: Bool
    var timpPreparare: Int   // minute

    // MARK: - Init
    init(
        id: UUID = UUID(),
        nume: String,
        descriere: String = "",
        categorie: CategorieReteta = .principala,
        icon: String = "fork.knife",
        numarPortii: Int = 1,
        timpPreparare: Int = 30,
        estePreferata: Bool = false,
        ingrediente: [Ingredient] = []
    ) {
        self.id = id
        self.nume = nume
        self.descriere = descriere
        self.categorie = categorie
        self.icon = icon
        self.numarPortii = numarPortii
        self.timpPreparare = timpPreparare
        self.estePreferata = estePreferata
        self.ingrediente = ingrediente
        self.dataCreare = Date()
    }
}

// MARK: - Categorie Rețetă
enum CategorieReteta: String, CaseIterable, Codable {
    case micDejun  = "Mic Dejun"
    case principala = "Felul Principal"
    case gustare   = "Gustare"
    case desert    = "Desert"
    case bautura   = "Băutură"

    var icon: String {
        switch self {
        case .micDejun:    return "sunrise.fill"
        case .principala:  return "fork.knife"
        case .gustare:     return "leaf.fill"
        case .desert:      return "birthday.cake.fill"
        case .bautura:     return "cup.and.saucer.fill"
        }
    }
}

// MARK: - Rețete Demo Predefinite
extension Reteta {
    /// Rețete demo pentru testarea UI
    static func reteteDemoPerCreare() -> [Reteta] {
        [
            creeazaPuiCuOrez(),
            creeazaSalataDePui(),
            creeazaSmothieProteic(),
            creeazaOmleta()
        ]
    }

    private static func creeazaPuiCuOrez() -> Reteta {
        let r = Reteta(
            nume: "Pui cu Orez",
            descriere: "Clasică sursă de proteine și carbohidrați complecși.",
            categorie: .principala,
            icon: "fork.knife",
            numarPortii: 1,
            timpPreparare: 25
        )
        r.ingrediente = [
            Ingredient(nume: "Piept de Pui (fiert)", categorie: .carne,
                       kcalPer100g: 165, proteinePer100g: 31, carboPer100g: 0, grasimiPer100g: 3.6,
                       cantitateGrame: 200),
            Ingredient(nume: "Orez (fiert)", categorie: .cereale,
                       kcalPer100g: 130, proteinePer100g: 2.7, carboPer100g: 28, grasimiPer100g: 0.3,
                       cantitateGrame: 150),
            Ingredient(nume: "Ulei de Măsline", categorie: .uleiuri,
                       kcalPer100g: 884, proteinePer100g: 0, carboPer100g: 0, grasimiPer100g: 100,
                       cantitateGrame: 10)
        ]
        return r
    }

    private static func creeazaSalataDePui() -> Reteta {
        let r = Reteta(
            nume: "Salată de Pui",
            descriere: "Salată bogată în proteine, perfectă pentru prânz.",
            categorie: .principala,
            icon: "leaf.fill",
            numarPortii: 1,
            timpPreparare: 15
        )
        r.ingrediente = [
            Ingredient(nume: "Piept de Pui (fiert)", categorie: .carne,
                       kcalPer100g: 165, proteinePer100g: 31, carboPer100g: 0, grasimiPer100g: 3.6,
                       cantitateGrame: 150),
            Ingredient(nume: "Spanac", categorie: .legume,
                       kcalPer100g: 23, proteinePer100g: 2.9, carboPer100g: 3.6, grasimiPer100g: 0.4,
                       cantitateGrame: 100),
            Ingredient(nume: "Roșii", categorie: .legume,
                       kcalPer100g: 18, proteinePer100g: 0.9, carboPer100g: 3.9, grasimiPer100g: 0.2,
                       cantitateGrame: 80),
            Ingredient(nume: "Ulei de Măsline", categorie: .uleiuri,
                       kcalPer100g: 884, proteinePer100g: 0, carboPer100g: 0, grasimiPer100g: 100,
                       cantitateGrame: 10)
        ]
        return r
    }

    private static func creeazaSmothieProteic() -> Reteta {
        let r = Reteta(
            nume: "Smoothie Proteic",
            descriere: "Smoothie rapid pentru post-antrenament.",
            categorie: .bautura,
            icon: "cup.and.saucer.fill",
            numarPortii: 1,
            timpPreparare: 5
        )
        r.ingrediente = [
            Ingredient(nume: "Proteină Whey (vanilla)", categorie: .suplimente,
                       kcalPer100g: 380, proteinePer100g: 75, carboPer100g: 10, grasimiPer100g: 5,
                       cantitateGrame: 30),
            Ingredient(nume: "Banane", categorie: .fructe,
                       kcalPer100g: 89, proteinePer100g: 1.1, carboPer100g: 23, grasimiPer100g: 0.3,
                       cantitateGrame: 100),
            Ingredient(nume: "Lapte (1.5%)", categorie: .lactate,
                       kcalPer100g: 47, proteinePer100g: 3.4, carboPer100g: 4.8, grasimiPer100g: 1.5,
                       cantitateGrame: 250),
            Ingredient(nume: "Semințe de Chia", categorie: .nuciSeminte,
                       kcalPer100g: 486, proteinePer100g: 17, carboPer100g: 42, grasimiPer100g: 31,
                       cantitateGrame: 15)
        ]
        return r
    }

    private static func creeazaOmleta() -> Reteta {
        let r = Reteta(
            nume: "Omletă cu Legume",
            descriere: "Mic dejun bogat în proteine și vitamine.",
            categorie: .micDejun,
            icon: "sunrise.fill",
            numarPortii: 1,
            timpPreparare: 10
        )
        r.ingrediente = [
            Ingredient(nume: "Ouă (întreg)", categorie: .lactate,
                       kcalPer100g: 155, proteinePer100g: 13, carboPer100g: 1.1, grasimiPer100g: 11,
                       cantitateGrame: 200),
            Ingredient(nume: "Albuș de Ou", categorie: .lactate,
                       kcalPer100g: 52, proteinePer100g: 11, carboPer100g: 0.7, grasimiPer100g: 0.2,
                       cantitateGrame: 100),
            Ingredient(nume: "Ardei Roșu", categorie: .legume,
                       kcalPer100g: 31, proteinePer100g: 1.0, carboPer100g: 6.0, grasimiPer100g: 0.3,
                       cantitateGrame: 50),
            Ingredient(nume: "Spanac", categorie: .legume,
                       kcalPer100g: 23, proteinePer100g: 2.9, carboPer100g: 3.6, grasimiPer100g: 0.4,
                       cantitateGrame: 50),
            Ingredient(nume: "Ulei de Cocos", categorie: .uleiuri,
                       kcalPer100g: 862, proteinePer100g: 0, carboPer100g: 0, grasimiPer100g: 100,
                       cantitateGrame: 5)
        ]
        return r
    }
}
