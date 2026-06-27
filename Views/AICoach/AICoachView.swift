// MARK: - AICoachView.swift
// NutriAI Pro — Interfața principală a AI Coach
// Platformă: iOS 17+

import SwiftUI
import SwiftData

struct AICoachView: View {

    @Bindable var viewModel: AICoachViewModel
    @Bindable var dashboardVM: DashboardViewModel

    @Query private var profiluri: [ProfilUtilizator]
    @Query private var retete: [Reteta]
    var profil: ProfilUtilizator? { profiluri.first }

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: Fundal animat AI
                AIGradientBackground(esteActiv: viewModel.seProcesaza)
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Header AI
                    AIHeaderView(viewModel: viewModel, profil: profil)

                    // MARK: Tab Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TabAICoach.allCases, id: \.self) { tab in
                                PillButton(
                                    titlu: tab.rawValue,
                                    icon: tab.icon,
                                    culori: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                    esteSelectat: viewModel.tabSelectat == tab,
                                    actiune: {
                                        withAnimation(.spring(duration: 0.3)) {
                                            viewModel.tabSelectat = tab
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }

                    Divider().background(.white.opacity(0.08))

                    // MARK: Conținut Tab
                    Group {
                        switch viewModel.tabSelectat {
                        case .nutritie:
                            PlanNutritieSaptamanal(viewModel: viewModel)
                        case .antrenament:
                            PlanAntrenamentSaptamanal(viewModel: viewModel)
                        case .chat:
                            ChatAIView(viewModel: viewModel, profil: profil)
                        case .sfaturi:
                            SfaturiAIView(viewModel: viewModel)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.tabSelectat)
                }
            }
            .navigationTitle("AI Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        guard let profil else { return }
                        Task { await viewModel.genereazaPlan(profil: profil, retete: retete) }
                    } label: {
                        HStack(spacing: 6) {
                            if viewModel.seProcesaza {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(Color(hex: "#818CF8"))
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(viewModel.seProcesaza ? "Generez..." : "Generează")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(Color(hex: "#818CF8"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#4F46E5").opacity(0.2), in: Capsule())
                        .overlay(Capsule().strokeBorder(Color(hex: "#818CF8").opacity(0.3), lineWidth: 1))
                    }
                    .disabled(viewModel.seProcesaza)
                }
            }
        }
    }
}

// MARK: - Header AI
struct AIHeaderView: View {
    let viewModel: AICoachViewModel
    let profil: ProfilUtilizator?

