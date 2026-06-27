// MARK: - AICoachViewModel.swift
// NutriAI Pro — ViewModel pentru AI Coach
// Platformă: iOS 17+ | MVVM

import Foundation
import SwiftUI
import SwiftData

// MARK: - ViewModel AI Coach
@Observable
final class AICoachViewModel {

    // MARK: - Referință Context
    private var modelContext: ModelContext?

    // MARK: - Stare Plan
    var raspunsAI: RaspunsAI? = nil
    var seProcesaza: Bool = false
    var mesajEroare: String? = nil
    var ziSelectata: Int = 0   // 0 = Luni ... 6 = Duminică

    // MARK: - UI State
    var tabSelectat: TabAICoach = .nutritie
    var seAfisezaSfaturi: Bool = false
    var seAfisezaDetaliiZi: Bool = false
    var seAnimaGradient: Bool = false

    // MARK: - Mesaje Chat (pentru interfața de tip chat)
    var mesajeChat: [MesajChat] = []
    var inputChat: String = ""
    var seProcesazaChatRaspuns: Bool = false

    // MARK: - Init
    init() {
        // Mesaj inițial de bun venit
        mesajeChat.append(MesajChat(
            text: "Bună! Sunt **NutriAI Coach**, asistentul tău personal. 🤖\n\nPot genera un plan săptămânal de nutriție și antrenament personalizat, adaptat obiectivului tău. Apasă **\"Generează Plan\"** pentru a începe!",
            esteAI: true,
            timestamp: Date()
        ))
    }

    // MARK: - Configurare
    func configureaza(context: ModelContext) {
        self.modelContext = context
        incarcaPlanSalvat()
    }

    // MARK: - Generare Plan
    func genereazaPlan(profil: ProfilUtilizator, retete: [Reteta]) async {
        seProcesaza = true
        mesajEroare = nil

        // Adaugă mesaj de confirmare utilizator
        adaugaMesajChat(text: "Generează un plan săptămânal pentru mine.", esteAI: false)

        // Adaugă mesaj de procesare
        adaugaMesajChat(text: "⏳ Analizez datele tale biometrice și creez un plan personalizat...", esteAI: true)

        let serviciu = AIAssistantService.shared
        let raspuns = await serviciu.genereazaPlanSaptamanal(profil: profil, retete: retete)

        seProcesaza = false

        if let raspuns = raspuns {
            self.raspunsAI = raspuns
            salveazaPlan(raspuns)

            // Elimina mesajul "se procesează" și adaugă răspunsul final
            mesajeChat.removeLast()
            adaugaMesajChat(text: raspuns.mesajPersonalizat, esteAI: true)

            // Animatie de apariție
            withAnimation(.spring(duration: 0.6)) {
                seAnimaGradient = true
            }
        } else {
            let eroare = await MainActor.run { serviciu.mesajEroare }
            mesajEroare = eroare ?? "Eroare necunoscută la generarea planului."
            mesajeChat.removeLast()
            adaugaMesajChat(text: "⚠️ A apărut o eroare. Încearcă din nou.", esteAI: true)
        }
    }

    // MARK: - Ajustare Dinamică
    func ajusteazaPlan(profil: ProfilUtilizator, dashboardVM: DashboardViewModel) async {
        let serviciu = AIAssistantService.shared
        let mesaj = await serviciu.ajusteazaPlanDinamic(
            profil: profil,
            caloriiConsumate: dashboardVM.kcalConsumate,
            caloriiTinta: dashboardVM.kcalTinta
        )

        adaugaMesajChat(text: mesaj, esteAI: true)
    }

    // MARK: - Trimitere Mesaj Chat
    func trimiteMesajChat(profil: ProfilUtilizator) {
        guard !inputChat.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let textUtilizator = inputChat
        inputChat = ""
        adaugaMesajChat(text: textUtilizator, esteAI: false)

        seProcesazaChatRaspuns = true

        Task {
            try? await Task.sleep(for: .seconds(1.5))

            // Răspuns mock contextual
            let raspuns = genereazaRaspunsContextual(intrebare: textUtilizator, profil: profil)
            adaugaMesajChat(text: raspuns, esteAI: true)
            seProcesazaChatRaspuns = false
        }
    }

