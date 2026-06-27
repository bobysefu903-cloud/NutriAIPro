// MARK: - DashboardViewModel.swift
// NutriAI Pro — ViewModel pentru dashboard-ul zilnic
// Platformă: iOS 17+ | MVVM | SwiftData

import Foundation
import SwiftUI
import SwiftData
import Combine

// MARK: - ViewModel Dashboard
@Observable
final class DashboardViewModel {

    // MARK: - Referințe
    private var modelContext: ModelContext?

    // MARK: - Profil & Jurnal
    var profil: ProfilUtilizator?
    var jurnalAzi: JurnalZilnic?

    // MARK: - Date HealthKit (reflectate din manager)
    var caloriiArse: Double = 0
    var pasi: Int = 0
    var distantaKm: Double = 0

    // MARK: - Stare UI
    var slotSelectat: SlotMasa? = nil
    var seAfisezaAdaugaMasa: Bool = false
    var seAfisezaApaDialog: Bool = false
    var seAnimaRings: Bool = false
    var dataAcum: Date = Date()
    var seReincarca: Bool = false

    // MARK: - Date Calculate (pentru macro rings)

    var kcalConsumate: Double { jurnalAzi?.kcalConsumate ?? 0 }
    var proteineConsumate: Double { jurnalAzi?.proteineConsumate ?? 0 }
    var carboConsumate: Double { jurnalAzi?.carboConsumate ?? 0 }
    var grasimiConsumate: Double { jurnalAzi?.grasimiConsumate ?? 0 }
    var apaConsumataML: Double { jurnalAzi?.apaConsumataML ?? 0 }

    var kcalTinta: Double {
        guard let profil else { return 2000 }
        // Ajustăm targetul caloric cu caloriile arse (HealthKit)
        return profil.tintaKcal + caloriiArse
    }

    var kcalRamase: Double { max(0, kcalTinta - kcalConsumate) }
    var proteineRamase: Double { max(0, (profil?.tintaProteine ?? 0) - proteineConsumate) }
    var carboRamase: Double { max(0, (profil?.tintaCarbo ?? 0) - carboConsumate) }
    var grasimiRamase: Double { max(0, (profil?.tintaGrasimi ?? 0) - grasimiConsumate) }
    var apaRamasaML: Double { max(0, (profil?.tintaApa ?? 2500) - apaConsumataML) }

    // MARK: - Procentaje Ring (0.0 - 1.0)
    var procentKcal: Double {
        CalculatorNutritie.procentajProgres(consumat: kcalConsumate, tinta: kcalTinta)
    }
    var procentProteine: Double {
        CalculatorNutritie.procentajProgres(consumat: proteineConsumate, tinta: profil?.tintaProteine ?? 1)
    }
    var procentCarbo: Double {
        CalculatorNutritie.procentajProgres(consumat: carboConsumate, tinta: profil?.tintaCarbo ?? 1)
    }
    var procentGrasimi: Double {
        CalculatorNutritie.procentajProgres(consumat: grasimiConsumate, tinta: profil?.tintaGrasimi ?? 1)
    }
    var procentApa: Double {
        CalculatorNutritie.procentajProgres(consumat: apaConsumataML, tinta: profil?.tintaApa ?? 2500)
    }

    // MARK: - Salut Personalizat
    var salutPersonalizat: String {
        let ora = Calendar.current.component(.hour, from: dataAcum)
        let prefix: String
        switch ora {
        case 5..<12:  prefix = "Bună dimineața"
        case 12..<18: prefix = "Bună ziua"
        case 18..<22: prefix = "Bună seara"
        default:      prefix = "Noapte bună"
        }
        return "\(prefix), \(profil?.numeUtilizator ?? "Utilizator")! 👋"
    }

