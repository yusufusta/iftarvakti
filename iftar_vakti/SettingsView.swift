import SwiftUI

struct TurkeyData: Codable {
    let TR: Country
}

struct Country: Codable {
    let name: String
    let cities: [String: [String]]
}

struct SettingsView: View {
    @StateObject private var prayerTimeManager = PrayerTimeManager.shared
    @AppStorage("selectedLanguage") private var selectedLanguage = "tr"
    @AppStorage("selectedCountry") private var selectedCountry = "TR"
    @AppStorage("selectedCity") private var selectedCity = "Istanbul"
    @AppStorage("selectedDistrict") private var selectedDistrict = "Fatih"
    @AppStorage("menuBarDisplayStyle") private var menuBarDisplayStyle = "short"
    @AppStorage("countdownStyle") private var countdownStyle = "numeric"

    @State private var turkeyData: TurkeyData?

    private let languages = ["tr", "en"]
    private let displayStyles = ["short", "medium", "long"]

    private var cities: [String] {
        turkeyData?.TR.cities.keys.sorted() ?? []
    }

    private var districts: [String] {
        turkeyData?.TR.cities[selectedCity] ?? []
    }

    var body: some View {
        VStack(spacing: 8) {
            Form {
                Section("Dil") {
                    Picker("Dil Seçimi", selection: $selectedLanguage) {
                        Text("Türkçe").tag("tr")
                        Text("English").tag("en")
                    }
                }

                Divider()

                Section("Konum") {
                    Picker("Şehir", selection: $selectedCity) {
                        ForEach(cities, id: \.self) { city in
                            Text(city).tag(city)
                        }
                    }

                    Picker("İlçe", selection: $selectedDistrict) {
                        ForEach(districts, id: \.self) { district in
                            Text(district).tag(district)
                        }
                    }
                }

                Divider()

                Section("Görünüm") {
                    Picker("Menü Bar Stili", selection: $menuBarDisplayStyle) {
                        Text("Kısa").tag("short")
                        Text("Orta").tag("medium")
                        Text("Uzun").tag("long")
                    }

                    Picker("Geri Sayım Formatı", selection: $countdownStyle) {
                        Text("Sayısal (00:00:00)").tag("numeric")
                        Text("Yazı (5 saat 30 dakika)").tag("text")
                    }
                }
            }
            .formStyle(.grouped)

            Button("Değişiklikleri Uygula") {
                prayerTimeManager.fetchPrayerTimes()
                NSApplication.shared.keyWindow?.close()
            }
            .buttonStyle(.borderedProminent)
            .padding(.vertical, 8)
        }
        .frame(width: 300)
        .padding(8)
        .onAppear {
            loadCityData()
        }
        .onChange(of: selectedCity) { _ in
            if let firstDistrict = districts.first {
                selectedDistrict = firstDistrict
            }
        }
    }

    private func loadCityData() {
        if let url = Bundle.main.url(forResource: "cities", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(TurkeyData.self, from: data)
        {
            turkeyData = decoded
        }
    }
}
