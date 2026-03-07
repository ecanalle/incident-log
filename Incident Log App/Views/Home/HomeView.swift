import SwiftUI
import SwiftData

// MARK: - HomeView

struct HomeView: View {

    @Environment(IncidentViewModel.self) private var vm
    @Environment(\.modelContext) private var context
    @Query private var incidents: [Incident]

    @State private var showingNewIncident = false

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            Group {
                if filteredIncidents.isEmpty {
                    emptyState
                } else {
                    incidentList
                }
            }
            .navigationTitle("Incidentes")
            .searchable(text: $vm.searchText, prompt: "Buscar incidente...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewIncident = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    filterMenu
                }
            }
            .sheet(isPresented: $showingNewIncident) {
                NewIncidentView()
            }
        }
    }

    // MARK: - Subviews

    private var incidentList: some View {
        List {
            // Tags filter chips
            if !allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        tagChip(label: "Todos", isSelected: vm.selectedTag == nil) {
                            vm.selectedTag = nil
                        }
                        ForEach(allTags, id: \.self) { tag in
                            tagChip(label: tag, isSelected: vm.selectedTag == tag) {
                                vm.selectedTag = vm.selectedTag == tag ? nil : tag
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }

            ForEach(filteredIncidents) { incident in
                NavigationLink(destination: IncidentDetailView(incident: incident)) {
                    IncidentRowView(incident: incident)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { vm.delete(filteredIncidents[$0], from: context) }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Nenhum incidente")
                .font(.title3).bold()
            Text("Toque em + para registrar um novo incidente.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var filterMenu: some View {
        Menu {
            Toggle("Apenas abertos", isOn: Binding(
                get: { vm.showOnlyOpen },
                set: { vm.showOnlyOpen = $0 }
            ))
        } label: {
            Image(systemName: vm.showOnlyOpen ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        }
    }

    private func tagChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption).fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemFill))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var filteredIncidents: [Incident] { vm.filtered(incidents) }
    private var allTags: [String]             { vm.allTags(from: incidents) }
}