    // MARK: - Răspuns Contextual Mock
    private func genereazaRaspunsContextual(intrebare: String, profil: ProfilUtilizator) -> String {
        let intrebareLower = intrebare.lowercased()

        if intrebareLower.contains("proteina") || intrebareLower.contains("proteică") {
            return "🥩 Targetul tău de proteine este **\(Int(profil.tintaProteine))g/zi**. Distribuie-le în cele 4 mese pentru sinteza proteică optimă. Surse recomandate: piept de pui, ouă, brânză de vaci, ton."
        } else if intrebareLower.contains("apa") || intrebareLower.contains("hidratare") {
            return "💧 Trebuie să bei **\(Int(profil.tintaApa))ml de apă** zilnic. Setează un reminder la fiecare 2 ore. Deshidratarea chiar și de 2% reduce performanța cognitivă și fizică."
        } else if intrebareLower.contains("antrenament") || intrebareLower.contains("exercitii") {
            return "💪 Planul tău de antrenament este generat în tab-ul **Antrenament**. Bazat pe obiectivul tău (\(profil.obiectiv.rawValue)), ai sesiuni de 45-65 minute cu intensitate progresivă."
        } else if intrebareLower.contains("calorii") || intrebareLower.contains("caloric") {
            return "🔥 Targetul tău caloric zilnic este **\(Int(profil.tintaKcal)) kcal** (TDEE \(Int(profil.tdee)) kcal ± ajustare obiectiv). Urmărind dashboard-ul, poți vedea progresul în timp real."
        } else if intrebareLower.contains("slabit") || intrebareLower.contains("pierdere") {
            return "⚡ Pentru pierderea în greutate, deficitul caloric este regele. Focusează-te pe: 1) Menținerea proteinelor ridicate, 2) Antrenament de forță pentru a păstra masa musculară, 3) Somn 7-9h."
        } else if intrebareLower.contains("muschi") || intrebareLower.contains("masa musculara") {
            return "💪 Creșterea musculară necesită: surplus caloric de 200-400 kcal, proteine 2-2.2g/kg, antrenament de forță progresiv și somn suficient. Creatina monohidrat este suplimentul cel mai eficient dovedit științific."
        } else if intrebareLower.contains("plan") && intrebareLower.contains("genereaza") {
            return "Apasă butonul **\"Generează Plan\"** din partea de sus a ecranului pentru a crea un plan nutrițional și de antrenament adaptat profilului tău! 🚀"
        } else {
            return "💡 Poți să mă întrebi despre nutriție, calorii, macronutrienți, antrenament sau sfaturi personalizate. Sunt aici să te ajut să îți atingi obiectivul de **\(profil.obiectiv.rawValue)**!"
        }
    }

    // MARK: - Helper: Adaugă Mesaj Chat
    private func adaugaMesajChat(text: String, esteAI: Bool) {
        let mesaj = MesajChat(text: text, esteAI: esteAI, timestamp: Date())
        withAnimation(.spring(duration: 0.4)) {
            mesajeChat.append(mesaj)
        }
    }

    // MARK: - Salvare Plan în UserDefaults (simplificat)
    private func salveazaPlan(_ raspuns: RaspunsAI) {
        if let data = try? JSONEncoder().encode(raspuns) {
            UserDefaults.standard.set(data, forKey: "ultimulPlanAI")
            UserDefaults.standard.set(Date(), forKey: "dataUltimulPlan")
        }
    }

    // MARK: - Încărcare Plan Salvat
    private func incarcaPlanSalvat() {
        if let data = UserDefaults.standard.data(forKey: "ultimulPlanAI"),
           let raspuns = try? JSONDecoder().decode(RaspunsAI.self, from: data) {
            self.raspunsAI = raspuns
            if let data = UserDefaults.standard.object(forKey: "dataUltimulPlan") as? Date {
                let zile = Calendar.current.dateComponents([.day], from: data, to: Date()).day ?? 0
                if zile < 7 {
                    adaugaMesajChat(text: "Am găsit planul tău din \(zile == 0 ? "azi" : "acum \(zile) zile"). Poți genera unul nou oricând! 🔄", esteAI: true)
                }
            }
        }
    }

    // MARK: - Accesori Plan Curent
    var ziNutritieCurenta: ZiNutritie? {
        raspunsAI?.planNutritional.saptamana[safe: ziSelectata]
    }

    var ziAntrenamentCurenta: ZiAntrenament? {
        raspunsAI?.planAntrenament.saptamana[safe: ziSelectata]
    }

    var totalKcalMedieSaptamana: Double {
        guard let plan = raspunsAI else { return 0 }
        let total = plan.planNutritional.saptamana.reduce(0) { $0 + $1.totalKcal }
        return total / Double(plan.planNutritional.saptamana.count)
    }

    var dataUltimeiGenerari: String {
        guard let raspuns = raspunsAI else { return "Niciodată" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.dateFormat = "d MMMM 'la' HH:mm"
        return formatter.string(from: raspuns.dataGenerare)
    }
}

// MARK: - Tab AI Coach
enum TabAICoach: String, CaseIterable {
    case nutritie   = "Nutriție"
    case antrenament = "Antrenament"
    case chat       = "Chat AI"
    case sfaturi    = "Sfaturi"

    var icon: String {
        switch self {
        case .nutritie:    return "fork.knife"
        case .antrenament: return "dumbbell.fill"
        case .chat:        return "bubble.left.and.bubble.right.fill"
        case .sfaturi:     return "lightbulb.fill"
        }
    }
}

// MARK: - Mesaj Chat
struct MesajChat: Identifiable {
    var id = UUID()
    var text: String
    var esteAI: Bool
    var timestamp: Date
}

// MARK: - Safe Array Subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
