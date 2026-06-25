// MARK: - Enums.swift
// NutriAI Pro — Toate enumerările aplicației
// Platformă: iOS 17+ | SwiftUI | SwiftData

import Foundation
import SwiftUI

// MARK: - Gen
/// Genul utilizatorului, folosit în calculul BMR (Mifflin-St Jeor)
enum Gen: String, CaseIterable, Codable {
    case masculin = "Masculin"
    case feminin  = "Feminin"

    var icon: String {
        switch self {
        case .masculin: return "person.fill"
        case .feminin:  return "person.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .masculin: return [Color(hex: "#4F8EF7"), Color(hex: "#1E3A8A")]
        case .feminin:  return [Color(hex: "#F472B6"), Color(hex: "#9D174D")]
        }
    }
}

// MARK: - Nivel Activitate
/// Nivelul de activitate fizică, multiplicator pentru calculul TDEE
enum NivelActivitate: String, CaseIterable, Codable {
    case sedentar         = "Sedentar"
    case usorActiv        = "Ușor Activ"
    case moderat          = "Moderat Activ"
    case foarteActiv      = "Foarte Activ"
    case extremDeActiv    = "Extrem de Activ"

    /// Multiplicatorul Harris-Benedict / Mifflin-St Jeor
    var multiplicator: Double {
        switch self {
        case .sedentar:       return 1.2
        case .usorActiv:      return 1.375
        case .moderat:        return 1.55
        case .foarteActiv:    return 1.725
        case .extremDeActiv:  return 1.9
        }
    }

    var descriere: String {
        switch self {
        case .sedentar:
            return "Birou, mișcare minimă"
        case .usorActiv:
            return "1–3 antrenamente/săpt."
        case .moderat:
            return "3–5 antrenamente/săpt."
        case .foarteActiv:
            return "6–7 antrenamente/săpt."
        case .extremDeActiv:
            return "Atletism/Muncă fizică"
        }
    }

    var icon: String {
        switch self {
        case .sedentar:      return "sofa.fill"
        case .usorActiv:     return "figure.walk"
        case .moderat:       return "figure.run"
        case .foarteActiv:   return "figure.strengthtraining.traditional"
        case .extremDeActiv: return "flame.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .sedentar:      return [Color(hex: "#6B7280"), Color(hex: "#374151")]
        case .usorActiv:     return [Color(hex: "#34D399"), Color(hex: "#065F46")]
        case .moderat:       return [Color(hex: "#60A5FA"), Color(hex: "#1D4ED8")]
        case .foarteActiv:   return [Color(hex: "#F59E0B"), Color(hex: "#92400E")]
        case .extremDeActiv: return [Color(hex: "#F87171"), Color(hex: "#991B1B")]
        }
    }
}

// MARK: - Obiectiv
/// Obiectivul nutrițional al utilizatorului
enum Obiectiv: String, CaseIterable, Codable {
    case mentinere        = "Menținere Greutate"
    case slabireModerate  = "Slăbire Moderată"
    case crestereMusculara = "Creștere Musculară"
    case deficitAgresiv   = "Deficit Agresiv"

    var descriere: String {
        switch self {
        case .mentinere:
            return "Păstrează greutatea actuală printr-un echilibru caloric perfect."
        case .slabireModerate:
            return "Deficit de 300–500 kcal/zi pentru o pierdere sănătoasă de 0.5 kg/săpt."
        case .crestereMusculara:
            return "Surplus de 300–400 kcal/zi cu proteine crescute pentru maximizarea anabolismului."
        case .deficitAgresiv:
            return "Deficit de 700–900 kcal/zi pentru o pierdere accelerată. Necesită monitorizare atentă."
        }
    }

    var icon: String {
        switch self {
        case .mentinere:          return "scale.3d"
        case .slabireModerate:    return "arrow.down.circle.fill"
        case .crestereMusculara:  return "dumbbell.fill"
        case .deficitAgresiv:     return "bolt.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .mentinere:          return [Color(hex: "#818CF8"), Color(hex: "#4F46E5")]
        case .slabireModerate:    return [Color(hex: "#34D399"), Color(hex: "#059669")]
        case .crestereMusculara:  return [Color(hex: "#FB923C"), Color(hex: "#C2410C")]
        case .deficitAgresiv:     return [Color(hex: "#F87171"), Color(hex: "#B91C1C")]
        }
    }

    /// Ajustarea calorică față de TDEE
    var ajustareCaloriica: Double {
        switch self {
        case .mentinere:          return 0
        case .slabireModerate:    return -400
        case .crestereMusculara:  return +350
        case .deficitAgresiv:     return -800
        }
    }
}

// MARK: - Slot Masă
/// Cele 4 mese zilnice ale aplicației
enum SlotMasa: String, CaseIterable, Codable, Identifiable {
    case micDejun     = "Mic Dejun"
    case pranz        = "Prânz"
    case cina         = "Cină"
    case gustare      = "Gustare / Sursă Proteine"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .micDejun: return "sunrise.fill"
        case .pranz:    return "sun.max.fill"
        case .cina:     return "moon.stars.fill"
        case .gustare:  return "bolt.heart.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .micDejun: return [Color(hex: "#FCD34D"), Color(hex: "#F59E0B")]
        case .pranz:    return [Color(hex: "#6EE7B7"), Color(hex: "#10B981")]
        case .cina:     return [Color(hex: "#818CF8"), Color(hex: "#6366F1")]
        case .gustare:  return [Color(hex: "#F9A8D4"), Color(hex: "#EC4899")]
        }
    }

    var oraSugerate: String {
        switch self {
        case .micDejun: return "07:00 – 09:00"
        case .pranz:    return "12:00 – 14:00"
        case .cina:     return "18:00 – 20:00"
        case .gustare:  return "Oricând"
        }
    }
}

// MARK: - Categorie IMC
/// Categoriile IMC conform OMS
enum CategorieIMC: String, Codable {
    case subponderal    = "Subponderal"
    case normal         = "Normal"
    case supraponderal  = "Supraponderal"
    case obezitate      = "Obezitate"

    var culoare: Color {
        switch self {
        case .subponderal:   return Color(hex: "#60A5FA")
        case .normal:        return Color(hex: "#34D399")
        case .supraponderal: return Color(hex: "#F59E0B")
        case .obezitate:     return Color(hex: "#F87171")
        }
    }

    var icon: String {
        switch self {
        case .subponderal:   return "arrow.down.circle"
        case .normal:        return "checkmark.circle.fill"
        case .supraponderal: return "exclamationmark.circle"
        case .obezitate:     return "exclamationmark.triangle.fill"
        }
    }

    var mesaj: String {
        switch self {
        case .subponderal:
            return "Greutatea ta este sub intervalul recomandat. Crește aportul caloric treptat."
        case .normal:
            return "Felicitări! Te afli în intervalul optim de greutate."
        case .supraponderal:
            return "Greutatea depășește ușor intervalul normal. Un deficit moderat te va ajuta."
        case .obezitate:
            return "Este recomandat să consulți un medic și să urmezi un program structurat."
        }
    }

    /// Calculează categoria pe baza valorii IMC
    static func dinValoare(_ imc: Double) -> CategorieIMC {
        switch imc {
        case ..<18.5:   return .subponderal
        case 18.5..<25: return .normal
        case 25..<30:   return .supraponderal
        default:        return .obezitate
        }
    }
}

// MARK: - Color Extension (Hex)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
