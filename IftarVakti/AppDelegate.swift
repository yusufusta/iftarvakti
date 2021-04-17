import Cocoa
import Foundation

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, PreferencesWindowDelegate {

    let DEFAULT_NAME = "İftar"
    let DEFAULT_DATE = NSDate(timeIntervalSince1970: 1618670600)
    
    var countToDate = NSDate(timeIntervalSince1970: 1618870600)
    var countdownName = "İftar"
    var sehir_default = "istanbul"
    var sehir = ""
    var showName = true
    var showSeconds = true
    var zeroPad = false

    var formatter = NumberFormatter()

    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    @IBOutlet weak var statusMenu: NSMenu!
    var preferencesWindow: PreferencesWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        statusItem.title = "İftar Vakti"
        statusItem.menu = statusMenu
        formatter.minimumIntegerDigits = zeroPad ? 2 : 1

        Timer.scheduledTimer(timeInterval: 0.33, // 33ms ~ 30fps
                             target: self,
                             selector: #selector(tick),
                             userInfo: nil,
                             repeats: true)
        
        updatePreferences()
    }
    
    func preferencesDidUpdate() { // Delegate when setting values are updated
        updatePreferences()
    }
    
    func updatePreferences() {
        let defaults = UserDefaults.standard
        countdownName = defaults.string(forKey: "sehir") ?? DEFAULT_NAME
        sehir = defaults.string(forKey: "sehir") ?? sehir_default
        let iftar = veriCek()
        countToDate = NSDate(timeIntervalSince1970: TimeInterval(Int(iftar)!))
    }
    
    
    func veriCek() -> String {
        var iftar = ""
        do {
            iftar = try String(contentsOf: URL(string: "https://fusuf.codes/iftar.php?il=" + sehir)!)
        } catch {
            return "0";
        }

        print(iftar)
        return iftar
    }

    // Calculates the difference in time from now to the specified date and sets the statusItem title
    @objc func tick() {
        let diffSeconds = Int(countToDate.timeIntervalSinceNow)
        statusItem.title = (showName) ? countdownName + ": " : ""
        if (diffSeconds <= 0) {
            statusItem.title! += "Okundu"
        } else {
            statusItem.title! += formatTime(diffSeconds)
        }
            
    }
    
    // Convert seconds to 4 Time integers (days, hours minutes and seconds)
    func secondsToTime (_ seconds : Int) -> (Int, Int, Int, Int) {
        let days = seconds / (3600 * 24)
        var remainder = seconds % (3600 * 24)
        
        let hours = remainder / 3600
        remainder = remainder % 3600
        
        let minutes = remainder / 60
        
        let seconds = remainder % 60
        
        return (days, hours, minutes, seconds)
    }
    
    func formatTime(_ seconds: Int) -> (String) {
        let time = secondsToTime(abs(seconds))
        let hoursStr   = (time.1 != 0 || time.0 != 0)               ? formatter.string(from: NSNumber(value: time.1))! + " s " : ""
        let minutesStr = (time.2 != 0 || time.1 != 0 || time.0 != 0) ? formatter.string(from: NSNumber(value: time.2))! + " dk" : ""
        let secondsStr = (showSeconds) ? " " + formatter.string(from: NSNumber(value: time.3))! + " sn" : ""
        return hoursStr + minutesStr + secondsStr
    }

    @IBAction func toggleShowSeconds(sender: NSMenuItem) {
        if (showSeconds) {
            showSeconds = false
            sender.state = .off
        } else {
            showSeconds = true
            sender.state = .on
        }
    }

    @IBAction func toggleShowName(sender: NSMenuItem) {
        if (showName) {
            showName = false
            sender.state = .off
        } else {
            showName = true
            sender.state = .on
        }
    }

    @IBAction func toggleZeroPad(sender: NSMenuItem) {
        if (zeroPad) {
            zeroPad = false
            sender.state = .off
        } else {
            zeroPad = true
            sender.state = .on
        }
        formatter.minimumIntegerDigits = zeroPad ? 2 : 1
    }

    @IBAction func configurePreferences(_ sender: Any) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitApplication(sender: NSMenuItem) {
        NSApplication.shared.terminate(self);
    }

}
