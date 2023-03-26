//
//  BackendModel.swift
//  iftarvakti
//
//  Created by Yusuf Usta on 24.03.2023.
//

import Foundation
import UserNotifications

class MenuAppViewModel : ObservableObject {
    @Published var label = "İftar Vakti | Lütfen Tıklayınız";
    @Published var iller : Iller = [Il(SehirID: "0", SehirAdi: "Lütfen Bekleyiniz", SehirAdiEn: "Lütfen Bekleyiniz")];
    @Published var kalanSureApp = "Yükleniyor..."
    @Published var vakitTur = 0

    var aksamVakit : Double = 0;
    var api = Api()
    var vakitler : Vakitler? = nil
    
    var time : Int = 100;

    func run() -> Void {
        api.getIller() {
            (ils) in
            self.iller = ils
        }
        
        let selectedIlce = UserDefaults.standard.string(forKey: "selectedIlce") ?? "0"

        Task.init {
            self.vakitler = await api.getVakitlerAsync(ilceId: selectedIlce)
        }
        
        self.updateVakitler();
        
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { timer in
            self.updateVakitler()
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.333, repeats: true) { timer in
            if (self.vakitler != nil){
                let geriKalanZaman = self.getTodayAksamVakit(vakitler: self.vakitler!);
                var geriKalanZaman2 = self.getTodayImsakVakit(vakitler: self.vakitler!);
                
                let topBarStyle = UserDefaults.standard.string(forKey: "topBarStyle") ?? "saatKisa"
                let selectedIlStr = UserDefaults.standard.string(forKey: "selectedIlStr")
                let selectedIlceStr = UserDefaults.standard.string(forKey: "selectedIlceStr")
                
                var kalanSure = Int((geriKalanZaman! - Date().timeIntervalSince1970))
                var kalanSure2 = Int((geriKalanZaman2! - Date().timeIntervalSince1970))
                
                if kalanSure2 < -10 {
                    geriKalanZaman2 = self.getTodayImsakVakit(vakitler: self.vakitler!, another_day:true);
                    kalanSure2 = Int((geriKalanZaman2! - Date().timeIntervalSince1970))
                }
                
                if (kalanSure2 > kalanSure) {
                    self.vakitTur = 0;
                    
                    if (kalanSure < 1 && kalanSure > -90) {
                        self.label = "İFTAR VAKTİ!"
                        
                        let title = selectedIlceStr! + " İÇİN İFTAR VAKTİ";
                        let subtitle = "Hayırlı İftarlar..."
                        
                        self.sendNotification(title: title, subtitle: subtitle);
                        return;
                    }
                } else {
                    self.vakitTur = 1;
                    kalanSure = kalanSure2
                    
                    if (kalanSure < 1 && kalanSure > -90) {
                        self.label = "SAHUR VAKTİ!"
                        
                        let title = selectedIlceStr! + " İÇİN SAHUR VAKTİ";
                        let subtitle = "Hayırlı Sahurlar..."
                        
                        self.sendNotification(title: title, subtitle: subtitle);
                        return;
                    }

                }
                
                let now_data = self.zamanDuzenle(kalanSure)
                
                let saatCiftNokta = (now_data[0] != "" ? now_data[0] + ":" : "");
                let dkPure = (now_data[1] != "" ? now_data[1] : "");
                let saatYazi = (now_data[0] != "" ? now_data[0] + "sa:" : "")
                let dkYazi = (now_data[1] != "" ? now_data[1] + "dk:" : "")
                let snYazi = (now_data[2] != "" ? now_data[2] + "sn" : "")
                let vakitYazi = (self.vakitTur == 0 ? "İftar" : "Sahur")
                
                switch topBarStyle {
                    case "saatUzun":
                        self.label = saatYazi + dkYazi + snYazi
                    case "saatKisa":
                        self.label = saatCiftNokta + (now_data[1] != "" ? now_data[1] + ":" : "") + (now_data[2] != "" ? now_data[2] : "")
                    case "saatTurUzun":
                        self.label = vakitYazi + " | " + saatYazi + dkYazi + snYazi
                    case "saatTurKisa":
                        self.label = vakitYazi + " | " + saatCiftNokta + (now_data[1] != "" ? now_data[1] + ":" : "") + (now_data[2] != "" ? now_data[2] : "")
                    case "dakikaUzun":
                        self.label = saatYazi + (now_data[1] != "" ? now_data[1] + " dk" : "")
                    case "dakikaKisa":
                        self.label = saatCiftNokta + dkPure
                    case "boslukluUzun":
                        self.label = (now_data[0] != "" ? now_data[0] + "sa " : "") + (now_data[1] != "" ? now_data[1] + "dk " : "") + snYazi
                    case "boslukluKisa":
                        self.label = (now_data[0] != "" ? now_data[0] + " " : "") + dkPure
                    case "sehirIlceKisa":
                        self.label = selectedIlStr! + " " + selectedIlceStr! + " " + (saatCiftNokta + dkPure)
                    case "kisaTur":
                    self.label = "i | " + vakitYazi
                    case "kisa":
                        self.label = "i"
                    default:
                        self.label = "i"
                }

                self.time -= 1
                self.kalanSureApp = ""
                
                if (now_data[0] != "") {
                    self.kalanSureApp += now_data[0]
                    self.kalanSureApp += ":"
                }
                
                if (now_data[1] != "") {
                    self.kalanSureApp += now_data[1]
                    self.kalanSureApp += ":"
                }

                if (now_data[2] != "") {
                    self.kalanSureApp += now_data[2]
                }

                //print(self.label)
            } else {
                print("vakitler yok")
            }
        }
    }
    
