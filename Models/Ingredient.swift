// MARK: - Ingredient.swift
// NutriAI Pro — Model ingredient (SwiftData @Model)
// Platformă: iOS 17+ | SwiftUI | SwiftData

import Foundation
import SwiftData

/// Un ingredient cu valorile nutritive per 100g produs.
@Model
final class Ingredient {

    // MARK: - Identificare
    var id: UUID
    var nume: String
    var categorie: CategorieIngredient

    // MARK: - Valori Nutritive (per 100g)
    var kcalPer100g: Double
    var proteinePer100g: Double
    var carboPer100g: Double
    var grasimiPer100g: Double
    var fibrePer100g: Double

    // MARK: - Cantitate selectată (grame) — folosit în context rețetă
    var cantitateGrame: Double

    // MARK: - Relație cu rețeta
    @Relationship(inverse: \Reteta.ingrediente)
    var reteta: Reteta?

    // MARK: - Valori calculate pentru cantitatea selectată
    var kcalTotal: Double { kcalPer100g * cantitateGrame / 100 }
    var proteineTotal: Double { proteinePer100g * cantitateGrame / 100 }
    var carboTotal: Double { carboPer100g * cantitateGrame / 100 }
    var grasimiTotal: Double { grasimiPer100g * cantitateGrame / 100 }

    // MARK: - Init
    init(
        id: UUID = UUID(),
        nume: String,
        categorie: CategorieIngredient = .altele,
        kcalPer100g: Double,
        proteinePer100g: Double,
        carboPer100g: Double,
        grasimiPer100g: Double,
        fibrePer100g: Double = 0,
        cantitateGrame: Double = 100
    ) {
        self.id = id
        self.nume = nume
        self.categorie = categorie
        self.kcalPer100g = kcalPer100g
        self.proteinePer100g = proteinePer100g
        self.carboPer100g = carboPer100g
        self.grasimiPer100g = grasimiPer100g
        self.fibrePer100g = fibrePer100g
        self.cantitateGrame = cantitateGrame
    }

    // MARK: - Copie independentă (pentru a fi adăugat la o rețetă fără referință shared)
    func copie(cantitate: Double) -> Ingredient {
        Ingredient(
            id: UUID(),
            nume: self.nume,
            categorie: self.categorie,
            kcalPer100g: self.kcalPer100g,
            proteinePer100g: self.proteinePer100g,
            carboPer100g: self.carboPer100g,
            grasimiPer100g: self.grasimiPer100g,
            fibrePer100g: self.fibrePer100g,
            cantitateGrame: cantitate
        )
    }
}

// MARK: - Categorie Ingredient
enum CategorieIngredient: String, CaseIterable, Codable {
    case carne       = "Carne & Pește"
    case lactate     = "Lactate & Ouă"
    case cereale     = "Cereale & Leguminoase"
    case legume      = "Legume"
    case fructe      = "Fructe"
    case nuciSeminte = "Nuci & Semințe"
    case uleiuri     = "Uleiuri & Grăsimi"
    case suplimente  = "Suplimente"
    case altele      = "Altele"

    var icon: String {
        switch self {
        case .carne:       return "fork.knife"
        case .lactate:     return "cup.and.saucer.fill"
        case .cereale:     return "leaf.fill"
        case .legume:      return "carrot.fill"
        case .fructe:      return "apple.logo"
        case .nuciSeminte: return "circle.hexagongrid.fill"
        case .uleiuri:     return "drop.fill"
        case .suplimente:  return "pills.fill"
        case .altele:      return "square.grid.2x2.fill"
        }
    }
}

