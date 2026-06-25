// MARK: - MealSlotCardView.swift
// NutriAI Pro — Cardul expandabil pentru fiecare slot de masă
// Platformă: iOS 17+

import SwiftUI

struct MealSlotCardView: View {

    let slot: SlotMasa
    let intrari: [IntrareAliment]
    let onAdauga: () -> Void
    let onSterge: (Int) -> Void

    // MARK: - Stare UI
    @State private var esteExpantat: Bool = false

    // MARK: - Macronutrienți Totale Slot
    var kcalSlot: Double { intrari.reduce(0) { $0 + $1.kcal } }
    var proteineSlot: Double { intrari.reduce(0) { $0 + $1.proteine } }
    var carboSlot: Double { intrari.reduce(0) { $0 + $1.carbo } }
    var grasimiSlot: Double { intrari.reduce(0) { $0 + $1.grasimi } }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Header Card (mereu vizibil)
            Button {
                withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                    esteExpantat.toggle()
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                HStack(spacing: 14) {

                    // Icon Slot
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: slot.gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .shadow(
                                color: slot.gradient.first?.opacity(0.5) ?? .clear,
                                radius: 8, x: 0, y: 4
                            )

                        Image(systemName: slot.icon)
                            .font(.title3)
                            .foregroundStyle(.white)
                    }

                    // Info Slot
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(slot.rawValue)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)

                            if !intrari.isEmpty {
                                Text("\(intrari.count) \(intrari.count == 1 ? "aliment" : "alimente")")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(.white.opacity(0.08), in: Capsule())
                            }
                        }

                        Text(slot.oraSugerate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Calorii + Expand
                    VStack(alignment: .trailing, spacing: 2) {
                        if kcalSlot > 0 {
                            Text("\(Int(kcalSlot))")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: slot.gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .contentTransition(.numericText())
                                .animation(.spring(duration: 0.4), value: kcalSlot)

                            Text("kcal")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Gol")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Image(systemName: esteExpantat ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(esteExpantat ? 0 : 0))
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            // MARK: Conținut Expandat
            if esteExpantat {
                VStack(spacing: 0) {
                    Divider()
                        .background(.white.opacity(0.08))
                        .padding(.horizontal, 16)

                    // Mini-bara macro slot
                    if kcalSlot > 0 {
                        SlotMacroBanda(
                            proteine: proteineSlot,
                            carbo: carboSlot,
                            grasimi: grasimiSlot
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }

                    // Lista intrări
                    if intrari.isEmpty {
                        MasaGoala(slot: slot, onAdauga: onAdauga)
                            .padding(16)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(Array(intrari.enumerated()), id: \.element.id) { index, intrare in
                                IntrareAlimentRow(
                                    intrare: intrare,
                                    onSterge: { onSterge(index) }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                            }

                            // Buton Adaugă în mod expand
                            Button(action: onAdauga) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle")
                                        .font(.subheadline)
                                    Text("Adaugă Aliment")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: slot.gradient,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    slot.gradient.first?.opacity(0.1) ?? .clear,
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(slot.gradient.first?.opacity(0.25) ?? .clear, lineWidth: 1)
                                )
                            }
                            .pressEffect()
                        }
                        .padding(16)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            esteExpantat
                            ? LinearGradient(
                                colors: [slot.gradient.first?.opacity(0.4) ?? .clear, .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                            : LinearGradient(colors: [.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: esteExpantat ? 1.5 : 1
                        )
                }
        }
        .animation(.spring(duration: 0.4), value: esteExpantat)
    }
}

// MARK: - Masă Goală
struct MasaGoala: View {
    let slot: SlotMasa
    let onAdauga: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: slot.icon)
                .font(.system(size: 32))
                .foregroundStyle(slot.gradient.first?.opacity(0.4) ?? .clear)

            Text("Niciun aliment adăugat")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onAdauga) {
                Label("Adaugă la \(slot.rawValue)", systemImage: "plus")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: slot.gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: slot.gradient.first?.opacity(0.4) ?? .clear, radius: 8, x: 0, y: 4)
                    }
            }
            .pressEffect()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Rând Intrare Aliment
struct IntrareAlimentRow: View {
    let intrare: IntrareAliment
    let onSterge: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(intrare.esteRinReteta
                          ? LinearGradient(colors: [Color(hex: "#818CF8"), Color(hex: "#4F46E5")], startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [Color.white.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: intrare.esteRinReteta ? "fork.knife" : "circle.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(intrare.numeAliment)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text("\(Int(intrare.kcal)) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if intrare.proteine > 0 {
                        Text("P:\(Int(intrare.proteine))g")
                            .font(.caption2)
                            .foregroundStyle(Color(hex: "#34D399").opacity(0.8))
                    }

                    if intrare.carbo > 0 {
                        Text("C:\(Int(intrare.carbo))g")
                            .font(.caption2)
                            .foregroundStyle(Color(hex: "#60A5FA").opacity(0.8))
                    }

                    if intrare.grasimi > 0 {
                        Text("G:\(Int(intrare.grasimi))g")
                            .font(.caption2)
                            .foregroundStyle(Color(hex: "#F59E0B").opacity(0.8))
                    }
                }
            }

            Spacer()

            // Buton Sterge
            Button(action: onSterge) {
                Image(systemName: "trash.fill")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.6))
                    .padding(8)
                    .background(.red.opacity(0.1), in: Circle())
            }
        }
        .padding(10)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Bandă Macro Slot
struct SlotMacroBanda: View {
    let proteine: Double
    let carbo: Double
    let grasimi: Double

    var total: Double { max(1, proteine * 4 + carbo * 4 + grasimi * 9) }
    var procentProteine: Double { (proteine * 4) / total }
    var procentCarbo: Double { (carbo * 4) / total }
    var procentGrasimi: Double { (grasimi * 9) / total }

    var body: some View {
        VStack(spacing: 6) {
            // Bara proporțională
            GeometryReader { geo in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "#34D399"))
                        .frame(width: geo.size.width * procentProteine)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "#60A5FA"))
                        .frame(width: geo.size.width * procentCarbo)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "#F59E0B"))
                        .frame(width: max(0, geo.size.width * procentGrasimi - 4))
                }
                .frame(height: 6)
                .clipShape(Capsule())
            }
            .frame(height: 6)

            // Legend
            HStack {
                LegendaItem(culoare: Color(hex: "#34D399"), label: "P \(Int(proteine))g")
                Spacer()
                LegendaItem(culoare: Color(hex: "#60A5FA"), label: "C \(Int(carbo))g")
                Spacer()
                LegendaItem(culoare: Color(hex: "#F59E0B"), label: "G \(Int(grasimi))g")
            }
        }
        .padding(.bottom, 8)
    }
}

struct LegendaItem: View {
    let culoare: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(culoare)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
