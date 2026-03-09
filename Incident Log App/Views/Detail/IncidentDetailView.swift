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
                        severityBadge
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
                            .font(.body).foregroundStyle(.secondary)
                    }
                    if !incident.affectedTeams.isEmpty {
                        Label(incident.affectedTeams, systemImage: "person.2")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            // MARK: Timeline visual
            if !incident.sortedTimeline.isEmpty {
                Section("Timeline") {
                    TimelineView(events: incident.sortedTimeline)
                }
            }

            // MARK: Causa raiz
            if !incident.rootCause.isEmpty {
                Section("Causa Raiz") {
                    Text(incident.rootCause)
                        .font(.body).foregroundStyle(.secondary)
                }
            }

            // MARK: Plano de ação
            let shortTerm = incident.shortTermActions
            let longTerm  = incident.longTermActions

            if !shortTerm.isEmpty || !longTerm.isEmpty {
                Section("Plano de Ação") {
                    if !shortTerm.isEmpty {
                        Text("Curto Prazo")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(.orange)
                        ForEach(shortTerm) { item in
                            ActionItemRow(item: item)
                        }
                    }
                    if !longTerm.isEmpty {
                        Text("Longo Prazo")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(.blue)
                        ForEach(longTerm) { item in
                            ActionItemRow(item: item)
                        }
                    }
                }
            }

            // MARK: Lições aprendidas
            if !incident.lessonsLearned.isEmpty {
                Section("Lições Aprendidas") {
                    Text(incident.lessonsLearned)
                        .font(.body).foregroundStyle(.secondary)
                }
            }

            // MARK: Notas
            if !incident.notes.isEmpty {
                Section("Notas") {
                    Text(incident.notes)
                        .font(.body).foregroundStyle(.secondary)
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
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Color.accentColor.opacity(0.12))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }

            // MARK: Export
            Section {
                let mdURL = PostmortemExporter.export(incident: incident)
                if let url = mdURL {
                    ShareLink(item: url, subject: Text(incident.title), message: Text("Postmortem gerado pelo Incident Log")) {
                        Label("Exportar Postmortem (.md)", systemImage: "doc.text")
                    }
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
        .confirmationDialog("Resolver incidente?", isPresented: $showingResolve, titleVisibility: .visible) {
            Button("Resolver agora") { vm.resolve(incident) }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("O tempo de resolução será registrado agora.")
        }
    }

    // MARK: - Badges

    private var statusBadge: some View {
        Text(incident.status.rawValue)
            .font(.caption).fontWeight(.semibold)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(statusColor.opacity(0.15))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    private var severityBadge: some View {
        Text(incident.severity.label)
            .font(.caption).fontWeight(.bold)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(severityColor.opacity(0.15))
            .foregroundStyle(severityColor)
            .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch incident.status {
        case .open:       return .red
        case .inProgress: return .orange
        case .resolved:   return .green
        }
    }

    private var severityColor: Color {
        switch incident.severity {
        case .p1: return .red
        case .p2: return .orange
        case .p3: return .yellow
        case .p4: return .blue
        }
    }
}

// MARK: - TimelineView

struct TimelineView: View {
    let events: [TimelineEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(index == 0 ? Color.red : index == events.count - 1 ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                            .padding(.top, 4)
                        if index < events.count - 1 {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.25))
                                .frame(width: 2)
                                .frame(minHeight: 32)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.label)
                            .font(.subheadline).fontWeight(.medium)
                        Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.bottom, index < events.count - 1 ? 16 : 0)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ActionItemRow

struct ActionItemRow: View {
    @Bindable var item: ActionItem

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isCompleted ? .green : .secondary)
                .onTapGesture { item.isCompleted.toggle() }
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline)
                    .strikethrough(item.isCompleted, color: .secondary)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    if !item.responsible.isEmpty {
                        Label(item.responsible, systemImage: "person")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    if let deadline = item.deadline {
                        Label(deadline.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}
