import SwiftUI

// MARK: - ContentView

struct ContentView: View {

    @State private var viewModel = IncidentViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Incidentes", systemImage: "list.bullet.clipboard")
                }

            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.xaxis")
                }
        }
        .environment(viewModel)
    }
}
