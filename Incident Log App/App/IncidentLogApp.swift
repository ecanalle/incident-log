import SwiftUI
import SwiftData

@main
struct IncidentLogApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Incident.self)
    }
}