    var body: some View {
        GlassCard(cornerRadius: 0, padding: 16, hasBorder: false) {
            HStack(spacing: 14) {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5"), Color(hex: "#7C3AED")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: Color(hex: "#4F46E5").opacity(0.6), radius: 12, x: 0, y: 6)

                    Image(systemName: "brain.head.profile.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("NutriAI Coach")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: "#34D399"))
                            .frame(width: 6, height: 6)
                        Text("Activ • Mod Offline")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Info profil
                if let profil {
                    VStack(alignment: .trailing, spacing: 2) {
                        Badge(
                            text: profil.obiectiv.rawValue,
                            culori: profil.obiectiv.gradient
                        )
                        if viewModel.raspunsAI != nil {
                            Text("Plan: \(viewModel.dataUltimeiGenerari)")
                                .font(.system(size: 9))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Plan Nutriție Săptămânal
struct PlanNutritieSaptamanal: View {
    let viewModel: AICoachViewModel

    var body: some View {
        if let plan = viewModel.raspunsAI?.planNutritional {
            VStack(spacing: 0) {

                // MARK: Selector Zi
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(plan.saptamana.enumerated()), id: \.element.id) { index, zi in
                            Button {
                                withAnimation(.spring(duration: 0.3)) {
                                    viewModel.ziSelectata = index
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(String(zi.zi.prefix(3)).uppercased())
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(viewModel.ziSelectata == index ? .white : .secondary)

                                    ZStack {
                                        Circle()
                                            .fill(
                                                viewModel.ziSelectata == index
                                                ? LinearGradient(
                                                    colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                                  )
                                                : LinearGradient(colors: [.white.opacity(0.08)],
                                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                            .frame(width: 34, height: 34)

                                        Text("\(index + 1)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(viewModel.ziSelectata == index ? .white : .secondary)
                                    }
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 6)
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(duration: 0.3), value: viewModel.ziSelectata)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                Divider().background(.white.opacity(0.06))

                // MARK: Detalii Zi Selectată
                if let zi = viewModel.ziNutritieCurenta {
                    ScrollView {
                        VStack(spacing: 16) {

                            // Nota zilei
                            HStack(spacing: 10) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundStyle(Color(hex: "#F59E0B"))
                                Text(zi.notaZi)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(Color(hex: "#92400E").opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)

                            // Total kcal zi
                            HStack {
                                Text("\(zi.zi) — \(Int(zi.totalKcal)) kcal total")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(.horizontal)

                            // Mese
                            ForEach([
                                (SlotMasa.micDejun, zi.micDejun),
                                (SlotMasa.pranz, zi.pranz),
                                (SlotMasa.cina, zi.cina),
                                (SlotMasa.gustare, zi.gustare)
                            ], id: \.0.rawValue) { (slot, mese) in
                                AISlotMasaCard(slot: slot, mese: mese)
                                    .padding(.horizontal)
                            }

                            Spacer(minLength: 30)
                        }
                        .padding(.top, 12)
                    }
                }
            }
        } else {
            // Placeholder când nu există plan
            AIPlaceholderView(
                icon: "fork.knife.circle",
                titlu: "Plan Nutrițional",
                mesaj: "Apasă **\"Generează\"** pentru a crea un plan de nutriție săptămânal personalizat bazat pe profilul tău."
            )
        }
    }
}

// MARK: - Slot Masă AI
struct AISlotMasaCard: View {
    let slot: SlotMasa
    let mese: [MasaAI]

    var body: some View {
        GlassCard(cornerRadius: 16, padding: 14) {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: slot.icon)
                        .foregroundStyle(
                            LinearGradient(colors: slot.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text(slot.rawValue)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(Int(mese.reduce(0) { $0 + $1.kcal })) kcal")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                Divider().background(.white.opacity(0.08))

                ForEach(mese) { masa in
                    HStack(spacing: 10) {
                        if masa.esteReteta {
                            Image(systemName: "fork.knife")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "#818CF8"))
                                .frame(width: 20)
                        } else {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(masa.numeAliment)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                            Text(masa.cantitate)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(Int(masa.kcal)) kcal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Plan Antrenament Săptămânal
struct PlanAntrenamentSaptamanal: View {
    let viewModel: AICoachViewModel

    var body: some View {
        if let plan = viewModel.raspunsAI?.planAntrenament {
            VStack(spacing: 0) {
                // Split Info Banner
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundStyle(Color(hex: "#F59E0B"))
                    Text(plan.tipSplit)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding()

                // Selector Zi
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(plan.saptamana.enumerated()), id: \.element.id) { index, zi in
                            Button {
                                withAnimation(.spring(duration: 0.3)) { viewModel.ziSelectata = index }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(String(zi.zi.prefix(3)).uppercased())
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(viewModel.ziSelectata == index ? .white : .secondary)

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                zi.esteZiOdihna
                                                ? LinearGradient(colors: [.white.opacity(0.06)],
                                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                                                : (viewModel.ziSelectata == index
                                                   ? LinearGradient(colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                                                    startPoint: .topLeading, endPoint: .bottomTrailing)
                                                   : LinearGradient(colors: [.white.opacity(0.08)],
                                                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                                            )
                                            .frame(width: 44, height: 44)

                                        Image(systemName: zi.esteZiOdihna ? "moon.zzz.fill" : "dumbbell.fill")
                                            .font(.body)
                                            .foregroundStyle(
                                                zi.esteZiOdihna ? Color.secondary
                                                : (viewModel.ziSelectata == index ? Color.white : Color.secondary)
                                            )
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                Divider().background(.white.opacity(0.06))

                // Detalii Antrenament Zi
                if let zi = viewModel.ziAntrenamentCurenta {
                    ScrollView {
                        VStack(spacing: 14) {

                            // Header zi
                            GlassCard(cornerRadius: 16, padding: 14) {
                                HStack(spacing: 12) {
                                    Image(systemName: zi.esteZiOdihna ? "moon.zzz.fill" : "flame.fill")
                                        .font(.title3)
                                        .foregroundStyle(
                                            zi.esteZiOdihna
                                            ? LinearGradient(colors: [.secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("\(zi.zi) — \(zi.tipAntrenament)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                        HStack(spacing: 10) {
                                            Text("⏱ \(zi.durataMinute) min")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text("⚡ \(zi.intensitate)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)

                            // Exerciții
                            ForEach(zi.exercitii) { exercitiu in
                                ExercitiiCard(exercitiu: exercitiu)
                                    .padding(.horizontal)
                            }

                            Spacer(minLength: 30)
                        }
                        .padding(.top, 12)
                    }
                }
            }
        } else {
            AIPlaceholderView(
                icon: "dumbbell.circle",
                titlu: "Plan Antrenament",
                mesaj: "Apasă **\"Generează\"** pentru a crea un plan de antrenament adaptat obiectivului tău."
            )
        }
    }
}

// MARK: - Card Exercițiu
struct ExercitiiCard: View {
    let exercitiu: ExercitiiAI

    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(exercitiu.numEx)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Spacer()
                }

                HStack(spacing: 16) {
                    ExercitiiStat(icon: "number.circle.fill", label: "Serii", valoare: "\(exercitiu.serii)",
                                  culoare: Color(hex: "#818CF8"))
                    ExercitiiStat(icon: "arrow.triangle.2.circlepath", label: "Rep", valoare: exercitiu.repetari,
                                  culoare: Color(hex: "#34D399"))
                    ExercitiiStat(icon: "scalemass.fill", label: "Greutate", valoare: exercitiu.greutate,
                                  culoare: Color(hex: "#F59E0B"))
                }

                if !exercitiu.notaFormaTehnica.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "#60A5FA"))
                        Text(exercitiu.notaFormaTehnica)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(8)
                    .background(Color(hex: "#1D4ED8").opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

struct ExercitiiStat: View {
    let icon: String
    let label: String
    let valoare: String
    let culoare: Color

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(culoare)
            Text(valoare)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Chat AI View
struct ChatAIView: View {
    @Bindable var viewModel: AICoachViewModel
    let profil: ProfilUtilizator?
    @FocusState private var inputFocusat: Bool

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Mesaje
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.mesajeChat) { mesaj in
                            AIMessageBubble(mesaj: mesaj)
                                .id(mesaj.id)
                        }

                        if viewModel.seProcesazaChatRaspuns {
                            AITypingIndicator()
                                .id("typing")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.mesajeChat.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.mesajeChat.last?.id, anchor: .bottom)
                    }
                }
            }

            Divider().background(.white.opacity(0.08))

            // MARK: Input
            HStack(spacing: 12) {
                TextField("Întreabă AI-ul...", text: $viewModel.inputChat)
                    .focused($inputFocusat)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
                    .onSubmit {
                        if let profil { viewModel.trimiteMesajChat(profil: profil) }
                    }

                Button {
                    if let profil { viewModel.trimiteMesajChat(profil: profil) }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            viewModel.inputChat.isEmpty
                            ? AnyShapeStyle(Color.secondary)
                            : AnyShapeStyle(LinearGradient(
                                colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing))
                        )
                }
                .disabled(viewModel.inputChat.isEmpty)
            }
            .padding()
        }
    }
}

// MARK: - Sfaturi AI
struct SfaturiAIView: View {
    let viewModel: AICoachViewModel

    var body: some View {
        if let sfaturi = viewModel.raspunsAI?.sfaturi {
            ScrollView {
                VStack(spacing: 12) {
                    Text("Sfaturi Personalizate")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ForEach(Array(sfaturi.enumerated()), id: \.offset) { index, sfat in
                        HStack(alignment: .top, spacing: 14) {
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color(hex: "#818CF8"))
                                .frame(width: 24, height: 24)
                                .background(Color(hex: "#4F46E5").opacity(0.2), in: Circle())

                            Text(sfat)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()
                        }
                        .padding(14)
                        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.06), lineWidth: 1))
                        .padding(.horizontal)
                    }
                    Spacer(minLength: 30)
                }
                .padding(.top, 16)
            }
        } else {
            AIPlaceholderView(icon: "lightbulb.circle", titlu: "Sfaturi Personalizate",
                              mesaj: "Generează un plan și vei primi sfaturi personalizate de nutriție și antrenament.")
        }
    }
}

// MARK: - AI Placeholder
struct AIPlaceholderView: View {
    let icon: String
    let titlu: String
    let mesaj: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            Text(titlu)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(try! AttributedString(markdown: mesaj))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - AI Gradient Background
struct AIGradientBackground: View {
    let esteActiv: Bool
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#4F46E5").opacity(esteActiv ? 0.5 : 0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: -50, y: -150 + (esteActiv ? phase * 30 : 0))
                .blur(radius: 50)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: esteActiv)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }
}

// MARK: - AI Message Bubble
struct AIMessageBubble: View {
    let mesaj: MesajChat

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if mesaj.esteAI {
                // Avatar AI
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 28, height: 28)
                    Image(systemName: "brain.head.profile.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                }
            }

            // Bulă text
            VStack(alignment: mesaj.esteAI ? .leading : .trailing, spacing: 4) {
                Text(try! AttributedString(markdown: mesaj.text))
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        mesaj.esteAI
                        ? AnyShapeStyle(Color.white.opacity(0.1))
                        : AnyShapeStyle(LinearGradient(
                            colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(.white.opacity(mesaj.esteAI ? 0.08 : 0), lineWidth: 1)
                    )

                Text(formateazaOra(mesaj.timestamp))
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity * 0.75, alignment: mesaj.esteAI ? .leading : .trailing)

            if !mesaj.esteAI { Spacer() }
        }
    }

    private func formateazaOra(_ data: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: data)
    }
}

// MARK: - Typing Indicator
struct AITypingIndicator: View {
    @State private var animatie: Bool = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 28, height: 28)
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 6, height: 6)
                        .scaleEffect(animatie ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15),
                            value: animatie
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))

            Spacer()
        }
        .onAppear { animatie = true }
    }
}
