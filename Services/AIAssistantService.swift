// MARK: - AIAssistantService.swift
// NutriAI Pro — Serviciu AI Coach (Mock + OpenAI-Ready)
// Platformă: iOS 17+
//
// === INSTRUȚIUNI DE INTEGRARE OPENAI ===
// 1. Adăugați Config.plist cu cheia: OPENAI_API_KEY = "sk-..."
// 2. Schimbați `modMock = true` în `false`
// 3. Serviciul va folosi automat GPT-4o cu prompturile preconfigurate
// ========================================

import Foundation

// MARK: - Modele de Date AI

/// Răspuns complet al planificatorului AI
struct RaspunsAI: Codable {
    var planNutritional: PlanNutritional
    var planAntrenament: PlanAntrenament
    var sfaturi: [String]
    var mesajPersonalizat: String
    var dataGenerare: Date
}

/// Plan nutrițional săptămânal
struct PlanNutritional: Codable {
    var saptamana: [ZiNutritie]
}

/// Plan de antrenament săptămânal
struct PlanAntrenament: Codable {
    var saptamana: [ZiAntrenament]
    var tipSplit: String
}

/// Planul nutrițional pentru o zi
struct ZiNutritie: Codable, Identifiable {
    var id: UUID = UUID()
    var zi: String           // Luni, Marți, etc.
    var micDejun: [MasaAI]
    var pranz: [MasaAI]
    var cina: [MasaAI]
    var gustare: [MasaAI]
    var totalKcal: Double
    var notaZi: String
}

/// O masă propusă de AI
struct MasaAI: Codable, Identifiable {
    var id: UUID = UUID()
    var numeAliment: String
    var cantitate: String    // ex: "200g", "1 portie"
    var kcal: Double
    var proteine: Double
    var carbo: Double
    var grasimi: Double
    var esteReteta: Bool     // dacă provine din rețetele utilizatorului
}

/// Antrenamentul pentru o zi
struct ZiAntrenament: Codable, Identifiable {
    var id: UUID = UUID()
    var zi: String
    var tipAntrenament: String       // ex: "Push", "Pull", "Picioare", "Cardio"
    var esteZiOdihna: Bool
    var exercitii: [ExercitiiAI]
    var durataMinute: Int
    var intensitate: String          // Ușor / Moderat / Intens
}

/// Un exercițiu din planul AI
struct ExercitiiAI: Codable, Identifiable {
    var id: UUID = UUID()
    var numEx: String
    var serii: Int
    var repetari: String    // ex: "8-12" sau "30 sec"
    var greutate: String    // ex: "70% 1RM" sau "greutatea corpului"
    var notaFormaTehnica: String
}

// MARK: - Serviciu AI
/// Serviciu AI gata pentru OpenAI. În modul mock, returnează date realiste în română.
@MainActor
final class AIAssistantService: ObservableObject {

    // MARK: - Singleton
    static let shared = AIAssistantService()

    // MARK: - Configurare
    /// Schimbați în `false` după adăugarea cheii OpenAI în Config.plist
    private let modMock = true
    private let modelOpenAI = "gpt-4o"
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    // MARK: - Stare Publicată
    @Published var seProcesaza: Bool = false
    @Published var mesajEroare: String? = nil
    @Published var ultimulRaspuns: RaspunsAI? = nil

    // MARK: - Init
    private init() {}

    // MARK: - Generare Plan Săptămânal
    /// Generează un plan personalizat de nutriție și antrenament.
    func genereazaPlanSaptamanal(
        profil: ProfilUtilizator,
        retete: [Reteta]
    ) async -> RaspunsAI? {
        seProcesaza = true
        mesajEroare = nil

        defer { seProcesaza = false }

        if modMock {
            // Simulăm un delay de rețea realist
            try? await Task.sleep(for: .seconds(2.5))
            let raspuns = genereazaRaspunsMock(profil: profil, retete: retete)
            self.ultimulRaspuns = raspuns
            return raspuns
        } else {
            return await apeleazaOpenAI(profil: profil, retete: retete)
        }
    }

    // MARK: - Ajustare Dinamică Plan
    /// Ajustează planul dacă utilizatorul nu a atins targetul caloric
    func ajusteazaPlanDinamic(
        profil: ProfilUtilizator,
        caloriiConsumate: Double,
        caloriiTinta: Double
    ) async -> String {
        let deficit = caloriiTinta - caloriiConsumate

        if modMock {
            try? await Task.sleep(for: .seconds(1.0))
            return genereazaMesajAjustare(deficit: deficit, obiectiv: profil.obiectiv)
        }

        return "Plan ajustat conform datelor tale."
    }

