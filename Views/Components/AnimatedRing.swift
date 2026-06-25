// MARK: - AnimatedRing.swift
// NutriAI Pro — Inelele animate de progres macro
// Platformă: iOS 17+ | SwiftUI

import SwiftUI

// MARK: - Inel Animat Principal
/// Inel circular animat cu gradient, folosit pentru vizualizarea macronutrienților
struct AnimatedRing: View {

    // MARK: - Input
    var progres: Double          // 0.0 – 1.0
    var culori: [Color]
    var grosime: CGFloat
    var dimensiune: CGFloat
    var animat: Bool

    // MARK: - Stare Animație
    @State private var afisatProgres: Double = 0
    @State private var pulsatie: Bool = false

    init(
        progres: Double,
        culori: [Color] = [Color(hex: "#818CF8"), Color(hex: "#4F46E5")],
        grosime: CGFloat = 12,
        dimensiune: CGFloat = 100,
        animat: Bool = true
    ) {
        self.progres = progres
        self.culori = culori
        self.grosime = grosime
        self.dimensiune = dimensiune
        self.animat = animat
    }

    var body: some View {
        ZStack {
            // MARK: Track (fundal ring)
            Circle()
                .stroke(
                    Color.white.opacity(0.08),
                    style: StrokeStyle(lineWidth: grosime, lineCap: .round)
                )
                .frame(width: dimensiune, height: dimensiune)

            // MARK: Progress Ring
            Circle()
                .trim(from: 0, to: animat ? afisatProgres : progres)
                .stroke(
                    AngularGradient(
                        colors: culori + [culori.first ?? .purple],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(
                        lineWidth: grosime,
                        lineCap: .round
                    )
                )
                .frame(width: dimensiune, height: dimensiune)
                .rotationEffect(.degrees(-90))
                .shadow(color: culori.first?.opacity(0.6) ?? .clear, radius: 6, x: 0, y: 0)

            // MARK: Glow la depășire target
            if progres >= 1.0 {
                Circle()
                    .stroke(
                        culori.first?.opacity(pulsatie ? 0.4 : 0.1) ?? .clear,
                        lineWidth: grosime + 4
                    )
                    .frame(width: dimensiune, height: dimensiune)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulsatie)
            }

            // MARK: Punct indicator la capătul progresului
            if afisatProgres > 0.02 {
                Circle()
                    .fill(
                        LinearGradient(colors: culori, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: grosime, height: grosime)
                    .shadow(color: culori.first?.opacity(0.8) ?? .clear, radius: 4, x: 0, y: 0)
                    .offset(y: -(dimensiune / 2))
                    .rotationEffect(.degrees((animat ? afisatProgres : progres) * 360 - 90))
            }
        }
        .onAppear {
            guard animat else { return }
            withAnimation(.spring(duration: 1.2, bounce: 0.2).delay(0.1)) {
                afisatProgres = progres
            }
            if progres >= 1.0 {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulsatie = true
                }
            }
        }
        .onChange(of: progres) { _, nouValoare in
            withAnimation(.spring(duration: 0.6)) {
                afisatProgres = nouValoare
            }
        }
    }
}

// MARK: - Macro Ring Card
/// Card complet cu inel animat + etichete + valori
struct MacroRingCard: View {
    let titlu: String
    let consumat: Double
    let tinta: Double
    let unitate: String
    let culori: [Color]
    let icon: String
    var dimensiuneRing: CGFloat = 80
    var animat: Bool = true

    var progres: Double {
        CalculatorNutritie.procentajProgres(consumat: consumat, tinta: tinta)
    }
    var ramas: Double { max(0, tinta - consumat) }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                AnimatedRing(
                    progres: progres,
                    culori: culori,
                    grosime: 8,
                    dimensiune: dimensiuneRing,
                    animat: animat
                )

                VStack(spacing: 0) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(
                            LinearGradient(colors: culori, startPoint: .top, endPoint: .bottom)
                        )

                    Text("\(Int(consumat))")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(unitate)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 2) {
                Text(titlu)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text("↓ \(Int(ramas))\(unitate)")
                    .font(.caption2)
                    .foregroundStyle(
                        LinearGradient(colors: culori, startPoint: .leading, endPoint: .trailing)
                    )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Inel Mare Central (Calorii)
struct CentralCaloriesRing: View {
    let consumate: Double
    let tinta: Double
    let caloriiArse: Double
    var animat: Bool = true

    @State private var afisatProgres: Double = 0
    @State private var pulsatie: Bool = false

    var progres: Double {
        CalculatorNutritie.procentajProgres(consumat: consumate, tinta: tinta)
    }

    var ramase: Double { max(0, tinta - consumate) }
    var culori: [Color] { [Color(hex: "#A78BFA"), Color(hex: "#7C3AED"), Color(hex: "#4F46E5")] }

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .stroke(
                    culori.first?.opacity(0.15) ?? .clear,
                    lineWidth: 24
                )
                .frame(width: 180, height: 180)
                .blur(radius: 8)

            // Track ring
            Circle()
                .stroke(
                    Color.white.opacity(0.06),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 176, height: 176)

            // Progress ring
            Circle()
                .trim(from: 0, to: animat ? afisatProgres : progres)
                .stroke(
                    AngularGradient(
                        colors: culori + [culori.first!],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 176, height: 176)
                .rotationEffect(.degrees(-90))
                .shadow(color: culori[1].opacity(0.7), radius: 12, x: 0, y: 0)

            // Inner content
            VStack(spacing: 4) {
                Text("CALORII")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(2)

                Text("\(Int(ramase))")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: culori,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .contentTransition(.numericText(countsDown: true))

                Text("rămase kcal")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                if caloriiArse > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.orange)
                        Text("+\(Int(caloriiArse)) arse")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.orange.opacity(0.15), in: Capsule())
                }
            }
        }
        .onAppear {
            guard animat else { return }
            withAnimation(.spring(duration: 1.4, bounce: 0.15).delay(0.2)) {
                afisatProgres = progres
            }
        }
        .onChange(of: progres) { _, nouaValoare in
            withAnimation(.spring(duration: 0.7)) {
                afisatProgres = nouaValoare
            }
        }
    }
}

// MARK: - Progress Bar Orizontal (pentru mese)
struct MacroProgressBar: View {
    let consumat: Double
    let tinta: Double
    let culori: [Color]

    var progres: Double {
        CalculatorNutritie.procentajProgres(consumat: consumat, tinta: tinta)
    }

    @State private var animatProgres: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(colors: culori, startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * animatProgres, height: 6)
                    .shadow(color: culori.first?.opacity(0.5) ?? .clear, radius: 4, x: 0, y: 0)
            }
        }
        .frame(height: 6)
        .onAppear {
            withAnimation(.spring(duration: 1.0).delay(0.2)) {
                animatProgres = progres
            }
        }
        .onChange(of: progres) { _, nouaValoare in
            withAnimation(.spring(duration: 0.5)) {
                animatProgres = nouaValoare
            }
        }
    }
}
