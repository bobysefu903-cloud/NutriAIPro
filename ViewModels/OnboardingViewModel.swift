// MARK: - OnboardingViewModel.swift
// NutriAI Pro — ViewModel pentru fluxul de onboarding
// Platformă: iOS 17+ | MVVM | SwiftData

import Foundation
import SwiftUI
import SwiftData

// MARK: - ViewModel Onboarding
/// Gestionează starea și logica tuturor celor 5 ecrane de onboarding.
/// Folosește @Observable pentru reactivitate modernă iOS 17.
@Observable
final class OnboardingViewModel {

    // MARK: - Navigare
    var paginaCurenta: Int = 0
    var onboardingFinalizat: Bool = false

    // MARK: - Inputs Biometrice
    var numeUtilizator: String = ""
    var varsta: Double = 25
    var greutate: Double = 75.0
    var inaltime: Double = 175.0
    var genSelectat: Gen = .masculin
    var nivelActivitate: NivelActivitate = .moderat

    // MARK: - Obiectiv Selectat
    var obiectivSelectat: Obiectiv? = nil

    // MARK: - Rezultate Calculate
    var bmr: Double = 0
    var tdee: Double = 0
    var imc: Double = 0
    var categorieIMC: CategorieIMC = .normal

    // MARK: - Ținte Macro
    var tintaKcal: Double = 0
    var tintaProteine: Double = 0
    var tintaCarbo: Double = 0
    var tintaGrasimi: Double = 0
    var tintaApa: Double = 0

    // MARK: - Stare UI
    var seAfisezaEroare: Bool = false
    var mesajEroare: String = ""
    var seAnimaRezultate: Bool = false

    // MARK: - Calcule Live
    /// Calculează IMC live în timp ce utilizatorul schimbă greutatea/înălțimea
    var imcLive: Double {
        CalculatorNutritie.calculeazaIMC(greutate: greutate, inaltime: inaltime)
    }

    var categorieIMCLive: CategorieIMC {
        CategorieIMC.dinValoare(imcLive)
    }

    var bmrLive: Double {
        CalculatorNutritie.calculeazaBMR(
            varsta: Int(varsta),
            greutate: greutate,
            inaltime: inaltime,
            gen: genSelectat
        )
    }

    var tdeeLive: Double {
        CalculatorNutritie.calculeazaTDEE(bmr: bmrLive, nivelActivitate: nivelActivitate)
    }

    // MARK: - Validare Input
    var inputuriBiometriceValide: Bool {
        varsta >= 13 && varsta <= 100 &&
        greutate >= 30 && greutate <= 300 &&
        inaltime >= 100 && inaltime <= 250 &&
        !numeUtilizator.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var obiectivSelectatValid: Bool {
        obiectivSelectat != nil
    }

    // MARK: - Calcul Final la Selecția Obiectivului
    /// Rulat când utilizatorul selectează un obiectiv — calculează toate valorile finale
    func calculeazaValoriFinale(obiectiv: Obiectiv) {
        self.obiectivSelectat = obiectiv

        let rezultat = CalculatorNutritie.calculeazaComplet(
            varsta: Int(varsta),
            greutate: greutate,
            inaltime: inaltime,
            gen: genSelectat,
            nivelActivitate: nivelActivitate,
            obiectiv: obiectiv
        )

        self.bmr         = rezultat.bmr
        self.tdee        = rezultat.tdee
        self.imc         = rezultat.imc
        self.categorieIMC = rezultat.categorieIMC
        self.tintaKcal   = rezultat.tintaKcal
        self.tintaProteine = rezultat.tintaProteine
        self.tintaCarbo  = rezultat.tintaCarbo
        self.tintaGrasimi = rezultat.tintaGrasimi
        self.tintaApa    = rezultat.tintaApa

        // Animăm apariția rezultatelor
        withAnimation(.spring(duration: 0.5)) {
            seAnimaRezultate = true
        }
    }

    // MARK: - Navigare
    func mergeInainte() {
        guard paginaCurenta < 4 else { return }

        // Validare la fiecare pas
        if paginaCurenta == 1 && !inputuriBiometriceValide {
            seAfisezaEroare = true
            mesajEroare = "Completează toate câmpurile corect pentru a continua."
            return
        }

        if paginaCurenta == 2 {
            // Calculăm valorile IMC după inputuri
            bmr = bmrLive
            tdee = tdeeLive
            imc = imcLive
            categorieIMC = categorieIMCLive
        }

        if paginaCurenta == 3 && !obiectivSelectatValid {
            seAfisezaEroare = true
            mesajEroare = "Selectează un obiectiv pentru a continua."
            return
        }

        withAnimation(.easeInOut(duration: 0.35)) {
            paginaCurenta += 1
        }
    }

    func mergeInapoi() {
        guard paginaCurenta > 0 else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            paginaCurenta -= 1
        }
    }

    // MARK: - Finalizare Onboarding
    /// Salvează profilul în SwiftData și marchează onboarding-ul ca finalizat
    func finalizeazaOnboarding(context: ModelContext) {
        guard let obiectiv = obiectivSelectat else { return }

        let profil = ProfilUtilizator(
            varsta: Int(varsta),
            greutate: greutate,
            inaltime: inaltime,
            gen: genSelectat,
            nivelActivitate: nivelActivitate,
            obiectiv: obiectiv,
            numeUtilizator: numeUtilizator.trimmingCharacters(in: .whitespaces)
        )

        context.insert(profil)

        // Salvăm preferința de onboarding finalizat
        UserDefaults.standard.set(true, forKey: "onboardingFinalizat")

        do {
            try context.save()
            withAnimation(.spring(duration: 0.6)) {
                onboardingFinalizat = true
            }
        } catch {
            seAfisezaEroare = true
            mesajEroare = "Eroare la salvarea profilului: \(error.localizedDescription)"
        }
    }

    // MARK: - Formatare Valori pentru UI
    var imcFormatat: String {
        String(format: "%.1f", imc > 0 ? imc : imcLive)
    }

    var bmrFormatat: String {
        String(format: "%.0f kcal/zi", bmr > 0 ? bmr : bmrLive)
    }

    var tdeeFormatat: String {
        String(format: "%.0f kcal/zi", tdee > 0 ? tdee : tdeeLive)
    }

    // MARK: - Greutate Ideală
    var greutateIdealaText: String {
        let plaja = CalculatorNutritie.greutateIdeala(inaltime: inaltime, gen: genSelectat)
        return String(format: "%.0f – %.0f kg", plaja.lowerBound, plaja.upperBound)
    }

    // MARK: - Progres Onboarding (pentru bara de progres)
    var procentajProgres: Double {
        Double(paginaCurenta) / 4.0
    }

    var titluPaginaCurenta: String {
        switch paginaCurenta {
        case 0: return "Bun Venit"
        case 1: return "Date Biometrice"
        case 2: return "Analiza Ta"
        case 3: return "Obiectivul Tău"
        case 4: return "Plan Generat"
        default: return ""
        }
    }
}
