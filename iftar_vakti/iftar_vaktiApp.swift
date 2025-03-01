//
//  iftar_vaktiApp.swift
//  iftar_vakti
//
//  Created by Yusuf Usta on 1.03.2025.
//

import SwiftUI

@main
struct iftar_vaktiApp: App {
    @StateObject private var prayerTimeManager = PrayerTimeManager.shared
    @AppStorage("menuBarDisplayStyle") private var menuBarDisplayStyle = "short"
    @AppStorage("countdownStyle") private var countdownStyle = "numeric"
    @State private var isSettingsWindowShown = false

    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Text(menuBarText)
        }
        .menuBarExtraStyle(.window)

        Window("Ayarlar", id: "settings") {
            SettingsView()
                .frame(width: 400, height: 500)
        }
        .defaultPosition(.center)
        .defaultSize(width: 400, height: 500)
    }

    private var menuBarText: String {
        if prayerTimeManager.isLoading {
            return "Yükleniyor..."
        }

        if let error = prayerTimeManager.errorMessage {
            return "⚠️ Hata"
        }

        guard prayerTimeManager.isRamadan else {
            return "Ramazan'da görüşmek üzere"
        }

        let timeString =
            countdownStyle == "numeric"
            ? prayerTimeManager.remainingTimeString : prayerTimeManager.remainingTimeText

        let type = prayerTimeManager.isIftar ? "İftar" : "Sahur"

        switch menuBarDisplayStyle {
        case "short":
            return timeString
        case "medium":
            return "\(type): \(timeString)"
        case "long":
            return "\(type)'a \(timeString) kaldı"
        default:
            return timeString
        }
    }
}