// MARK: - Baza de Date Ingrediente Predefinite
/// 60+ alimente comune românești cu valorile nutritive per 100g
struct BazaDateAlimente {
    static let alimente: [Ingredient] = [
        // Carne & Pește
        Ingredient(nume: "Piept de Pui (fiert)", categorie: .carne,    kcalPer100g: 165, proteinePer100g: 31, carboPer100g: 0,   grasimiPer100g: 3.6),
        Ingredient(nume: "Piept de Curcan",       categorie: .carne,    kcalPer100g: 135, proteinePer100g: 30, carboPer100g: 0,   grasimiPer100g: 1.0),
        Ingredient(nume: "Vită (mușchi)",          categorie: .carne,    kcalPer100g: 250, proteinePer100g: 26, carboPer100g: 0,   grasimiPer100g: 17),
        Ingredient(nume: "Porc (fleică)",          categorie: .carne,    kcalPer100g: 242, proteinePer100g: 27, carboPer100g: 0,   grasimiPer100g: 14),
        Ingredient(nume: "Somon (fillet)",         categorie: .carne,    kcalPer100g: 208, proteinePer100g: 20, carboPer100g: 0,   grasimiPer100g: 13),
        Ingredient(nume: "Ton (conservă, în apă)", categorie: .carne,    kcalPer100g: 116, proteinePer100g: 26, carboPer100g: 0,   grasimiPer100g: 1.0),
        Ingredient(nume: "Creveti",                categorie: .carne,    kcalPer100g: 99,  proteinePer100g: 24, carboPer100g: 0.2, grasimiPer100g: 0.3),
        Ingredient(nume: "Cod (file)",             categorie: .carne,    kcalPer100g: 82,  proteinePer100g: 18, carboPer100g: 0,   grasimiPer100g: 0.7),

        // Lactate & Ouă
        Ingredient(nume: "Ouă (întreg)",           categorie: .lactate,  kcalPer100g: 155, proteinePer100g: 13, carboPer100g: 1.1, grasimiPer100g: 11),
        Ingredient(nume: "Albuș de Ou",            categorie: .lactate,  kcalPer100g: 52,  proteinePer100g: 11, carboPer100g: 0.7, grasimiPer100g: 0.2),
        Ingredient(nume: "Brânză de Vaci (0%)",    categorie: .lactate,  kcalPer100g: 74,  proteinePer100g: 11, carboPer100g: 4.3, grasimiPer100g: 0.4),
        Ingredient(nume: "Iaurt Grecesc (0%)",     categorie: .lactate,  kcalPer100g: 59,  proteinePer100g: 10, carboPer100g: 3.6, grasimiPer100g: 0.4),
        Ingredient(nume: "Lapte (1.5%)",           categorie: .lactate,  kcalPer100g: 47,  proteinePer100g: 3.4, carboPer100g: 4.8, grasimiPer100g: 1.5),
        Ingredient(nume: "Caș",                    categorie: .lactate,  kcalPer100g: 280, proteinePer100g: 18, carboPer100g: 1.5, grasimiPer100g: 22),
        Ingredient(nume: "Parmezan",               categorie: .lactate,  kcalPer100g: 431, proteinePer100g: 38, carboPer100g: 4.1, grasimiPer100g: 29),
        Ingredient(nume: "Unt",                    categorie: .lactate,  kcalPer100g: 717, proteinePer100g: 0.9, carboPer100g: 0.1, grasimiPer100g: 81),

        // Cereale & Leguminoase
        Ingredient(nume: "Orez (fiert)",           categorie: .cereale,  kcalPer100g: 130, proteinePer100g: 2.7, carboPer100g: 28,  grasimiPer100g: 0.3),
        Ingredient(nume: "Paste (fierte)",          categorie: .cereale,  kcalPer100g: 158, proteinePer100g: 5.8, carboPer100g: 31,  grasimiPer100g: 0.9),
        Ingredient(nume: "Fulgi de Ovăz",           categorie: .cereale,  kcalPer100g: 389, proteinePer100g: 17,  carboPer100g: 66,  grasimiPer100g: 7.0),
        Ingredient(nume: "Cartofi (fierți)",        categorie: .cereale,  kcalPer100g: 87,  proteinePer100g: 1.9, carboPer100g: 20,  grasimiPer100g: 0.1),
        Ingredient(nume: "Linte (fiartă)",          categorie: .cereale,  kcalPer100g: 116, proteinePer100g: 9.0, carboPer100g: 20,  grasimiPer100g: 0.4),
        Ingredient(nume: "Naut (fiert)",            categorie: .cereale,  kcalPer100g: 164, proteinePer100g: 8.9, carboPer100g: 27,  grasimiPer100g: 2.6),
        Ingredient(nume: "Pâine Integrală",         categorie: .cereale,  kcalPer100g: 247, proteinePer100g: 9.0, carboPer100g: 41,  grasimiPer100g: 3.4),
        Ingredient(nume: "Quinoa (fiartă)",         categorie: .cereale,  kcalPer100g: 120, proteinePer100g: 4.4, carboPer100g: 22,  grasimiPer100g: 1.9),

        // Legume
        Ingredient(nume: "Spanac",                 categorie: .legume,   kcalPer100g: 23,  proteinePer100g: 2.9, carboPer100g: 3.6, grasimiPer100g: 0.4),
        Ingredient(nume: "Broccoli",               categorie: .legume,   kcalPer100g: 34,  proteinePer100g: 2.8, carboPer100g: 7.0, grasimiPer100g: 0.4),
        Ingredient(nume: "Roșii",                  categorie: .legume,   kcalPer100g: 18,  proteinePer100g: 0.9, carboPer100g: 3.9, grasimiPer100g: 0.2),
        Ingredient(nume: "Castraveți",             categorie: .legume,   kcalPer100g: 15,  proteinePer100g: 0.7, carboPer100g: 3.6, grasimiPer100g: 0.1),
        Ingredient(nume: "Ardei Roșu",             categorie: .legume,   kcalPer100g: 31,  proteinePer100g: 1.0, carboPer100g: 6.0, grasimiPer100g: 0.3),
        Ingredient(nume: "Ceapă",                  categorie: .legume,   kcalPer100g: 40,  proteinePer100g: 1.1, carboPer100g: 9.3, grasimiPer100g: 0.1),
        Ingredient(nume: "Morcovi",                categorie: .legume,   kcalPer100g: 41,  proteinePer100g: 0.9, carboPer100g: 10,  grasimiPer100g: 0.2),
        Ingredient(nume: "Fasole Verde",           categorie: .legume,   kcalPer100g: 31,  proteinePer100g: 1.8, carboPer100g: 7.0, grasimiPer100g: 0.1),
        Ingredient(nume: "Conopidă",               categorie: .legume,   kcalPer100g: 25,  proteinePer100g: 1.9, carboPer100g: 5.0, grasimiPer100g: 0.3),
        Ingredient(nume: "Dovlecel",               categorie: .legume,   kcalPer100g: 17,  proteinePer100g: 1.2, carboPer100g: 3.1, grasimiPer100g: 0.3),

        // Fructe
        Ingredient(nume: "Banane",                 categorie: .fructe,   kcalPer100g: 89,  proteinePer100g: 1.1, carboPer100g: 23,  grasimiPer100g: 0.3),
        Ingredient(nume: "Mere",                   categorie: .fructe,   kcalPer100g: 52,  proteinePer100g: 0.3, carboPer100g: 14,  grasimiPer100g: 0.2),
        Ingredient(nume: "Căpșuni",                categorie: .fructe,   kcalPer100g: 32,  proteinePer100g: 0.7, carboPer100g: 7.7, grasimiPer100g: 0.3),
        Ingredient(nume: "Afine",                  categorie: .fructe,   kcalPer100g: 57,  proteinePer100g: 0.7, carboPer100g: 14,  grasimiPer100g: 0.3),
        Ingredient(nume: "Portocale",              categorie: .fructe,   kcalPer100g: 47,  proteinePer100g: 0.9, carboPer100g: 12,  grasimiPer100g: 0.1),
        Ingredient(nume: "Avocado",                categorie: .fructe,   kcalPer100g: 160, proteinePer100g: 2.0, carboPer100g: 9.0, grasimiPer100g: 15),

        // Nuci & Semințe
        Ingredient(nume: "Migdale",                categorie: .nuciSeminte, kcalPer100g: 579, proteinePer100g: 21, carboPer100g: 22, grasimiPer100g: 50),
        Ingredient(nume: "Nuci",                   categorie: .nuciSeminte, kcalPer100g: 654, proteinePer100g: 15, carboPer100g: 14, grasimiPer100g: 65),
        Ingredient(nume: "Unt de Arahide",         categorie: .nuciSeminte, kcalPer100g: 598, proteinePer100g: 25, carboPer100g: 20, grasimiPer100g: 51),
        Ingredient(nume: "Semințe de Chia",        categorie: .nuciSeminte, kcalPer100g: 486, proteinePer100g: 17, carboPer100g: 42, grasimiPer100g: 31, fibrePer100g: 34),
        Ingredient(nume: "Semințe de In",          categorie: .nuciSeminte, kcalPer100g: 534, proteinePer100g: 18, carboPer100g: 29, grasimiPer100g: 42),

        // Uleiuri & Grăsimi
        Ingredient(nume: "Ulei de Măsline",        categorie: .uleiuri,  kcalPer100g: 884, proteinePer100g: 0, carboPer100g: 0, grasimiPer100g: 100),
        Ingredient(nume: "Ulei de Cocos",          categorie: .uleiuri,  kcalPer100g: 862, proteinePer100g: 0, carboPer100g: 0, grasimiPer100g: 100),

        // Suplimente
        Ingredient(nume: "Proteină Whey (vanilla)", categorie: .suplimente, kcalPer100g: 380, proteinePer100g: 75, carboPer100g: 10, grasimiPer100g: 5),
        Ingredient(nume: "Creatină Monohidrat",     categorie: .suplimente, kcalPer100g: 0,   proteinePer100g: 0,  carboPer100g: 0,  grasimiPer100g: 0),
        Ingredient(nume: "Cazeină",                 categorie: .suplimente, kcalPer100g: 370, proteinePer100g: 80, carboPer100g: 8,  grasimiPer100g: 3),
    ]
}