    // MARK: - Răspuns Mock Realist
    private func genereazaRaspunsMock(profil: ProfilUtilizator, retete: [Reteta]) -> RaspunsAI {
        let numeRetet = retete.map { $0.nume }
        let areRetet = !numeRetet.isEmpty

        return RaspunsAI(
            planNutritional: genereazaPlanNutritionalMock(profil: profil, reteteSalvate: numeRetet),
            planAntrenament: genereazaPlanAntrenamentMock(obiectiv: profil.obiectiv, nivelActivitate: profil.nivelActivitate),
            sfaturi: genereazaSfaturiMock(profil: profil, areRetet: areRetet),
            mesajPersonalizat: genereazaMesajPersonalizat(profil: profil),
            dataGenerare: Date()
        )
    }

    // MARK: - Plan Nutrițional Mock
    private func genereazaPlanNutritionalMock(profil: ProfilUtilizator, reteteSalvate: [String]) -> PlanNutritional {
        let zile = ["Luni", "Marți", "Miercuri", "Joi", "Vineri", "Sâmbătă", "Duminică"]

        let ziNutritie = zile.enumerated().map { (index, zi) -> ZiNutritie in
            let esteZiSfarsitSaptamana = index >= 5

            // Varieze mâncărurile în funcție de zi
            let micDejun: [MasaAI]
            let pranz: [MasaAI]
            let cina: [MasaAI]
            let gustare: [MasaAI]

            switch index % 3 {
            case 0:
                micDejun = [
                    MasaAI(numeAliment: reteteSalvate.contains("Omletă cu Legume") ? "Omletă cu Legume" : "Fulgi de Ovăz cu Afine",
                           cantitate: reteteSalvate.contains("Omletă cu Legume") ? "1 porție" : "80g ovăz + 100g afine",
                           kcal: 380, proteine: 28, carbo: 35, grasimi: 12,
                           esteReteta: reteteSalvate.contains("Omletă cu Legume"))
                ]
                pranz = [
                    MasaAI(numeAliment: reteteSalvate.contains("Pui cu Orez") ? "Pui cu Orez" : "Piept de Pui cu Orez",
                           cantitate: "1 porție (350g)",
                           kcal: 520, proteine: 48, carbo: 52, grasimi: 8,
                           esteReteta: reteteSalvate.contains("Pui cu Orez"))
                ]
                cina = [
                    MasaAI(numeAliment: reteteSalvate.contains("Salată de Pui") ? "Salată de Pui" : "Somon cu Broccoli",
                           cantitate: "1 porție",
                           kcal: 420, proteine: 40, carbo: 20, grasimi: 18,
                           esteReteta: reteteSalvate.contains("Salată de Pui"))
                ]
                gustare = [
                    MasaAI(numeAliment: reteteSalvate.contains("Smoothie Proteic") ? "Smoothie Proteic" : "Iaurt Grecesc cu Migdale",
                           cantitate: "1 porție",
                           kcal: 280, proteine: 25, carbo: 18, grasimi: 8,
                           esteReteta: reteteSalvate.contains("Smoothie Proteic"))
                ]

            case 1:
                micDejun = [
                    MasaAI(numeAliment: "Ouă Jumări cu Pâine Integrală",
                           cantitate: "3 ouă + 2 felii pâine",
                           kcal: 420, proteine: 26, carbo: 38, grasimi: 16, esteReteta: false)
                ]
                pranz = [
                    MasaAI(numeAliment: "Paste cu Ton și Roșii",
                           cantitate: "200g paste fierte + 150g ton",
                           kcal: 480, proteine: 42, carbo: 55, grasimi: 6, esteReteta: false)
                ]
                cina = [
                    MasaAI(numeAliment: "Muschi de Vită cu Cartofi la Cuptor",
                           cantitate: "180g vită + 200g cartofi",
                           kcal: 560, proteine: 45, carbo: 42, grasimi: 18, esteReteta: false)
                ]
                gustare = [
                    MasaAI(numeAliment: "Brânză de Vaci cu Fructe de Pădure",
                           cantitate: "200g brânză + 100g fructe",
                           kcal: 220, proteine: 22, carbo: 25, grasimi: 2, esteReteta: false)
                ]

            default:
                micDejun = [
                    MasaAI(numeAliment: "Smoothie de Banana cu Proteină",
                           cantitate: "1 banană + 30g whey + 250ml lapte",
                           kcal: 390, proteine: 35, carbo: 45, grasimi: 5, esteReteta: false)
                ]
                pranz = [
                    MasaAI(numeAliment: "Naut cu Legume și Quinoa",
                           cantitate: "150g naut + 100g quinoa + legume",
                           kcal: 450, proteine: 22, carbo: 65, grasimi: 8, esteReteta: false)
                ]
                cina = [
                    MasaAI(numeAliment: "Pui la Grătar cu Salată de Castraveți",
                           cantitate: "200g pui + salată",
                           kcal: 380, proteine: 42, carbo: 12, grasimi: 10, esteReteta: false)
                ]
                gustare = [
                    MasaAI(numeAliment: "Unt de Arahide cu Mere",
                           cantitate: "30g unt + 1 măr",
                           kcal: 250, proteine: 7, carbo: 28, grasimi: 14, esteReteta: false)
                ]
            }

            let totalKcal = (micDejun + pranz + cina + gustare).reduce(0) { $0 + $1.kcal }
            let notaZi = esteZiSfarsitSaptamana
                ? "Weekend: Permite-ți o masă mai liberă, dar menține hidratarea optimă."
                : "Zi săptămână: Pregătește mesele din timp pentru a evita alegerile impulsive."

            return ZiNutritie(
                zi: zi,
                micDejun: micDejun,
                pranz: pranz,
                cina: cina,
                gustare: gustare,
                totalKcal: totalKcal,
                notaZi: notaZi
            )
        }

        return PlanNutritional(saptamana: ziNutritie)
    }

