//
//  AppDelegate.swift
//  IftarVaktiV2
//
//  Created by Yusuf Usta on 18.04.2021.
//


import Cocoa
import SwiftUI
import Alamofire

struct Zaman: Decodable {
 var iftar : Int?
 var sahur : Int?
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var menu: NSMenu!
    var sehirIsmiGoster: NSMenuItem!
    var gosterilecekYazi: String! = "İftarVaktiV2"
    var isIftar: Bool = true
    var iftarZamani: NSDate!
    var sahurZamani: NSDate!
    var iftarVeSahurYazisi: NSMenuItem!
    var sehir: String!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let defaults = UserDefaults.standard
        self.sehir = defaults.string(forKey: "sehir") ?? "istanbul"
        
        self.sehirIsmiGoster = NSMenuItem(title: "Şehir İsmini Göster", action: #selector(self.sehirIsmiAyarla), keyEquivalent: "")
        self.sehirIsmiGoster.state = (defaults.string(forKey: "sehirIsmi") == "on" ? NSControl.StateValue.on : NSControl.StateValue.off);
        
        self.iftarVeSahurYazisi = NSMenuItem(title: "İftar/Sahur Göster", action: #selector(self.iftarVeSahurYazisiAyarla), keyEquivalent: "")
        self.iftarVeSahurYazisi.state = (defaults.string(forKey: "iftarYazi") == "off" ? NSControl.StateValue.off : NSControl.StateValue.on);

        let contentView = ContentView()
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover

        let menu = NSMenu()
        menu.addItem(self.sehirIsmiGoster)
        menu.addItem(self.iftarVeSahurYazisi)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Ayarlar", action: #selector(self.togglePopover), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Kapat", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        self.menu = menu;
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        self.statusBarItem.menu = self.menu;
        if let button = self.statusBarItem.button {
            button.title = self.gosterilecekYazi
        }
        verileriGuncelle();
        Timer.scheduledTimer(timeInterval: 0.33,
                                     target: self,
                                     selector: #selector(yaziyiDegistir),
                                     userInfo: nil,
                                     repeats: true)
        Timer.scheduledTimer(timeInterval: 7200,
                                     target: self,
                                     selector: #selector(verileriGuncelle),
                                     userInfo: nil,
                                     repeats: true)

    }
    
    func uzaktanVeriGuncellendi() {
        verileriGuncelle()
    }
    
    @objc func iftarVeSahurYazisiAyarla() {
        let defaults = UserDefaults.standard
        if ( self.iftarVeSahurYazisi.state == NSControl.StateValue.on) {
            defaults.set("off", forKey: "iftarYazi")
            self.iftarVeSahurYazisi.state = NSControl.StateValue.off;
        } else {
            defaults.set("on", forKey: "iftarYazi")
            self.iftarVeSahurYazisi.state = NSControl.StateValue.on;
        }
    }
    
    @objc func sehirIsmiAyarla() {
        let defaults = UserDefaults.standard
        if ( self.sehirIsmiGoster.state == NSControl.StateValue.on) {
            defaults.set("off", forKey: "sehirIsmi")
            self.sehirIsmiGoster.state = NSControl.StateValue.off;
        } else {
            defaults.set("on", forKey: "sehirIsmi")
            self.sehirIsmiGoster.state = NSControl.StateValue.on;
        }
    }
    
    @objc func yaziyiDegistir() {
        if (self.iftarZamani != nil) {
            var kalanSure: Int = 0;
            let iftarZamaniSaniye = Int(self.iftarZamani.timeIntervalSinceNow)
            let sahurZamaniSaniye = Int(self.sahurZamani.timeIntervalSinceNow);
            
            if (sahurZamaniSaniye > iftarZamaniSaniye || sahurZamaniSaniye < 0) {
                self.isIftar = true;
                kalanSure = iftarZamaniSaniye;
            } else {
                self.isIftar = false;
                kalanSure = sahurZamaniSaniye;
            }
            
            if (kalanSure < 0) {
                self.verileriGuncelle()
            }
            
            self.statusBarItem.button?.title = (self.sehirIsmiGoster.state == NSControl.StateValue.on ? self.sehir.capitalizingFirstLetter() + " | " : "") +  (self.iftarVeSahurYazisi.state == NSControl.StateValue.on ? (self.isIftar ? "İftar: " : "Sahur: ") : "")  + self.zamanDuzenle(kalanSure)
        }
    }
    
    @objc func verileriGuncelle() {
        let defaults = UserDefaults.standard
        self.sehir = defaults.string(forKey: "sehir") ?? "istanbul"
        
        do {
            AF.request("https://fusuf.codes/iftar.php?sehir=" + self.sehir).responseJSON { response in
                let zamanlar: Zaman = try! JSONDecoder().decode(Zaman.self, from: response.data!)
                self.iftarZamani = NSDate(timeIntervalSince1970: TimeInterval(zamanlar.iftar!))
                self.sahurZamani = NSDate(timeIntervalSince1970: TimeInterval(zamanlar.sahur!))
                self.yaziyiDegistir()
            }
        } catch {
            self.statusBarItem.button?.title = "Hata!"
        }
    }
    
    func saniyeCevirZaman (_ seconds : Int) -> (Int, Int, Int, Int) {
        let days = seconds / (3600 * 24)
        var remainder = seconds % (3600 * 24)
        
        let hours = remainder / 3600
        remainder = remainder % 3600
        let minutes = remainder / 60
        let seconds = remainder % 60
        return (days, hours, minutes, seconds)
    }
    
    func zamanDuzenle(_ seconds: Int) -> (String) {
        let time = saniyeCevirZaman(abs(seconds));
        let formatter = NumberFormatter();
        
        let hoursStr   = (time.1 != 0 || time.0 != 0) ? formatter.string(from: NSNumber(value: time.1))! + "sa " : ""
        let minutesStr = (time.2 != 0 || time.1 != 0 || time.0 != 0) ? formatter.string(from: NSNumber(value: time.2))! + "dk" : ""
        let secondsStr = " " + formatter.string(from: NSNumber(value: time.3))! + "sn"
        return hoursStr + minutesStr + secondsStr
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
