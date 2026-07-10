import SwiftUI

@main
struct MaintenanceApp: App {
    init() {
        DataStore.shared.setup()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
