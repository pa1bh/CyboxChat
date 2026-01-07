import SwiftUI

@main
struct CyboxChatApp: App {
    init() {
        // Initialize NotificationService early to set up delegate
        _ = NotificationService.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
