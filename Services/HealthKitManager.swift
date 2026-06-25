// MARK: - HealthKitManager.swift
// NutriAI Pro — Integrare HealthKit
// Platformă: iOS 17+
//
// NOTĂ: Asigurați-vă că în Info.plist există:
//   NSHealthShareUsageDescription
//   NSHealthUpdateUsageDescription
// HealthKit funcționează DOAR pe dispozitiv fizic, nu pe Simulator.

import Foundation
import HealthKit
import Combine

// MARK: - Manager HealthKit
/// Gestionează permisiunile și citirea datelor din HealthKit.
/// Publică actualizări reactive via @Published pentru UI.
@MainActor
final class HealthKitManager: ObservableObject {

    // MARK: - Singleton
    static let shared = HealthKitManager()

    // MARK: - Stare
    @Published var esteAutorizat: Bool = false
    @Published var esteDisponibil: Bool = HKHealthStore.isHealthDataAvailable()
    @Published var caloriiArseAzi: Double = 0
    @Published var pasiAzi: Int = 0
    @Published var distantaKmAzi: Double = 0
    @Published var mesajEroare: String? = nil

    // MARK: - Private
    private let store = HKHealthStore()
    private var interogariActive: Set<HKQuery> = []

    // MARK: - Tipuri de Date Cerute
    private var tipuriLectura: Set<HKQuantityType> {
        var tipuri: Set<HKQuantityType> = []

        if let calorii = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            tipuri.insert(calorii)
        }
        if let pasi = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            tipuri.insert(pasi)
        }
        if let distanta = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            tipuri.insert(distanta)
        }
        return tipuri
    }

    // MARK: - Init
    private init() {
        if esteDisponibil {
            Task { await verificaStareAutorizare() }
        }
    }

    // MARK: - Cerere Permisiuni
    /// Solicită autorizarea utilizatorului pentru accesul la datele HealthKit.
    func solicitaPermisiuni() async {
        guard esteDisponibil else {
            mesajEroare = "HealthKit nu este disponibil pe acest dispozitiv."
            return
        }

        do {
            try await store.requestAuthorization(toShare: [], read: tipuriLectura)
            await verificaStareAutorizare()
            if esteAutorizat {
                await incarcaDateAzi()
                pornesteMontorizareaInTimRealCalori()
            }
        } catch {
            mesajEroare = "Eroare la solicitarea permisiunilor HealthKit: \(error.localizedDescription)"
        }
    }

    // MARK: - Verificare Stare Autorizare
    private func verificaStareAutorizare() async {
        guard let tip = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let stare = store.authorizationStatus(for: tip)
        esteAutorizat = (stare == .sharingAuthorized)
    }

    // MARK: - Încărcare Date Azi
    /// Încarcă toate datele disponibile pentru ziua curentă
    func incarcaDateAzi() async {
        async let calorii = fetchCaloriiArseAzi()
        async let pasi = fetchPasiAzi()
        async let distanta = fetchDistantaAzi()

        self.caloriiArseAzi = await calorii
        self.pasiAzi        = await pasi
        self.distantaKmAzi  = await distanta
    }

    // MARK: - Calorii Arse Azi
    /// Returnează totalul caloriilor arse activ în ziua curentă.
    func fetchCaloriiArseAzi() async -> Double {
        guard esteDisponibil,
              let tip = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0
        }

        return await withCheckedContinuation { continuation in
            let predicat = HKQuery.predicateForSamples(
                withStart: Calendar.current.startOfDay(for: Date()),
                end: Date(),
                options: .strictStartDate
            )

            let query = HKStatisticsQuery(
                quantityType: tip,
                quantitySamplePredicate: predicat,
                options: .cumulativeSum
            ) { _, result, error in
                if let eroare = error {
                    print("🔴 HealthKit - Eroare calorii: \(eroare.localizedDescription)")
                    continuation.resume(returning: 0)
                    return
                }
                let valoare = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                continuation.resume(returning: valoare)
            }

            store.execute(query)
        }
    }

    // MARK: - Pași Azi
    func fetchPasiAzi() async -> Int {
        guard esteDisponibil,
              let tip = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }

        return await withCheckedContinuation { continuation in
            let predicat = HKQuery.predicateForSamples(
                withStart: Calendar.current.startOfDay(for: Date()),
                end: Date(),
                options: .strictStartDate
            )

            let query = HKStatisticsQuery(
                quantityType: tip,
                quantitySamplePredicate: predicat,
                options: .cumulativeSum
            ) { _, result, error in
                if let eroare = error {
                    print("🔴 HealthKit - Eroare pași: \(eroare.localizedDescription)")
                    continuation.resume(returning: 0)
                    return
                }
                let valoare = Int(result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
                continuation.resume(returning: valoare)
            }

            store.execute(query)
        }
    }

    // MARK: - Distanță Azi
    func fetchDistantaAzi() async -> Double {
        guard esteDisponibil,
              let tip = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return 0
        }

        return await withCheckedContinuation { continuation in
            let predicat = HKQuery.predicateForSamples(
                withStart: Calendar.current.startOfDay(for: Date()),
                end: Date(),
                options: .strictStartDate
            )

            let query = HKStatisticsQuery(
                quantityType: tip,
                quantitySamplePredicate: predicat,
                options: .cumulativeSum
            ) { _, result, error in
                let valoare = result?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                continuation.resume(returning: valoare / 1000.0)
            }

            store.execute(query)
        }
    }

    // MARK: - Monitorizare în Timp Real
    /// Pornește un HKObserverQuery pentru actualizări live ale caloriilor
    private func pornesteMontorizareaInTimRealCalori() {
        guard let tip = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        let query = HKObserverQuery(sampleType: tip, predicate: nil) { [weak self] _, _, error in
            guard error == nil else { return }
            Task { @MainActor [weak self] in
                self?.caloriiArseAzi = await self?.fetchCaloriiArseAzi() ?? 0
            }
        }

        store.execute(query)
        store.enableBackgroundDelivery(for: tip, frequency: .immediate) { _, _ in }
        interogariActive.insert(query)
    }

    // MARK: - Date din Ultimele N Zile
    /// Returnează istoricul caloriilor arse pentru grafice
    func fetchIstoricCaloriiArseSaptamana() async -> [(data: Date, calorii: Double)] {
        var rezultate: [(Date, Double)] = []

        for zi in 0..<7 {
            guard let dataZi = Calendar.current.date(byAdding: .day, value: -zi, to: Date()) else { continue }
            let startZi = Calendar.current.startOfDay(for: dataZi)
            guard let endZi = Calendar.current.date(byAdding: .day, value: 1, to: startZi) else { continue }

            guard let tip = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { continue }

            let calorii = await withCheckedContinuation { continuation in
                let predicat = HKQuery.predicateForSamples(withStart: startZi, end: endZi, options: .strictStartDate)
                let query = HKStatisticsQuery(quantityType: tip, quantitySamplePredicate: predicat, options: .cumulativeSum) { _, result, _ in
                    let val = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                    continuation.resume(returning: val)
                }
                store.execute(query)
            }

            rezultate.append((startZi, calorii))
        }

        return rezultate.reversed()
    }

    // MARK: - Reset / Cleanup
    func opresteMontorizarea() {
        for query in interogariActive {
            store.stop(query)
        }
        interogariActive.removeAll()
    }

    // MARK: - Mock pentru Simulator
    /// Generează date simulate pentru testare pe Simulator
    func aplicaDateSimulate() {
        caloriiArseAzi = Double.random(in: 200...650)
        pasiAzi = Int.random(in: 4000...12000)
        distantaKmAzi = Double.random(in: 2.5...9.0)
        esteAutorizat = true
    }
}

// MARK: - Extensie Formatare
extension HealthKitManager {
    var pasiFormatayi: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: pasiAzi)) ?? "\(pasiAzi)"
    }

    var distantaFormatayta: String {
        String(format: "%.1f km", distantaKmAzi)
    }

    var caloriiArseFormatayte: String {
        String(format: "%.0f kcal", caloriiArseAzi)
    }
}
