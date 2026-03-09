import SwiftUI

// MARK: - IncidentDetailView

struct IncidentDetailView: View {

    @Environment(IncidentViewModel.self) private var vm
    @Environment(\.modelContext) private var context

    @Bindable var incident: Incident

    @State private var showingAddUpdate       = false
    @State private var showingAddAction       = false
    @State private var showingCloseAlert      = false
    @State private var showingIncompleteAlert = false
    @State private var updateText             = ""

    var body: some View {
        List {

            // MARK: Header
            Section {
                VStack(alignment: .leading, spacing: 8) {
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
                    if !incident.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(incident.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2).fontWeight(.medium)
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(Color.accentColor.opacity(0.12))
                                        .foregroundStyle(Color.accentColor)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // MARK: Timeline
            Section {
                ForEach(incident.sortedUpdates) { update in
                    TimelineRow(update: update, isLast: update.id == incident.sortedUpdates.last?.id)
                }

                if incident.isOpen {
                    Button {
                        updateText = ""
                        showingAddUpdate = true
                    } label: {
                        Label("Adicionar atualização", systemImage: "plus.circle")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            } header: {
                Text("Timeline")
            }

            // MARK: Postmortem — sempre visível
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    postmortemLabel("Causa Raiz", required: true, filled: !incident.rootCause.isEmpty)
                    TextField("O que causou o incidente?", text: $incident.rootCause, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.body)
                }
            } header: { Text("Postmortem") }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    postmortemLabel("Lições Aprendidas", required: true, filled: !incident.lessonsLearned.isEmpty)
                    TextField("O que aprendemos?", text: $incident.lessonsLearned, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.body)
                }
            }

            // MARK: Plano de ação
            Section {
                postmortemLabel("Plano de Ação", required: true, filled: !incident.actionItems.isEmpty)

                if !incident.shortTermActions.isEmpty {
                    Text("Curto Prazo")
                        .font(.caption).fontWeight(.semibold).foregroundStyle(.orange)
                    ForEach(incident.shortTermActions) { item in
                        ActionItemRow(item: item)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach {
                            vm.deleteActionItem(incident.shortTermActions[$0], from: incident, context: context)
                        }
                    }
                }

                if !incident.longTermActions.isEmpty {
                    Text("Longo Prazo")
                        .font(.caption).fontWeight(.semibold).foregroundStyle(.blue)
                    ForEach(incident.longTermActions) { item in
                        ActionItemRow(item: item)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach {
                            vm.deleteActionItem(incident.longTermActions[$0], from: incident, context: context)
                        }
                    }
                }

                Button {
                    showingAddAction = true
                } label: {
                    Label("Adicionar ação", systemImage: "plus.circle")
                        .foregroundStyle(Color.accentColor)
                }
            }

            // MARK: Notas internas
            Section("Notas Internas") {
                TextField("Anotações, links, contexto...", text: $incident.notes, axis: .vertical)
                    .lineLimit(3...8)
            }

            // MARK: Export
            Section {
                if let url = PostmortemExporter.export(incident: incident) {
                    ShareLink(
                        item: url,
                        subject: Text(incident.title),
                        message: Text("Postmortem — \(incident.title)")
                    ) {
                        Label("Exportar Postmortem (.md)", systemImage: "doc.text")
                    }
                }
            }

            // MARK: Encerrar / Reabrir
            Section {
                if incident.isOpen {
                    Button {
                        if vm.tryClose(incident) {
                            showingCloseAlert = false
                        } else {
                            showingIncompleteAlert = true
                        }
                    } label: {
                        Label("Encerrar incidente", systemImage: "xmark.circle")
                            .foregroundStyle(.red)
                            .fontWeight(.semibold)
                    }
                } else {
                    Button {
                        vm.reopen(incident)
                    } label: {
                        Label("Reabrir incidente", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .navigationTitle(incident.isOpen ? "Incidente Aberto" : "Encerrado")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: Add Update Sheet
        .sheet(isPresented: $showingAddUpdate) {
            AddUpdateSheet(updateText: $updateText) {
                vm.addUpdate(to: incident, text: updateText)
                showingAddUpdate = false
            }
        }

        // MARK: Add Action Sheet
        .sheet(isPresented: $showingAddAction) {
            AddActionSheet { title, responsible, deadline, isLongTerm in
                vm.addActionItem(
                    to: incident,
                    title: title,
                    responsible: responsible,
                    deadline: deadline,
                    isLongTerm: isLongTerm,
                    context: context
                )
            }
        }

        // MARK: Incomplete postmortem alert
        .alert("Postmortem incompleto", isPresented: $showingIncompleteAlert) {
            Button("Entendi", role: .cancel) {}
        } message: {
            Text("Para encerrar o incidente, preencha a causa raiz, as lições aprendidas e adicione ao menos uma ação no plano de ação.")
        }
    }

    // MARK: - Helpers

    private func postmortemLabel(_ title: String, required: Bool, filled: Bool) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
            if required {
                Image(systemName: filled ? "checkmark.circle.fill" : "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(filled ? .green : .orange)
            }
        }
    }

    private var statusBadge: some View {
        Text(incident.status.rawValue)
            .font(.caption).fontWeight(.semibold)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(incident.isOpen ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
            .foregroundStyle(incident.isOpen ? .red : .green)
            .clipShape(Capsule())
    }

    private var severityBadge: some View {
        Text(incident.severity.rawValue)
            .font(.caption).fontWeight(.bold)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Color.orange.opacity(0.15))
            .foregroundStyle(.orange)
            .clipShape(Capsule())
    }
}

// MARK: - TimelineRow

struct TimelineRow: View {
    let update: TimelineUpdate
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(isLast ? Color.green : Color.accentColor)
                    .frame(width: 9, height: 9)
                    .padding(.top, 4)
                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 2)
                        .frame(minHeight: 28)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(update.text)
                    .font(.subheadline).fontWeight(.medium)
                Text(update.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(.bottom, isLast ? 0 : 12)
        }
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

// MARK: - AddUpdateSheet

struct AddUpdateSheet: View {
    @Binding var updateText: String
    @Environment(\.dismiss) private var dismiss
    let onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Nova atualização") {
                    TextField("O que aconteceu agora?", text: $updateText, axis: .vertical)
                        .lineLimit(3...8)
                }
                Section {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text("Timestamp registrado automaticamente")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Adicionar Atualização")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") { onConfirm() }
                        .fontWeight(.semibold)
                        .disabled(updateText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - AddActionSheet

struct AddActionSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title       = ""
    @State private var responsible = ""
    @State private var deadline    = Date().addingTimeInterval(60*60*24*7)
    @State private var hasDeadline = false
    @State private var isLongTerm  = false

    let onConfirm: (String, String, Date?, Bool) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Ação") {
                    TextField("Descreva a ação a ser tomada", text: $title, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Responsável (opcional)", text: $responsible)
                }
                Section("Prazo") {
                    Toggle("Definir prazo", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Prazo", selection: $deadline, displayedComponents: .date)
                    }
                }
                Section("Tipo") {
                    Toggle("Longo prazo", isOn: $isLongTerm)
                    Text(isLongTerm ? "Ação estratégica, sem urgência imediata." : "Ação de curto prazo, aplicar o quanto antes.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Nova Ação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        onConfirm(title, responsible, hasDeadline ? deadline : nil, isLongTerm)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        IncidentDetailView(incident: {
            let i = Incident(title: "API fora do ar", body: "Usuários não conseguem acessar.", severity: .p1, affectedTeams: "Suporte, Produto")
            i.addUpdate(text: "Time acionado para investigação")
            i.addUpdate(text: "Causa identificada — IP bloqueado no firewall")
            i.rootCause = "Novo IP não cadastrado nas regras do firewall."
            i.lessonsLearned = "Checklist de pré-ativação para novos IPs."
            return i
        }())
        .environment(IncidentViewModel())
    }
}