    // MARK: - Data Formatată
    var dataFormatayta: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: dataAcum).capitalized
    }

    // MARK: - Status Progres Zilnic
    var statusProgres: StatusProgres {
        if procentKcal >= 0.95 && procentKcal <= 1.05 {
            return .perfect
        } else if procentKcal > 1.05 {
            return .depasit
        } else if procentKcal >= 0.8 {
            return .bun
        } else {
            return .insuficient
        }
    }

    // MARK: - Init
    init() {
        self.dataAcum = Date()
    }

    // MARK: - Configurare Context
    func configureaza(context: ModelContext) {
        self.modelContext = context
        incarcaDate()
    }

    // MARK: - Încărcare Date
    func incarcaDate() {
        guard let context = modelContext else { return }

        // Încarcă profilul
        let descriptor = FetchDescriptor<ProfilUtilizator>()
        profil = try? context.fetch(descriptor).first

        // Încarcă sau creează jurnalul de azi
        let startZi = Calendar.current.startOfDay(for: Date())
        var jurnalDescriptor = FetchDescriptor<JurnalZilnic>(
            predicate: #Predicate { jurnal in
                jurnal.data >= startZi
            }
        )
        jurnalDescriptor.fetchLimit = 1

        if let jurnal = try? context.fetch(jurnalDescriptor).first {
            jurnalAzi = jurnal
        } else {
            let jurnal = JurnalZilnic(data: Date())
            context.insert(jurnal)
            jurnalAzi = jurnal
            try? context.save()
        }

        // Sincronizare HealthKit
        Task { @MainActor in
            await sincronizeazaHealthKit()
        }

        // Animăm ring-urile la încărcare
        withAnimation(.spring(duration: 0.8).delay(0.3)) {
            seAnimaRings = true
        }
    }

    // MARK: - Sincronizare HealthKit
    func sincronizeazaHealthKit() async {
        let hk = HealthKitManager.shared
        await hk.incarcaDateAzi()
        // HealthKitManager e @MainActor — captăm valorile pe main actor
        let (kcal, pasi, km, kcalHK) = await MainActor.run {
            (hk.caloriiArseAzi, hk.pasiAzi, hk.distantaKmAzi, hk.caloriiArseAzi)
        }
        self.caloriiArse = kcal
        self.pasi = pasi
        self.distantaKm = km
        jurnalAzi?.caloriiArseActiv = kcalHK
        jurnalAzi?.pasi = pasi
        salveaza()
    }

    // MARK: - Adaugă Apă
    func adaugaApa(cantitateML: Double) {
        guard let jurnal = jurnalAzi else { return }
        withAnimation(.spring(duration: 0.4)) {
            jurnal.apaConsumataML = min(jurnal.apaConsumataML + cantitateML, (profil?.tintaApa ?? 3000) * 1.5)
        }
        salveaza()
    }

    func resetApa() {
        guard let jurnal = jurnalAzi else { return }
        withAnimation { jurnal.apaConsumataML = 0 }
        salveaza()
    }

    // MARK: - Adaugă Intrare din Rețetă
    func adaugaReteta(_ reteta: Reteta, laSlot slot: SlotMasa, portii: Double = 1) {
        guard let jurnal = jurnalAzi else { return }
        let intrare = IntrareAliment.dinReteta(reteta, slot: slot, portii: portii)
        withAnimation(.spring(duration: 0.4)) {
            jurnal.adaugaIntrare(intrare, laSlot: slot)
        }
        salveaza()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - Adaugă Intrare Ingredient
    func adaugaIngredient(_ ingredient: Ingredient, laSlot slot: SlotMasa) {
        guard let jurnal = jurnalAzi else { return }
        let intrare = IntrareAliment.dinIngredient(ingredient, slot: slot)
        withAnimation(.spring(duration: 0.4)) {
            jurnal.adaugaIntrare(intrare, laSlot: slot)
        }
        salveaza()
    }

    // MARK: - Adaugă Intrare Directă (din Barcode Scanner)
    /// Adaugă o intrare pre-construită direct în jurnalul de azi (folosit de scanner)
    func adaugaIntrareDirecta(_ intrare: IntrareAliment) {
        guard let jurnal = jurnalAzi else { return }
        withAnimation(.spring(duration: 0.4)) {
            jurnal.adaugaIntrare(intrare, laSlot: intrare.slotMasa)
        }
        salveaza()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - Șterge Intrare
    func stergeIntrare(laIndex index: Int, dinSlot slot: SlotMasa) {
        guard let jurnal = jurnalAzi else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            jurnal.stergeIntrare(laIndex: index, dinSlot: slot)
        }
        salveaza()
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    // MARK: - Salvare
    func salveaza() {
        try? modelContext?.save()
    }

    // MARK: - Reîncărcare (schimbare dată)
    func selecteazaData(_ data: Date) {
        withAnimation(.easeInOut) {
            seReincarca = true
            dataAcum = data
        }
        incarcaDate()
        withAnimation(.easeInOut.delay(0.3)) {
            seReincarca = false
        }
    }

    // MARK: - Kcal Rămase cu Ajustare HealthKit
    var kcalRamaseAjustateText: String {
        let ramase = kcalRamase
        if ramase <= 0 {
            return "0 kcal rămase"
        }
        return "\(Int(ramase)) kcal rămase"
    }

    // MARK: - Macro Text Formatate
    var textRezumatZi: String {
        "\(Int(kcalConsumate)) / \(Int(kcalTinta)) kcal consumate"
    }

    // MARK: - Streak Zile Consecutive
    var streakZile: Int {
        // Implementare simplificată — în producție se verifică jurnalele din ultimele N zile
        return UserDefaults.standard.integer(forKey: "streakZile")
    }
}

// MARK: - Status Progres Zilnic
enum StatusProgres {
    case insuficient, bun, perfect, depasit

    var text: String {
        switch self {
        case .insuficient: return "Sub target"
        case .bun:         return "Pe drumul bun"
        case .perfect:     return "Target atins! 🎯"
        case .depasit:     return "Target depășit"
        }
    }

    var culoare: Color {
        switch self {
        case .insuficient: return Color(hex: "#60A5FA")
        case .bun:         return Color(hex: "#34D399")
        case .perfect:     return Color(hex: "#A78BFA")
        case .depasit:     return Color(hex: "#F87171")
        }
    }

    var icon: String {
        switch self {
        case .insuficient: return "arrow.up.circle"
        case .bun:         return "checkmark.circle"
        case .perfect:     return "star.fill"
        case .depasit:     return "exclamationmark.circle"
        }
    }
}
