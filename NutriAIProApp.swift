// MARK: - NutriAIProApp.swift
// NutriAI Pro — Entry point aplicație
// Platformă: iOS 26+ (Liquid Glass) | Backward compatible iOS 17+

import SwiftUI
import SwiftData

@main
struct NutriAIProApp: App {

    // MARK: - SwiftData Container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ProfilUtilizator.self,
            JurnalZilnic.self,
            IntrareAliment.self,
            Reteta.self,
            Ingredient.self
        ])

        let configuratie = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuratie])
        } catch {
            fatalError("Nu s-a putut crea ModelContainer: \(error)")
        }
    }()

    // MARK: - State
    @State private var onboardingFinalizat: Bool = UserDefaults.standard.bool(forKey: "onboardingFinalizat")

    var body: some Scene {
        WindowGroup {
            if onboardingFinalizat {
                ContentView()
                    .modelContainer(sharedModelContainer)
                    .preferredColorScheme(.dark)
                    .onReceive(NotificationCenter.default.publisher(for: .resetOnboarding)) { _ in
                        withAnimation(.easeInOut) {
                            onboardingFinalizat = false
                        }
                    }
            } else {
                OnboardingContainerView(onFinalizare: {
                    withAnimation(.spring(duration: 0.6)) {
                        onboardingFinalizat = true
                    }
                })
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(.dark)
            }
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let resetOnboarding = Notification.Name("resetOnboarding")
}
