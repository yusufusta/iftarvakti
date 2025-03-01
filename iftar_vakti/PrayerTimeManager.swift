import Foundation
import UserNotifications

class PrayerTimeManager: ObservableObject {
    static let shared = PrayerTimeManager()

    @Published var nextPrayerTime: Date?
    @Published var isIftar = false
    @Published var currentRamadanDay = 1
    @Published var remainingTimeString = ""
    @Published var remainingTimeText = ""
    @Published var isRamadan = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedLocation = ""
    @Published var hijriDateString = ""
    @Published var gregorianDateString = ""

    private var timer: Timer?
    private let calendar = Calendar(identifier: .gregorian)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    init() {
        setupDefaultValues()
        checkIfRamadan()
        if isRamadan {
            fetchPrayerTimes()
            startTimer()
            setupNotifications()
        }
        updateDateStrings()
    }

    private func updateDateStrings() {
        let now = Date()

        // Hicri tarih
        let islamicCalendar = Calendar(identifier: .islamicUmmAlQura)
        let hijriFormatter = DateFormatter()
        hijriFormatter.calendar = islamicCalendar
        hijriFormatter.dateFormat = "d MMMM yyyy"
        hijriFormatter.locale = Locale(identifier: "tr")
        hijriDateString = hijriFormatter.string(from: now)

        // Miladi tarih
        let gregorianFormatter = DateFormatter()
        gregorianFormatter.dateFormat = "d MMMM yyyy"
        gregorianFormatter.locale = Locale(identifier: "tr")
        gregorianDateString = gregorianFormatter.string(from: now)

        // Seçili konum
        if let city = UserDefaults.standard.string(forKey: "selectedCity"),
            let district = UserDefaults.standard.string(forKey: "selectedDistrict")
        {
            selectedLocation = "\(district), \(city)"
        }
    }

    private func setupDefaultValues() {
        let defaults = UserDefaults.standard

        if defaults.string(forKey: "selectedLanguage") == nil {
            defaults.set("tr", forKey: "selectedLanguage")
        }
        if defaults.string(forKey: "selectedCountry") == nil {
            defaults.set("TR", forKey: "selectedCountry")
        }
        if defaults.string(forKey: "selectedCity") == nil {
            defaults.set("Istanbul", forKey: "selectedCity")
        }
        if defaults.string(forKey: "selectedDistrict") == nil {
            defaults.set("Fatih", forKey: "selectedDistrict")
        }
        if defaults.string(forKey: "menuBarDisplayStyle") == nil {
            defaults.set("short", forKey: "menuBarDisplayStyle")
        }
    }

    private func checkIfRamadan() {
        let now = Date()
        let islamicCalendar = Calendar(identifier: .islamicUmmAlQura)
        let month = islamicCalendar.component(.month, from: now)
        isRamadan = month == 9

        if isRamadan {
            currentRamadanDay = islamicCalendar.component(.day, from: now)
        }
    }

    func fetchPrayerTimes() {
        guard let city = UserDefaults.standard.string(forKey: "selectedCity"),
            let country = UserDefaults.standard.string(forKey: "selectedCountry")
        else {
            self.errorMessage = "Şehir ve ülke bilgisi bulunamadı"
            return
        }

        isLoading = true
        errorMessage = nil
        updateDateStrings()

        let baseURL = "https://api.aladhan.com/v1/timingsByCity"
        let queryItems = [
            URLQueryItem(name: "city", value: city),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "method", value: "13"),
            URLQueryItem(name: "date", value: formatDate(Date())),
        ]

        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = queryItems

        print("Fetching prayer times from:", urlComponents.url?.absoluteString ?? "")

        URLSession.shared.dataTask(with: urlComponents.url!) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Veri çekilemedi: \(error.localizedDescription)"
                    return
                }

                guard let data = data,
                    let response = try? JSONDecoder().decode(PrayerTimesResponse.self, from: data)
                else {
                    if let dataString = String(data: data ?? Data(), encoding: .utf8) {
                        print("API Response:", dataString)
                    }
                    self?.errorMessage = "Veri işlenemedi"
                    return
                }

                self?.updatePrayerTimes(with: response.data.timings)
            }
        }.resume()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }

    private func updatePrayerTimes(with timings: Timings) {
        let now = Date()
        let today = Calendar.current.startOfDay(for: now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        // Bugünün vakitleri
        let fajrToday = combineDateWithTime(date: today, timeString: timings.Fajr)
        let maghribToday = combineDateWithTime(date: today, timeString: timings.Maghrib)

        // Yarının imsak vakti için API'yi tekrar çağırmamız gerekiyor, şimdilik bugünün vaktini kullanıyoruz
        let fajrTomorrow = combineDateWithTime(date: tomorrow, timeString: timings.Fajr)

        guard let fajr = fajrToday, let maghrib = maghribToday, let nextFajr = fajrTomorrow else {
            errorMessage = "Saat bilgisi işlenemedi"
            return
        }

        // Vakit kontrolü ve sonraki vakit belirleme
        if now < fajr {
            // Sabah ezanından önceyse (gece yarısından sonra)
            nextPrayerTime = fajr
            isIftar = false
        } else if now < maghrib {
            // İftar vaktinden önceyse
            nextPrayerTime = maghrib
            isIftar = true
        } else {
            // İftar vaktinden sonraysa, yarının sahur vakti
            nextPrayerTime = nextFajr
            isIftar = false
        }

        updateRemainingTime()
    }

    private func combineDateWithTime(date: Date, timeString: String) -> Date? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        guard let time = timeFormatter.date(from: timeString) else { return nil }

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: date)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }

    private func updateRemainingTime() {
        guard let nextTime = nextPrayerTime else { return }

        let now = Date()
        // Eğer nextTime geçmişse, vakitleri güncelle
        if now > nextTime {
            fetchPrayerTimes()
            return
        }

        let difference = calendar.dateComponents(
            [.hour, .minute, .second], from: now, to: nextTime)

        // Sayısal format (00:00:00)
        remainingTimeString = String(
            format: "%02d:%02d:%02d",
            difference.hour ?? 0,
            difference.minute ?? 0,
            difference.second ?? 0)

        // Metin format
        var textParts: [String] = []
        if let hours = difference.hour, hours > 0 {
            textParts.append("\(hours) saat")
        }
        if let minutes = difference.minute, minutes > 0 {
            textParts.append("\(minutes) dakika")
        }
        if let seconds = difference.second, seconds > 0 {
            textParts.append("\(seconds) saniye")
        }
        remainingTimeText = textParts.isEmpty ? "0 saniye" : textParts.joined(separator: " ")
    }

    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
            granted, _ in
            guard granted else { return }

            if let nextTime = self.nextPrayerTime {
                let content = UNMutableNotificationContent()
                content.title = self.isIftar ? "İftar Vakti" : "Sahur Vakti"
                content.body = self.isIftar ? "İftar vakti geldi!" : "Sahur vakti geldi!"
                content.sound = .default

                let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: nextTime)
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: triggerDate, repeats: false)

                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: trigger)

                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}

// API Response Models
struct PrayerTimesResponse: Codable {
    let data: PrayerData
}

struct PrayerData: Codable {
    let timings: Timings
}

struct Timings: Codable {
    let Fajr: String
    let Maghrib: String
}
