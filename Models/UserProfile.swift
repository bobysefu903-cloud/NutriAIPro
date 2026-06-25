// MARK: - UserProfile.swift
// NutriAI Pro — Profilul utilizatorului (SwiftData @Model)
// Platformă: iOS 17+ | SwiftUI | SwiftData

import Foundation
import SwiftData

/// Profilul complet al utilizatorului — persitat cu SwiftData.
/// Există o singură instanță activă în aplicație.
@Model
final class ProfilUtilizator {

    // MARK: - Date Biometrice
    var varsta: Int           // ani
    var greutate: Double      // kg
    var inaltime: Double      // cm
    var gen: Gen
    var nivelActivitate: NivelActivitate

    // MARK: - Obiectiv & Calcule
    var obiectiv: Obiectiv
    var bmr: Double           // kcal/zi
    var tdee: Double          // kcal/zi
    var imc: Double           // kg/m²
    var categorieIMC: CategorieIMC

    // MARK: - Ținte Zilnice Macronutrienți
    var tintaKcal: Double     // kcal/zi
    var tintaProteine: Double // grame/zi
    var tintaCarbo: Double    // grame/zi
    var tintaGrasimi: Double  // grame/zi
    var tintaApa: Double      // ml/zi

    // MARK: - Metadata
    var dataCreare: Date
    var numeUtilizator: String

    // MARK: - Init
    init(
        varsta: Int = 25,
        greutate: Double = 75,
        inaltime: Double = 175,
        gen: Gen = .masculin,
        nivelActivitate: NivelActivitate = .moderat,
        obiectiv: Obiectiv = .mentinere,
        numeUtilizator: String = "Utilizator"
    ) {
        self.varsta = varsta
        self.greutate = greutate
        self.inaltime = inaltime
        self.gen = gen
        self.nivelActivitate = nivelActivitate
        self.obiectiv = obiectiv
        self.numeUtilizator = numeUtilizator
        self.dataCreare = Date()

        // Calculele sunt efectuate la inițializare
        let calc = CalculatorNutritie.calculeazaComplet(
            varsta: varsta,
            greutate: greutate,
            inaltime: inaltime,
            gen: gen,
            nivelActivitate: nivelActivitate,
            obiectiv: obiectiv
        )
        self.bmr = calc.bmr
        self.tdee = calc.tdee
        self.imc = calc.imc
        self.categorieIMC = calc.categorieIMC
        self.tintaKcal = calc.tintaKcal
        self.tintaProteine = calc.tintaProteine
        self.tintaCarbo = calc.tintaCarbo
        self.tintaGrasimi = calc.tintaGrasimi
        self.tintaApa = calc.tintaApa
    }

    // MARK: - Recalculare
    /// Recalculează toate valorile după modificarea datelor biometrice
    func recalculeaza() {
        let calc = CalculatorNutritie.calculeazaComplet(
            varsta: varsta,
            greutate: greutate,
            inaltime: inaltime,
            gen: gen,
            nivelActivitate: nivelActivitate,
            obiectiv: obiectiv
        )
        self.bmr = calc.bmr
        self.tdee = calc.tdee
        self.imc = calc.imc
        self.categorieIMC = calc.categorieIMC
        self.tintaKcal = calc.tintaKcal
        self.tintaProteine = calc.tintaProteine
        self.tintaCarbo = calc.tintaCarbo
        self.tintaGrasimi = calc.tintaGrasimi
        self.tintaApa = calc.tintaApa
    }
}