    func sendNotification(title: String, subtitle: String) -> Void {
        let sendNotifications = UserDefaults.standard.bool(forKey: "sendNotifications")
        
        if (!sendNotifications) { return; }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        return;
    }
    
    func updateVakitler() -> Void {
        let selectedIlce = UserDefaults.standard.string(forKey: "selectedIlce")

        api.getVakitler(ilceId: selectedIlce ?? "0") {
            vakitler in
            self.vakitler = vakitler
        }
    }
    
    func getTodayAksamVakit(vakitler: Vakitler) -> Optional<TimeInterval> {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let todayDate = formatter.string(from: Date())
        
        for vakit in vakitler {
            if vakit.miladiTarihKisa == todayDate {
                let formatter2 = DateFormatter()
                
                formatter2.dateFormat = "HH:mm dd.MM.yyyy"
                let aksam = vakit.aksam ?? "00:00"
                let miladiTarih = vakit.miladiTarihKisa ?? "01.01.2020"
                
                let todayDate = formatter2.date(from: "\(aksam) \(miladiTarih)")
                return todayDate?.timeIntervalSince1970
            }
        }
        
        return -1;
    }
    
    func getTodayImsakVakit(vakitler: Vakitler, another_day:Bool = false) -> Optional<TimeInterval> {
        var date = Date()
        if another_day {
            date = date.addingTimeInterval(86400)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let todayDate = formatter.string(from: date)
        
        for vakit in vakitler {
            if vakit.miladiTarihKisa == todayDate {
                let formatter2 = DateFormatter()
                
                formatter2.dateFormat = "HH:mm dd.MM.yyyy"
                let aksam = vakit.imsak ?? "00:00"
                let miladiTarih = vakit.miladiTarihKisa ?? "01.01.2020"
                
                let todayDate = formatter2.date(from: "\(aksam) \(miladiTarih)")
                return todayDate?.timeIntervalSince1970
            }
        }
        
        return -1;
    }

    func getTodayVakit(vakitler: Vakitler) -> Vakit? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let todayDate = formatter.string(from: Date())
        
        for vakit in vakitler {
            if vakit.miladiTarihKisa == todayDate {
                return vakit;
            }
        }
        
        return nil;
    }

    // https://github.com/yusufusta/iftarvakti/blob/master/IftarVaktiV2/AppDelegate.swift#L150
    func saniyeCevirZaman (_ seconds : Int) -> (Int, Int, Int, Int) {
        let days = seconds / (3600 * 24)
        var remainder = seconds % (3600 * 24)
        
        let hours = remainder / 3600
        remainder = remainder % 3600
        let minutes = remainder / 60
        let seconds = remainder % 60
        return (days, hours, minutes, seconds)
    }
    
    func zamanDuzenle(_ seconds: Int) -> ([String]) {
        let time = saniyeCevirZaman(abs(seconds));
        let formatter = NumberFormatter();
        
        let hoursStr   = (time.1 != 0 || time.0 != 0) ? formatter.string(from: NSNumber(value: time.1))! : ""
        let minutesStr = (time.2 != 0 || time.1 != 0 || time.0 != 0) ? formatter.string(from: NSNumber(value: time.2))! : ""
        let secondsStr = formatter.string(from: NSNumber(value: time.3))!
        return [hoursStr, minutesStr, secondsStr]
    }
}