    // MARK: - Plan Antrenament Mock
    private func genereazaPlanAntrenamentMock(
        obiectiv: Obiectiv,
        nivelActivitate: NivelActivitate
    ) -> PlanAntrenament {

        let tipSplit: String
        let zileAntrenament: [String]
        let zileOdihna: Set<String>

        switch obiectiv {
        case .crestereMusculara:
            tipSplit = "Push/Pull/Legs (PPL Split)"
            zileAntrenament = ["Luni", "Marți", "Miercuri", "Joi", "Vineri", "Sâmbătă", "Duminică"]
            zileOdihna = ["Joi", "Duminică"]
        case .slabireModerate, .deficitAgresiv:
            tipSplit = "Full Body + Cardio"
            zileAntrenament = ["Luni", "Marți", "Miercuri", "Joi", "Vineri", "Sâmbătă", "Duminică"]
            zileOdihna = ["Miercuri", "Duminică"]
        case .mentinere:
            tipSplit = "Upper/Lower Split"
            zileAntrenament = ["Luni", "Marți", "Miercuri", "Joi", "Vineri", "Sâmbătă", "Duminică"]
            zileOdihna = ["Miercuri", "Sâmbătă", "Duminică"]
        }

        let saptamana = zileAntrenament.enumerated().map { (index, zi) -> ZiAntrenament in
            if zileOdihna.contains(zi) {
                return ZiAntrenament(
                    zi: zi,
                    tipAntrenament: "Odihnă Activă",
                    esteZiOdihna: true,
                    exercitii: [
                        ExercitiiAI(numEx: "Plimbare 30-45 min", serii: 1, repetari: "30-45 min",
                                    greutate: "Ritm lejer", notaFormaTehnica: "Menține o postură corectă și respirație regulată.")
                    ],
                    durataMinute: 40,
                    intensitate: "Ușor"
                )
            }

            let (tipAntren, exercitii, durata) = exercitiiPentruZi(index: index, obiectiv: obiectiv)

            return ZiAntrenament(
                zi: zi,
                tipAntrenament: tipAntren,
                esteZiOdihna: false,
                exercitii: exercitii,
                durataMinute: durata,
                intensitate: obiectiv == .deficitAgresiv ? "Intens" : "Moderat"
            )
        }

        return PlanAntrenament(saptamana: saptamana, tipSplit: tipSplit)
    }

