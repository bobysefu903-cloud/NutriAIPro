// MARK: - ScannerOverlayView.swift
// NutriAI Pro — Overlay vizual premium peste camera live
// Faza 3 | iOS 26 Liquid Glass + fallback iOS 17+

import SwiftUI

// MARK: - ScannerOverlayView
/// Overlay animat deasupra preview-ului camerei — cadru de scanare, instrucțiuni, lanternă
struct ScannerOverlayView: View {

    var onLanterna: () -> Void
    var onInchide: () -> Void

    // MARK: - Stare Animație
    @State private var animatieCadru: Bool = false
    @State private var liniiScaning: CGFloat = 0
    @State private var lanternaActiva: Bool = false
    @State private var pulsatie: Bool = false
    @State private var opacitateInstructiuni: Double = 0

    private let dimensiuneCadru: CGFloat = 260
    private let grosimeColt: CGFloat = 3
    private let lungimeColt: CGFloat = 28

    var body: some View {
        ZStack {
            // MARK: Mască semi-transparentă (fundal întunecat + gaură centrală)
            ScannerMaskView(dimensiuneCadru: dimensiuneCadru)

            // MARK: Cadru Scanare
            ZStack {
                // Colțuri animate
                CadruScanare(
                    dimensiune: dimensiuneCadru,
                    grosime: grosimeColt,
                    lungimeColt: lungimeColt,
                    culoare: animatieCadru ? Color(hex: "#34D399") : .white
                )
                .animation(.easeInOut(duration: 0.6), value: animatieCadru)

                // Linia de scanare animată
                LinieScaning(dimensiune: dimensiuneCadru, offset: liniiScaning)
                    .opacity(animatieCadru ? 0.0 : 0.8)
            }

            // MARK: UI Controls
            VStack {
                // MARK: Top Bar
                HStack {
                    // Buton Închide
                    Button(action: onInchide) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4)
                    }

                    Spacer()

                    // Titlu
                    Text("Scanează Produs")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 4)

                    Spacer()

                    // Buton Lanternă
                    Button {
                        lanternaActiva.toggle()
                        onLanterna()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: lanternaActiva ? "bolt.circle.fill" : "bolt.slash.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(lanternaActiva ? Color(hex: "#F59E0B") : .white)
                            .shadow(color: .black.opacity(0.5), radius: 4)
                            .animation(.spring(duration: 0.3), value: lanternaActiva)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 0) // SafeArea gestionată de NavigationStack

                Spacer()

                // MARK: Zona cadru (goală — camera se vede prin mască)
                Spacer()
                    .frame(height: dimensiuneCadru + 60)

                Spacer()

                // MARK: Bottom Info
                VStack(spacing: 20) {
                    // Instrucțiuni
                    VStack(spacing: 8) {
                        Text("Centrează codul de bare în cadru")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.6), radius: 4)

                        Text("EAN-8 • EAN-13 • UPC • QR Code")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .shadow(color: .black.opacity(0.5), radius: 2)
                    }
                    .opacity(opacitateInstructiuni)

                    // Hint format coduri
                    HStack(spacing: 8) {
                        Image(systemName: "barcode")
                            .foregroundStyle(.white.opacity(0.6))
                        Text("Se detectează automat")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.35), in: Capsule())
                    .opacity(opacitateInstructiuni)
                }
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            pornestAnimatii()
        }
    }

    // MARK: - Animații
    private func pornestAnimatii() {
        // Apariție instrucțiuni
        withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
            opacitateInstructiuni = 1
        }

        // Linia de scanare pulsează continuu
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            liniiScaning = 1
        }

        // Colțuri pulsează
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulsatie = true
        }
    }
}

// MARK: - Mască Semi-transparentă cu Gaură
struct ScannerMaskView: View {
    let dimensiuneCadru: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Fundal întunecat
                Color.black.opacity(0.65)

                // Gaura centrală (zona de scanare)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .frame(width: dimensiuneCadru, height: dimensiuneCadru)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Cadru de Scanare cu Colțuri
struct CadruScanare: View {
    let dimensiune: CGFloat
    let grosime: CGFloat
    let lungimeColt: CGFloat
    let culoare: Color

    var body: some View {
        ZStack {
            // Cadrul principal rotunjit (umbra)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(culoare.opacity(0.3), lineWidth: 1)
                .frame(width: dimensiune, height: dimensiune)

            // Colț Stânga-Sus
            ColtScanare(dimensiune: dimensiuneColt, grosime: grosime, culoare: culoare)
                .offset(x: -(dimensiune/2 - lungimeColt/2), y: -(dimensiune/2 - lungimeColt/2))

            // Colț Dreapta-Sus
            ColtScanare(dimensiune: dimensiuneColt, grosime: grosime, culoare: culoare)
                .rotationEffect(.degrees(90))
                .offset(x: (dimensiune/2 - lungimeColt/2), y: -(dimensiune/2 - lungimeColt/2))

            // Colț Dreapta-Jos
            ColtScanare(dimensiune: dimensiuneColt, grosime: grosime, culoare: culoare)
                .rotationEffect(.degrees(180))
                .offset(x: (dimensiune/2 - lungimeColt/2), y: (dimensiune/2 - lungimeColt/2))

            // Colț Stânga-Jos
            ColtScanare(dimensiune: dimensiuneColt, grosime: grosime, culoare: culoare)
                .rotationEffect(.degrees(270))
                .offset(x: -(dimensiune/2 - lungimeColt/2), y: (dimensiune/2 - lungimeColt/2))
        }
        .shadow(color: culoare.opacity(0.6), radius: 8, x: 0, y: 0)
    }

    private var dimensiuneColt: CGFloat { lungimeColt }
}

// MARK: - Un singur colț de scanare
struct ColtScanare: View {
    let dimensiune: CGFloat
    let grosime: CGFloat
    let culoare: Color

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: dimensiune))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: dimensiune, y: 0))
        }
        .stroke(culoare, style: StrokeStyle(lineWidth: grosime, lineCap: .round, lineJoin: .round))
        .frame(width: dimensiune, height: dimensiune)
    }
}

// MARK: - Linia de Scanare Animată
struct LinieScaning: View {
    let dimensiune: CGFloat
    var offset: CGFloat  // 0.0 → sus, 1.0 → jos

    var body: some View {
        GeometryReader { _ in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#34D399").opacity(0),
                            Color(hex: "#34D399").opacity(0.8),
                            Color(hex: "#34D399").opacity(0.5),
                            Color(hex: "#34D399").opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: dimensiune - 20, height: 3)
                .offset(y: offset * (dimensiune - 6) - dimensiune/2)
        }
        .frame(width: dimensiune, height: dimensiune)
        .clipped()
    }
}
