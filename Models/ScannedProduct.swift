// MARK: - ScannedProduct.swift
// NutriAI Pro — Model produs scanat (Open Food Facts)
// Faza 3: Barcode Scanner

import Foundation
import SwiftUI

// MARK: - ScannedProduct
/// Produsul identificat prin scanarea codului de bare
struct ScannedProduct: Identifiable, Equatable {
    let id: UUID = UUID()
    let barcode: String
    let numeProdus: String
    let brand: String
    let urlImagine: String?

    // Valori nutriționale per 100g
    let kcalPer100g: Double
    let proteinePer100g: Double
    let carboPer100g: Double
    let grasimiPer100g: Double
    let fibrePer100g: Double
    let zaharPer100g: Double

    // Info suplimentar
    let marimePorţie: String?
    let cantitateGramePorţie: Double?

    // MARK: - Macro calculate pentru o cantitate specificată
    func kcal(pentruGrame g: Double) -> Double { kcalPer100g * g / 100 }
    func proteine(pentruGrame g: Double) -> Double { proteinePer100g * g / 100 }
    func carbo(pentruGrame g: Double) -> Double { carboPer100g * g / 100 }
    func grasimi(pentruGrame g: Double) -> Double { grasimiPer100g * g / 100 }

    // MARK: - Calitate date
    var areDate: Bool {
        kcalPer100g > 0 && !numeProdus.isEmpty
    }

    // MARK: - Conversie către Ingredient SwiftData
    func asIngredient(cantitate: Double = 100) -> Ingredient {
        Ingredient(
            nume: numeProdus,
            kcalPer100g: kcalPer100g,
            proteinePer100g: proteinePer100g,
            carboPer100g: carboPer100g,
            grasimiPer100g: grasimiPer100g,
            categorie: .altele,
            cantitateGrame: cantitate
        )
    }

    // MARK: - Conversie către IntrareAliment
    func asIntrare(slot: SlotMasa, cantitate: Double) -> IntrareAliment {
        IntrareAliment(
            numeAliment: numeProdus,
            kcal: kcal(pentruGrame: cantitate),
            proteine: proteine(pentruGrame: cantitate),
            carbo: carbo(pentruGrame: cantitate),
            grasimi: grasimi(pentruGrame: cantitate),
            gramaj: cantitate,
            slot: slot,
            esteRinReteta: false
        )
    }
}

// MARK: - OpenFoodFacts API Response Models
/// Structuri pentru decodificarea răspunsului JSON de la Open Food Facts

struct OFFApiResponse: Decodable {
    let status: Int          // 1 = găsit, 0 = negăsit
    let statusVerbose: String?
    let product: OFFProduct?

    enum CodingKeys: String, CodingKey {
        case status
        case statusVerbose = "status_verbose"
        case product
    }
}

struct OFFProduct: Decodable {
    let productName: String?
    let productNameRo: String?   // Versiunea română dacă există
    let productNameEn: String?
    let brands: String?
    let imageUrl: String?
    let imageFrontUrl: String?
    let servingSize: String?
    let servingQuantity: Double?
    let nutriments: OFFNutriments?

    // Câmpul de nume cel mai relevant
    var numeCalculat: String {
        productNameRo ?? productName ?? productNameEn ?? "Produs Necunoscut"
    }

    enum CodingKeys: String, CodingKey {
        case productName       = "product_name"
        case productNameRo     = "product_name_ro"
        case productNameEn     = "product_name_en"
        case brands
        case imageUrl          = "image_url"
        case imageFrontUrl     = "image_front_url"
        case servingSize       = "serving_size"
        case servingQuantity   = "serving_quantity"
        case nutriments
    }
}

struct OFFNutriments: Decodable {
    // Energie
    let energyKcal100g: Double?
    let energyKcal: Double?

    // Macronutrienți per 100g
    let proteine100g: Double?
    let carbo100g: Double?
    let grasimi100g: Double?
    let fibre100g: Double?
    let zahar100g: Double?
    let sare100g: Double?

    // Valori calculate (pot lipsi)
    var kcal: Double { energyKcal100g ?? energyKcal ?? 0 }