    private func exercitiiPentruZi(index: Int, obiectiv: Obiectiv) -> (String, [ExercitiiAI], Int) {
        switch index % 5 {
        case 0: // Push
            return ("Push (Piept, Umeri, Triceps)", [
                ExercitiiAI(numEx: "Flotări / Împins la Bancă", serii: 4, repetari: "8-12",
                            greutate: "70-80% 1RM", notaFormaTehnica: "Coboară lent 3 secunde, explodează sus."),
                ExercitiiAI(numEx: "Presă Militară (Umeri)", serii: 3, repetari: "10-12",
                            greutate: "60-70% 1RM", notaFormaTehnica: "Nu bloca coatele în sus."),
                ExercitiiAI(numEx: "Crossover Cabluri (Pectoral)", serii: 3, repetari: "12-15",
                            greutate: "Greutate moderată", notaFormaTehnica: "Concentrează-te pe contracția pectoralului."),
                ExercitiiAI(numEx: "Extensii Triceps (Coardă)", serii: 3, repetari: "12-15",
                            greutate: "Greutate medie", notaFormaTehnica: "Ține coatele imobile pe lângă corp."),
                ExercitiiAI(numEx: "Lateral Raises (Umeri Laterali)", serii: 4, repetari: "15-20",
                            greutate: "Greutate ușoară", notaFormaTehnica: "Ridică în formă de arc, nu bate umerii.")
            ], 55)

        case 1: // Pull
            return ("Pull (Spate, Biceps)", [
                ExercitiiAI(numEx: "Tracțiuni / Lat Pulldown", serii: 4, repetari: "6-10",
                            greutate: "Greutatea corpului / 75% 1RM", notaFormaTehnica: "Omoplații jos înainte de a trage."),
                ExercitiiAI(numEx: "Renegade Row cu Gantere", serii: 3, repetari: "10 per parte",
                            greutate: "12-20 kg", notaFormaTehnica: "Menține spatele drept, nu roti șoldul."),
                ExercitiiAI(numEx: "Biceps Curl cu Bara", serii: 3, repetari: "10-12",
                            greutate: "65% 1RM", notaFormaTehnica: "Contractă bicepsul în punctul de sus."),
                ExercitiiAI(numEx: "Face Pulls (Trapez Posterior)", serii: 3, repetari: "15-20",
                            greutate: "Greutate ușoară", notaFormaTehnica: "Trage la nivelul feței, coatele sus."),
                ExercitiiAI(numEx: "Deadlift Românesc", serii: 3, repetari: "8-10",
                            greutate: "70% 1RM", notaFormaTehnica: "Împinge șoldul înapoi, nu îndoi genunchii excesiv.")
            ], 60)

        case 2: // Legs
            return ("Legs (Picioare, Fesieri)", [
                ExercitiiAI(numEx: "Genuflexiuni / Squat", serii: 4, repetari: "6-10",
                            greutate: "75-85% 1RM", notaFormaTehnica: "Genunchii urmează direcția degetelor de la picioare."),
                ExercitiiAI(numEx: "Leg Press", serii: 3, repetari: "12-15",
                            greutate: "Greutate mare", notaFormaTehnica: "Nu bloca genunchii în extensie."),
                ExercitiiAI(numEx: "Fandări cu Gantere (Lunges)", serii: 3, repetari: "12 per picior",
                            greutate: "15-25 kg per ganteră", notaFormaTehnica: "Trunchiul drept, genunchiul din față la 90°."),
                ExercitiiAI(numEx: "Hip Thrust (Fesieri)", serii: 4, repetari: "12-15",
                            greutate: "Greutate corporală + disc", notaFormaTehnica: "Contractă fesierii la vârf complet."),
                ExercitiiAI(numEx: "Calf Raises (Moleti)", serii: 4, repetari: "20-25",
                            greutate: "Greutatea corpului / Smith Machine", notaFormaTehnica: "Pauza de 1 secundă sus și jos.")
            ], 65)

        case 3: // Cardio + Core
            return ("Cardio & Core", [
                ExercitiiAI(numEx: "Alergare / Bicicletă Cardio (HIIT)", serii: 1, repetari: "20 min",
                            greutate: "Intensitate variabilă", notaFormaTehnica: "30 sec sprint / 90 sec recuperare."),
                ExercitiiAI(numEx: "Planșă (Plank)", serii: 3, repetari: "60 sec",
                            greutate: "Greutatea corpului", notaFormaTehnica: "Nu ridica/lăsa șoldul; contractă abdomenul."),
                ExercitiiAI(numEx: "Crunch Bicicletă", serii: 3, repetari: "20 per parte",
                            greutate: "Greutatea corpului", notaFormaTehnica: "Mișcarea lentă, nu trage de gât."),
                ExercitiiAI(numEx: "Mountain Climbers", serii: 3, repetari: "45 sec",
                            greutate: "Greutatea corpului", notaFormaTehnica: "Menține șoldul jos, ritm constant."),
                ExercitiiAI(numEx: "Kettlebell Swings", serii: 3, repetari: "15-20",
                            greutate: "16-24 kg", notaFormaTehnica: "Puterea vine din șold, nu din brațe.")
            ], 45)

        default: // Full Body
            return ("Full Body (Menținere)", [
                ExercitiiAI(numEx: "Circuit Full Body (5 exerciții)", serii: 3, repetari: "12 per exercițiu",
                            greutate: "60-70% 1RM", notaFormaTehnica: "Pauze de 60 sec între circuite."),
                ExercitiiAI(numEx: "Tracțiuni", serii: 3, repetari: "Max",
                            greutate: "Greutatea corpului", notaFormaTehnica: "Mișcarea completă, jos și sus."),
                ExercitiiAI(numEx: "Push-ups Variante", serii: 3, repetari: "Max",
                            greutate: "Greutatea corpului", notaFormaTehnica: "Coatele la 45° față de corp."),
                ExercitiiAI(numEx: "Squat Săritură", serii: 3, repetari: "15",
                            greutate: "Greutatea corpului", notaFormaTehnica: "Aterizează moale pe toată talpa.")
            ], 50)
        }
    }

