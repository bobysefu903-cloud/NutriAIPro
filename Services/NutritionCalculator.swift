// MARK: - NutritionCalculator.swift
// NutriAI Pro — Calculator nutrițional pur (fără efecte secundare)
// Platformă: iOS 17+

import Foundation

// MARK: - Rezultat Calcul
/// Structură care conține toate valorile calculate pentru un profil
struct RezultatCalcul {
    let bmr: Double
    let tdee: Double
    let imc: Double
    let categorieIMC: CategorieIMC
    let tintaKcal: Double
    let tintaProteine: Double
    let tintaCarbo: Double
    let tintaGrasimi: Double
    let tintaApa: Double
}

// MARK: - Calculator Nutriție
/// Funcții pure pentru calculul tuturor valorilor nutriționale.
/// Nu are stare internă — toate funcțiile sunt statice.
enum CalculatorNutritie {

    // MARK: - Calcul Complet
    /// Calculează toate valorile pentru un profil dat
    static func calculeazaComplet(
        varsta: Int,
        greutate: Double,
        inaltime: Double,
        gen: Gen,
        nivelActivitate: NivelActivitate,
        obiectiv: Obiectiv
    ) -> RezultatCalcul {

        let bmr    = calculeazaBMR(varsta: varsta, greutate: greutate, inaltime: inaltime, gen: gen)
        let tdee   = calculeazaTDEE(bmr: bmr, nivelActivitate: nivelActivitate)
        let imc    = calculeazaIMC(greutate: greutate, inaltime: inaltime)
        let catIMC = CategorieIMC.dinValoare(imc)
        let tintaKcal = calculeazaTintaKcal(tdee: tdee, obiectiv: obiectiv)
        let macros = calculeazaMacronutrienti(kcal: tintaKcal, greutate: greutate, obiectiv: obiectiv)
        let apa    = calculeazaTintaApa(greutate: greutate, nivelActivitate: nivelActivitate)

        return RezultatCalcul(
            bmr: bmr,
            tdee: tdee,
            imc: imc,
            categorieIMC: catIMC,
            tintaKcal: tintaKcal,
            tintaProteine: macros.proteine,
            tintaCarbo: macros.carbo,
            tintaGrasimi: macros.grasimi,
            tintaApa: apa
        )
    }

    // MARK: - BMR (Mifflin-St Jeor)
    /// Formula Mifflin-St Jeor pentru rata metabolică bazală
    /// - Masculin: (10 × greutate) + (6.25 × înălțime) - (5 × vârstă) + 5
    /// - Feminin:  (10 × greutate) + (6.25 × înălțime) - (5 × vârstă) - 161
    static func calculeazaBMR(
        varsta: Int,
        greutate: Double,
        inaltime: Double,
        gen: Gen
    ) -> Double {
        let baza = (10 * greutate) + (6.25 * inaltime) - (5 * Double(varsta))
        switch gen {
        case .masculin: return baza + 5
        case .feminin:  return baza - 161
        }
    }

    // MARK: - TDEE
    /// Totalul energiei cheltuită zilnic = BMR × multiplicator activitate
    static func calculeazaTDEE(bmr: Double, nivelActivitate: NivelActivitate) -> Double {
        bmr * nivelActivitate.multiplicator
    }

    // MARK: - IMC
    /// Indice Masă Corporală = greutate(kg) / (înălțime(m))²
    static func calculeazaIMC(greutate: Double, inaltime: Double) -> Double {
        let inaltimeM = inaltime / 100.0
        guard inaltimeM > 0 else { return 0 }
        return greutate / (inaltimeM * inaltimeM)
    }

    // MARK: - Țintă Calorii
    /// Calculează targetul caloric pe baza TDEE și obiectivului
    static func calculeazaTintaKcal(tdee: Double, obiectiv: Obiectiv) -> Double {
        max(1200, tdee + obiectiv.ajustareCaloriica)
    }

    // MARK: - Macronutrienți
    /// Structură internă pentru rezultatul calculului macronutrienților
    struct MacronutrientiZilnici {
        let proteine: Double  // grame
        let carbo: Double     // grame
        let grasimi: Double   // grame
    }

