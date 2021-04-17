import Cocoa

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var nameBadInputFeedback: NSTextField!
    
    var delegate: PreferencesWindowDelegate?
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center() // Center the popover
        self.window?.makeKeyAndOrderFront(nil) // Make popover appear on top of anything else
        
        NSApp.activate(ignoringOtherApps: true) // Activate popover
        let defaults = UserDefaults.standard

        nameTextField.insertText(defaults.string(forKey: "sehir")!)
        nameTextField.delegate = self
    }
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(nameTextField.stringValue, forKey: "sehir")
        delegate?.preferencesDidUpdate()
    }
    
    @IBAction func validate(_ sender: Any) {
        var validation = true
        
        if nameTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) == "" { // Check if name is empty
            nameBadInputFeedback.isHidden = false
            window?.shakeWindow()
            
            validation = false
            
        }
        
        if validation {
            save()
            close()
        }
    }
    
    @IBAction func closePopover(_ sender: Any) {
        close()
    }
}

extension PreferencesWindow: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        nameBadInputFeedback.isHidden = true 
    }
}
