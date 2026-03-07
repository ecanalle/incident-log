import SwiftUI

// MARK: - IncidentDetailView

struct IncidentDetailView: View {

    @Environment(IncidentViewModel.self) private var vm
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var incident: Incident
    @State private var showingEdit    = false
    @State private var showingResolve = false

    var body: some View {
        List {
            // MARK: Header
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        statusBadge
                        Spacer()
                        if let time = incident.resolutionTimeFormatted {
                            Label(time, systemImage: "clock.fill")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }

                    Text(incident.title)
                        .font(.title2).bold()

                    if !incident.body.isEmpty {
                        Text(incident.body)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            // MARK: Timeline
            Section("Timeline") {
                timelineRow(
                    icon: "exclamationmark.circle.fill",
                    color: .red,
                    label: "Aberto",
                    date: incident.openedAt
                )
                if let resolved = incident.resolvedAt {
                    timelineRow(
                        icon: "checkmark.circle.fill",
                        color: .green,
                        label: "Resolvido",
                        date: resolved
                    )
                }
            }

            // MARK: Tags
            if !incident.tags.isEmpty {
                Section("Tags") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(incident.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption).fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor.opacity(0.12))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            // MARK: Notes
            if !incident.notes.isEmpty {
                Section("Notas") {
                    Text(incident.notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: Actions
            Section {
                if incident.isOpen {
                    Button {
                        showingResolve = true
                    } label: {
                        Label("Marcar como resolvido", systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                    }
                } else {
                    Button {
                        vm.reopen(incident)
                    } label: {
                        Label("Reabrir incidente", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.orange)
                    }
                }

                Button(role: .destructive) {
                    vm.delete(incident, from: context)
                    dismiss()
                } label: {
                    Label("Excluir incidente", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Detalhe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Editar") {
                    vm.loadForm(from: incident)
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditIncidentView(incident: incident)
        }
        .confirmationDialog(
            "Resolver incidente?",
            isPresented: $showingResolve,
            titleVisibility: .visible
        ) {
            Button("Resolver agora", role: .none) { vm.resolve(incident) }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("O tempo de resolução será registrado agora.")
        }
    }

    // MARK: - Helpers

    private var statusBadge: some View {
        Text(incident.status.rawValue)
            .font(.caption).fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.15))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch incident.status {
        case .open:       return .red
        case .inProgress: return .orange
        case .resolved:   return .green
        }
    }

    private func timelineRow(icon: String, color: Color, label: String, date: Date) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.subheadline).fontWeight(.medium)
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