    /// Calculează distribuția optimă a macronutrienților pe baza obiectivului
    ///
    /// Repartizare calorii:
    /// - 1g Proteină  = 4 kcal
    /// - 1g Carbohidrat = 4 kcal
    /// - 1g Grăsime  = 9 kcal
    static func calculeazaMacronutrienti(
        kcal: Double,
        greutate: Double,
        obiectiv: Obiectiv
    ) -> MacronutrientiZilnici {

        let gPerKgProteine: Double
        let procentGrasimi: Double

        switch obiectiv {
        case .mentinere:
            // 30% P | 40% C | 30% G
            gPerKgProteine = 1.8
            procentGrasimi = 0.30
        case .slabireModerate:
            // 35% P | 40% C | 25% G
            gPerKgProteine = 2.0
            procentGrasimi = 0.25
        case .crestereMusculara:
            // 30% P | 45% C | 25% G
            gPerKgProteine = 2.2
            procentGrasimi = 0.25
        case .deficitAgresiv:
            // 40% P | 35% C | 25% G
            gPerKgProteine = 2.4
            procentGrasimi = 0.25
        }

        let proteineGr = min(gPerKgProteine * greutate, kcal * 0.45 / 4)  // max 45% din kcal
        let grasimiGr  = (kcal * procentGrasimi) / 9
        let proteineKcal = proteineGr * 4
        let grasimiKcal  = grasimiGr * 9
        let carboKcal = max(0, kcal - proteineKcal - grasimiKcal)
        let carboGr = carboKcal / 4

        return MacronutrientiZilnici(
            proteine: proteineGr.rounded(),
            carbo: carboGr.rounded(),
            grasimi: grasimiGr.rounded()
        )
    }

    // MARK: - Țintă Apă
    /// 35ml per kg greutate corporală, +500ml dacă este activ
    static func calculeazaTintaApa(
        greutate: Double,
        nivelActivitate: NivelActivitate
    ) -> Double {
        let baza = greutate * 35  // ml
        let bonus: Double = nivelActivitate == .sedentar ? 0 : 500
        return (baza + bonus).rounded()
    }

    // MARK: - Procentaj Progres
    /// Calculează procentajul de progres (0.0 – 1.0), cu clipare la 1.0
    static func procentajProgres(consumat: Double, tinta: Double) -> Double {
        guard tinta > 0 else { return 0 }
        return min(consumat / tinta, 1.0)
    }

    // MARK: - Formatare Număr
    /// Formatează un Double cu un număr specificat de zecimale
    static func formateaza(_ valoare: Double, zecimale: Int = 1) -> String {
        String(format: "%.\(zecimale)f", valoare)
    }

    // MARK: - Greutate Ideală (Devine/Robinson)
    /// Calculează plaja de greutate ideală conform formulei Robinson
    static func greutateIdeala(inaltime: Double, gen: Gen) -> ClosedRange<Double> {
        let inaltimeCmPesteBaza = max(0, inaltime - 152.4)
        let inchiExtra = inaltimeCmPesteBaza / 2.54

        let baza: Double
        let perInch: Double

        switch gen {
        case .masculin:
            baza = 52.0
            perInch = 1.9
        case .feminin:
            baza = 49.0
            perInch = 1.7
        }

        let greutateIdealaMedie = baza + perInch * inchiExtra
        return (greutateIdealaMedie - 5)...(greutateIdealaMedie + 5)
    }

    // MARK: - Kilograme de Pierdut/Câștigat
    static func kilogameDeModificat(greutate: Double, inaltime: Double, gen: Gen) -> Double {
        let plajaIdeala = greutateIdeala(inaltime: inaltime, gen: gen)
        if greutate < plajaIdeala.lowerBound {
            return greutate - plajaIdeala.lowerBound  // negativ = de luat în greutate
        } else if greutate > plajaIdeala.upperBound {
            return greutate - plajaIdeala.upperBound  // pozitiv = de dat jos
        }
        return 0
    }

    // MARK: - Timp Estimat Obiectiv
    /// Estimează numărul de săptămâni pentru atingerea obiectivului
    static func timpEstimatSaptamani(
        greutate: Double,
        inaltime: Double,
        gen: Gen,
        obiectiv: Obiectiv
    ) -> Int? {
        let kgDeModificat = abs(kilogameDeModificat(greutate: greutate, inaltime: inaltime, gen: gen))
        guard kgDeModificat > 0 else { return nil }

        let deficitPerSaptamana: Double
        switch obiectiv {
        case .slabireModerate:  deficitPerSaptamana = 0.4   // kg/săpt
        case .deficitAgresiv:   deficitPerSaptamana = 0.8   // kg/săpt
        case .crestereMusculara: deficitPerSaptamana = 0.25 // kg/săpt (masă musculară)
        case .mentinere:        return nil
        }

        return Int((kgDeModificat / deficitPerSaptamana).rounded(.up))
    }
}
