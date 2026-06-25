// MARK: - DailyLog.swift
// NutriAI Pro — Jurnalul zilnic (SwiftData @Model)
// Platformă: iOS 17+ | SwiftUI | SwiftData

import Foundation
import SwiftData

/// Jurnalul de nutriție pentru o zi calendaristică specifică.
@Model
final class JurnalZilnic {

    // MARK: - Identificare
    var id: UUID
    var data: Date  // Cheia de identificare: ziua calendaristică

    // MARK: - Mese (4 sloturi)
    var intrariMicDejun: [IntrareAliment]
    var intrariPranz:    [IntrareAliment]
    var intrariCina:     [IntrareAliment]
    var intrariGustare:  [IntrareAliment]

    // MARK: - Hidratare
    var apaConsumataML: Double   // mililitri

    // MARK: - Calorii Arse (HealthKit)
    var caloriiArseActiv: Double   // kcal din exercițiu
    var pasi: Int                  // pași din HealthKit

    // MARK: - Init
    init(data: Date = Date()) {
        self.id = UUID()
        self.data = Calendar.current.startOfDay(for: data)
        self.intrariMicDejun = []
        self.intrariPranz = []
        self.intrariCina = []
        self.intrariGustare = []
        self.apaConsumataML = 0
        self.caloriiArseActiv = 0
        self.pasi = 0
    }

    // MARK: - Accesorii calculate
    var toateIntrarile: [IntrareAliment] {
        intrariMicDejun + intrariPranz + intrariCina + intrariGustare
    }

    var kcalConsumate: Double {
        toateIntrarile.reduce(0) { $0 + $1.kcal }
    }
    var proteineConsumate: Double {
        toateIntrarile.reduce(0) { $0 + $1.proteine }
    }
    var carboConsumate: Double {
        toateIntrarile.reduce(0) { $0 + $1.carbo }
    }
    var grasimiConsumate: Double {
        toateIntrarile.reduce(0) { $0 + $1.grasimi }
    }

    /// Returnează intrările pentru un slot specific
    func intrari(pentruSlot slot: SlotMasa) -> [IntrareAliment] {
        switch slot {
        case .micDejun: return intrariMicDejun
        case .pranz:    return intrariPranz
        case .cina:     return intrariCina
        case .gustare:  return intrariGustare
        }
    }

    /// Adaugă o intrare la slotul specificat
    func adaugaIntrare(_ intrare: IntrareAliment, laSlot slot: SlotMasa) {
        switch slot {
        case .micDejun: intrariMicDejun.append(intrare)
        case .pranz:    intrariPranz.append(intrare)
        case .cina:     intrariCina.append(intrare)
        case .gustare:  intrariGustare.append(intrare)
        }
    }

    /// Șterge o intrare dintr-un slot
    func stergeIntrare(laIndex index: Int, dinSlot slot: SlotMasa) {
        switch slot {
        case .micDejun:
            guard index < intrariMicDejun.count else { return }
            intrariMicDejun.remove(at: index)
        case .pranz:
            guard index < intrariPranz.count else { return }
            intrariPranz.remove(at: index)
        case .cina:
            guard index < intrariCina.count else { return }
            intrariCina.remove(at: index)
        case .gustare:
            guard index < intrariGustare.count else { return }
            intrariGustare.remove(at: index)
        }
    }

    /// Kcal disponibili ajustați cu caloriile arse
    func kcalDisponibiliAjustati(tinta: Double) -> Double {
        (tinta - kcalConsumate) + caloriiArseActiv
    }
}

// MARK: - IntrareAliment
/// O intrare individuală de aliment/rețetă într-un slot de masă
@Model
final class IntrareAliment {

    // MARK: - Identificare
    var id: UUID
    var numeAliment: String
    var cantitateGrame: Double
    var oraLogare: Date

    // MARK: - Valori Nutritive (totale pentru cantitate)
    var kcal: Double
    var proteine: Double
    var carbo: Double
    var grasimi: Double

    // MARK: - Referință Rețetă (opțional)
    var esteRinReteta: Bool
    var numarPortiiRinReteta: Double

    // MARK: - Slot Masă (pentru context)
    var slotMasa: SlotMasa

    // MARK: - Init (din ingredient)
    init(
        numeAliment: String,
        cantitateGrame: Double,
        kcal: Double,
        proteine: Double,
        carbo: Double,
        grasimi: Double,
        slotMasa: SlotMasa,
        esteRinReteta: Bool = false,
        numarPortiiRinReteta: Double = 1
    ) {
        self.id = UUID()
        self.numeAliment = numeAliment
        self.cantitateGrame = cantitateGrame
        self.kcal = kcal
        self.proteine = proteine
        self.carbo = carbo
        self.grasimi = grasimi
        self.slotMasa = slotMasa
        self.esteRinReteta = esteRinReteta
        self.numarPortiiRinReteta = numarPortiiRinReteta
        self.oraLogare = Date()
    }

    // MARK: - Factory din Rețetă
    static func dinReteta(_ reteta: Reteta, slot: SlotMasa, portii: Double = 1) -> IntrareAliment {
        IntrareAliment(
            numeAliment: reteta.nume,
            cantitateGrame: Double(reteta.ingrediente.reduce(0) { $0 + $1.cantitateGrame }) * portii,
            kcal: reteta.kcalPerPortie * portii,
            proteine: reteta.proteinePerPortie * portii,
            carbo: reteta.carboPerPortie * portii,
            grasimi: reteta.grasimiPerPortie * portii,
            slotMasa: slot,
            esteRinReteta: true,
            numarPortiiRinReteta: portii
        )
    }

    // MARK: - Factory din Ingredient
    static func dinIngredient(_ ingredient: Ingredient, slot: SlotMasa) -> IntrareAliment {
        IntrareAliment(
            numeAliment: ingredient.nume,
            cantitateGrame: ingredient.cantitateGrame,
            kcal: ingredient.kcalTotal,
            proteine: ingredient.proteineTotal,
            carbo: ingredient.carboTotal,
            grasimi: ingredient.grasimiTotal,
            slotMasa: slot
        )
    }
}