    // MARK: - Sfaturi Mock
    private func genereazaSfaturiMock(profil: ProfilUtilizator, areRetet: Bool) -> [String] {
        var sfaturi = [
            "🥩 Consumă proteinele în fiecare masă — distribuția uniformă maximizează sinteza proteică musculară.",
            "💧 Bea \(Int(profil.tintaApa))ml de apă zilnic. Hidratarea optimă îmbunătățește performanța cu până la 20%.",
            "🌙 Dormi 7-9 ore pe noapte. Hormonul de creștere se secretă în proporție de 70% în somn.",
            "📏 Cântărește-te dimineața, pe stomacul gol, în aceleași condiții pentru consistență.",
            "🔥 Antrenamentul de forță crește metabolismul bazal cu 7-10% pe termen lung.",
            "⏰ Mănâncă ultima masă cu minimum 2-3 ore înainte de culcare pentru digestie optimă.",
        ]

        switch profil.obiectiv {
        case .slabireModerate, .deficitAgresiv:
            sfaturi.append("⚡ Adaugă 10-15 minute de mers rapid post-masă pentru a accelera metabolismul.")
            sfaturi.append("🥗 Începe fiecare masă cu legume — fibra crește sațietatea și reduce aportul caloric total.")
        case .crestereMusculara:
            sfaturi.append("🍌 Consumă carbohidrați pre- și post-antrenament pentru energie și recuperare optimă.")
            sfaturi.append("💊 Creatina monohidrat (5g/zi) este cel mai studiat și eficient supliment pentru forță.")
        case .mentinere:
            sfaturi.append("⚖️ Cântărește alimentele timp de 2-4 săptămâni până când estimezi vizual corect porțiile.")
        }

        if areRetet {
            sfaturi.append("👨‍🍳 Excelent! Ai rețete salvate — preparatele personale sunt mai sănătoase și mai economice decât mâncatul în oraș.")
        }

        return sfaturi
    }