    enum CodingKeys: String, CodingKey {
        case energyKcal100g   = "energy-kcal_100g"
        case energyKcal       = "energy-kcal"
        case proteine100g     = "proteins_100g"
        case carbo100g        = "carbohydrates_100g"
        case grasimi100g      = "fat_100g"
        case fibre100g        = "fiber_100g"
        case zahar100g        = "sugars_100g"
        case sare100g         = "salt_100g"
    }
}

// MARK: - Scanner Error
enum ScannerError: LocalizedError {
    case produsFăsGăsit(String)
    case rețeaIndisponibilă
    case dateInvalide
    case camerăIndisponibilă
    case permisiuneDenied

    var errorDescription: String? {
        switch self {
        case .produsFăsGăsit(let barcode):
            return "Produsul cu codul \(barcode) nu a fost găsit în baza de date."
        case .rețeaIndisponibilă:
            return "Nu există conexiune la internet. Verifică rețeaua și încearcă din nou."
        case .dateInvalide:
            return "Datele nutriționale pentru acest produs sunt incomplete sau invalide."
        case .camerăIndisponibilă:
            return "Camera nu este disponibilă pe acest dispozitiv."
        case .permisiuneDenied:
            return "Permisiunea pentru cameră a fost refuzată. Activează-o din Setări > NutriAI Pro > Cameră."
    }
}

    var errorDescriptionRomana: String {
        errorDescription ?? "Eroare necunoscută"
    }
}

// MARK: - Produs Mock (pentru Simulator / offline)
extension ScannedProduct {
    static let mockuri: [String: ScannedProduct] = [
        "3017620422003": ScannedProduct(
            barcode: "3017620422003",
            numeProdus: "Nutella",
            brand: "Ferrero",
            urlImagine: nil,
            kcalPer100g: 539,
            proteinePer100g: 6.3,
            carboPer100g: 57.5,
            grasimiPer100g: 30.9,
            fibrePer100g: 0,
            zaharPer100g: 56.3,
            marimePorţie: "15g",
            cantitateGramePorţie: 15
        ),
        "5449000000996": ScannedProduct(
            barcode: "5449000000996",
            numeProdus: "Coca-Cola",
            brand: "The Coca-Cola Company",
            urlImagine: nil,
            kcalPer100g: 42,
            proteinePer100g: 0,
            carboPer100g: 10.6,
            grasimiPer100g: 0,
            fibrePer100g: 0,
            zaharPer100g: 10.6,
            marimePorţie: "330ml",
            cantitateGramePorţie: 330
        ),
        "8001120901859": ScannedProduct(
            barcode: "8001120901859",
            numeProdus: "Panzani Spaghetti",
            brand: "Panzani",
            urlImagine: nil,
            kcalPer100g: 350,
            proteinePer100g: 13.0,
            carboPer100g: 68.5,
            grasimiPer100g: 1.8,
            fibrePer100g: 3.2,
            zaharPer100g: 3.5,
            marimePorţie: "80g",
            cantitateGramePorţie: 80
        ),
        "3155250349793": ScannedProduct(
            barcode: "3155250349793",
            numeProdus: "Iaurt Grecesc 0%",
            brand: "Danone",
            urlImagine: nil,
            kcalPer100g: 56,
            proteinePer100g: 9.0,
            carboPer100g: 4.0,
            grasimiPer100g: 0.2,
            fibrePer100g: 0,
            zaharPer100g: 4.0,
            marimePorţie: "150g",
            cantitateGramePorţie: 150
        ),
        "5010477348678": ScannedProduct(
            barcode: "5010477348678",
            numeProdus: "Fulgi de Ovăz",
            brand: "Quaker",
            urlImagine: nil,
            kcalPer100g: 370,
            proteinePer100g: 13.5,
            carboPer100g: 60.0,
            grasimiPer100g: 6.9,
            fibrePer100g: 10.1,
            zaharPer100g: 1.1,
            marimePorţie: "40g",
            cantitateGramePorţie: 40
        )
    ]
}
