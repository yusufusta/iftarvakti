//
//  ContentView.swift
//  iftar_vakti
//
//  Created by Yusuf Usta on 1.03.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var prayerTimeManager = PrayerTimeManager.shared
    @AppStorage("selectedLanguage") private var selectedLanguage = "tr"
    @AppStorage("selectedCountry") private var selectedCountry = "TR"
    @AppStorage("selectedCity") private var selectedCity = "Istanbul"
    @AppStorage("selectedDistrict") private var selectedDistrict = "Fatih"
    @AppStorage("menuBarDisplayStyle") private var menuBarDisplayStyle = "short"
    @AppStorage("countdownStyle") private var countdownStyle = "numeric"
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 20) {
            if prayerTimeManager.isRamadan {
                GroupBox {
                    Grid(alignment: .leading, horizontalSpacing: 8) {
                        GridRow {
                            Image(
                                systemName: prayerTimeManager.isIftar
                                    ? "moon.stars.fill" : "sun.max.fill"
                            )
                            .font(.title2)
                            .foregroundStyle(prayerTimeManager.isIftar ? .indigo : .orange)

                            Text(prayerTimeManager.selectedLocation)
                                .font(.headline)
                                .gridCellColumns(2)

                            Text("(\(prayerTimeManager.currentRamadanDay). Gün)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        GridRow {
                            if let nextTime = prayerTimeManager.nextPrayerTime {
                                Text("Vakit: \(nextTime.formatted(date: .omitted, time: .shortened))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .gridCellColumns(4)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .backgroundStyle(.clear)
                .frame(maxWidth: .infinity)

                if prayerTimeManager.isLoading {
                    ProgressView("Namaz vakitleri yükleniyor...")
                } else if let error = prayerTimeManager.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Tekrar Dene") {
                            prayerTimeManager.fetchPrayerTimes()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    // Vakit Bilgileri
                    VStack(spacing: 4) {
                        Text(prayerTimeManager.isIftar ? "İFTAR VAKTİNE" : "SAHUR VAKTİNE")
                            .font(.headline)

                        if countdownStyle == "numeric" {
                            Text(prayerTimeManager.remainingTimeString)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .monospacedDigit()
                        } else {
                            Text(prayerTimeManager.remainingTimeText)
                                .font(.title)
                        }

                        Text("KALDI")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }

                // Butonlar
                HStack(spacing: 12) {
                    Button("Ayarlar") {
                        openWindow(id: "settings")
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Kapat") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.plain)
                }

                // Alt Linkler
                HStack {
                    Text("[GitHub](https://github.com/yusufusta/iftarvakti)").font(.system(size: 9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("[yusufusta.dev](https://yusufusta.dev)").font(.system(size: 9))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.yellow)
                    Text("Bu uygulama sadece Ramazan ayında çalışmaktadır.")
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .frame(width: 300, height: 300)
    }
}

#Preview {
    ContentView()
}
