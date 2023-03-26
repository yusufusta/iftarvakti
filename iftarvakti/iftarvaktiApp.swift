import SwiftUI
import UserNotifications

@main
struct iftarVaktiApp: App {
    @StateObject private var menuVM = MenuAppViewModel()
    @AppStorage("sendNotifications") var sendNotifications: Bool = false
    @AppStorage("selectedIlce") var selectedIlce: String = "9550"

    var api = Api()
    
    init() {
    }
    
    var body: some Scene {
        MenuBarExtra(menuVM.label) {
                ContentView()
                    .environmentObject(menuVM)
                    .onAppear {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                            sendNotifications = success;
                        }
                    }
        }
            .menuBarExtraStyle(.window)
    }
    
}