    // MARK: - Mesaj Personalizat Mock
    private func genereazaMesajPersonalizat(profil: ProfilUtilizator) -> String {
        let salut = "Salut! Iată planul tău personalizat pentru săptămâna aceasta."

        let contextObiectiv: String
        switch profil.obiectiv {
        case .mentinere:
            contextObiectiv = "Obiectivul tău de menținere înseamnă disciplină și consistență — nu restricție extremă."
        case .slabireModerate:
            contextObiectiv = "Cu un deficit de ~400 kcal/zi, vei pierde aproximativ 0.4 kg pe săptămână în mod sănătos."
        case .crestereMusculara:
            contextObiectiv = "Surplusul caloric combinat cu antrenamentul de forță va maximiza creșterea musculară."
        case .deficitAgresiv:
            contextObiectiv = "Atenție: deficitul agresiv necesită monitorizare atentă. Prioritizează proteinele pentru a păstra masa musculară."
        }

        let imcContext: String
        switch profil.categorieIMC {
        case .normal:
            imcContext = "IMC-ul tău de \(String(format: "%.1f", profil.imc)) este în intervalul optim. "
        case .supraponderal:
            imcContext = "IMC-ul tău indică puțin supraponderal — planul acesta te va ghida spre intervalul normal. "
        case .subponderal:
            imcContext = "IMC-ul tău indică subponderal — surplusul caloric și proteinele te vor ajuta să câștigi masă sănătoasă. "
        case .obezitate:
            imcContext = "Fiecare pas contează. Urmează planul cu răbdare și consultă un medic nutriționist periodic. "
        }

        return "\(salut)\n\n\(imcContext)\(contextObiectiv)\n\nPlanul combină nutriția cu antrenamentul pentru rezultate maxime. Succes!"
    }

    // MARK: - Mesaj Ajustare Dinamică
    private func genereazaMesajAjustare(deficit: Double, obiectiv: Obiectiv) -> String {
        if deficit > 300 {
            return "⚠️ Ai consumat cu \(Int(deficit)) kcal mai puțin decât targetul azi. Adaugă o gustare proteică înainte de culcare pentru a proteja masa musculară."
        } else if deficit < -300 {
            let surplus = abs(deficit)
            return "📈 Ai depășit targetul cu \(Int(surplus)) kcal. Mâine reduce porțiile la prânz cu ~150g sau sari gustarea."
        } else {
            return "✅ Excelent! Ai fost aproape de targetul caloric. Consistența aceasta pe termen lung aduce rezultate garantate!"
        }
    }

    // MARK: - OpenAI Integration (Dezactivat în modul mock)
    private func apeleazaOpenAI(profil: ProfilUtilizator, retete: [Reteta]) async -> RaspunsAI? {
        guard let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String,
              !apiKey.isEmpty else {
            mesajEroare = "Cheia API OpenAI nu este configurată în Config.plist."
            return nil
        }

        let prompt = construiestePrompt(profil: profil, retete: retete)

        guard let url = URL(string: baseURL) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": modelOpenAI,
            "messages": [
                ["role": "system", "content": "Ești un nutriționist și antrenor personal expert. Răspunzi DOAR în română. Generezi planuri personalizate în format JSON structurat."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 4000
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)

            // Parsează răspunsul OpenAI și convertește în RaspunsAI
            // (Implementare completă la activarea cheii API)
            _ = data
            return nil
        } catch {
            mesajEroare = "Eroare la conectarea cu OpenAI: \(error.localizedDescription)"
            return nil
        }
    }

    // MARK: - Constructor Prompt OpenAI
    private func construiestePrompt(profil: ProfilUtilizator, retete: [Reteta]) -> String {
        let reteteLista = retete.map { "- \($0.nume) (\(Int($0.kcalPerPortie))kcal, \(Int($0.proteinePerPortie))g P, \(Int($0.carboPerPortie))g C, \(Int($0.grasimiPerPortie))g G)" }.joined(separator: "\n")

        return """
        Generează un plan săptămânal de nutriție și antrenament pentru:

        DATE BIOMETRICE:
        - Vârstă: \(profil.varsta) ani
        - Greutate: \(profil.greutate) kg
        - Înălțime: \(profil.inaltime) cm
        - Gen: \(profil.gen.rawValue)
        - Nivel activitate: \(profil.nivelActivitate.rawValue)
        - IMC: \(String(format: "%.1f", profil.imc)) (\(profil.categorieIMC.rawValue))

        OBIECTIV: \(profil.obiectiv.rawValue)

        TARGETURI ZILNICE:
        - Calorii: \(Int(profil.tintaKcal)) kcal
        - Proteine: \(Int(profil.tintaProteine)) g
        - Carbohidrați: \(Int(profil.tintaCarbo)) g
        - Grăsimi: \(Int(profil.tintaGrasimi)) g
        - Apă: \(Int(profil.tintaApa)) ml

        REȚETE SALVATE DE UTILIZATOR (prioritizează-le în plan):
        \(reteteLista.isEmpty ? "Niciuna" : reteteLista)

        Răspunde STRICT în română. Integrează rețetele salvate când este posibil.
        """
    }
}
