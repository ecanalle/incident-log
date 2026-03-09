import SwiftUI

// MARK: - NewIncidentView

struct NewIncidentView: View {

    @Environment(IncidentViewModel.self) private var vm
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var vm = vm
        NavigationStack {
            IncidentFormView()
                .navigationTitle("Novo Incidente")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { vm.resetForm(); dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Registrar") {
                            vm.createIncident(in: context)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .disabled(vm.formTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
        }
    }
}

// MARK: - EditIncidentView

struct EditIncidentView: View {

    @Environment(IncidentViewModel.self) private var vm
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let incident: Incident

    var body: some View {
        NavigationStack {
            IncidentFormView()
                .navigationTitle("Editar Incidente")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Salvar") {
                            vm.update(incident, in: context)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .disabled(vm.formTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
        }
    }
}

// MARK: - IncidentFormView (shared form)

struct IncidentFormView: View {

    @Environment(IncidentViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        Form {

            // MARK: Básico
            Section("Informações") {
                TextField("Título do incidente", text: $vm.formTitle)
                TextField("Descrição (opcional)", text: $vm.formBody, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Times afetados", text: $vm.formAffectedTeams)
            }

            // MARK: Tags
            Section("Tags") {
                tagEditor(tags: $vm.formTags, input: $vm.formTagInput) {
                    vm.addTagFromInput()
                }
            }

            // MARK: Timeline
            Section("Timeline") {
                if !vm.formTimelineEvents.isEmpty {
                    ForEach(vm.formTimelineEvents) { draft in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(draft.label).font(.subheadline)
                                Text(draft.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                vm.formTimelineEvents.removeAll { $0.id == draft.id }
                            } label: {
                                Image(systemName: "xmark").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                TextField("Evento (ex: Incidente identificado)", text: $vm.formTimelineLabel)
                    .submitLabel(.done)
                    .onSubmit { vm.addTimelineEventDraft() }
                DatePicker("Data/hora", selection: $vm.formTimelineDate, displayedComponents: [.date, .hourAndMinute])
                Button("Adicionar evento") { vm.addTimelineEventDraft() }
                    .disabled(vm.formTimelineLabel.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // MARK: Postmortem
            Section("Causa Raiz") {
                TextField("O que causou o incidente?", text: $vm.formRootCause, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Plano de Ação") {
                if !vm.formActionItems.isEmpty {
                    ForEach(vm.formActionItems) { draft in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(draft.title).font(.subheadline)
                                HStack(spacing: 6) {
                                    if !draft.responsible.isEmpty {
                                        Text(draft.responsible).font(.caption2).foregroundStyle(.secondary)
                                    }
                                    Text(draft.isLongTerm ? "Longo prazo" : "Curto prazo")
                                        .font(.caption2)
                                        .foregroundStyle(draft.isLongTerm ? .blue : .orange)
                                }
                            }
                            Spacer()
                            Button {
                                vm.formActionItems.removeAll { $0.id == draft.id }
                            } label: {
                                Image(systemName: "xmark").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                TextField("Ação (ex: Revisar processo de cadastro)", text: $vm.formActionTitle)
                    .submitLabel(.done)
                    .onSubmit { vm.addActionItemDraft() }
                TextField("Responsável", text: $vm.formActionResponsible)
                DatePicker("Prazo", selection: $vm.formActionDeadline, displayedComponents: .date)
                Toggle("Longo prazo", isOn: $vm.formActionIsLongTerm)
                Button("Adicionar ação") { vm.addActionItemDraft() }
                    .disabled(vm.formActionTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Section("Lições Aprendidas") {
                TextField("O que aprendemos com esse incidente?", text: $vm.formLessonsLearned, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section("Notas") {
                TextField("Observações, links, contexto...", text: $vm.formNotes, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
    }

    // MARK: - Tag Editor

    @ViewBuilder
    private func tagEditor(tags: Binding<[String]>, input: Binding<String>, onAdd: @escaping () -> Void) -> some View {
        if !tags.wrappedValue.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags.wrappedValue, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag).font(.caption).fontWeight(.medium)
                            Button {
                                tags.wrappedValue.removeAll { $0 == tag }
                            } label: {
                                Image(systemName: "xmark").font(.caption2)
                            }
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        HStack {
            TextField("Adicionar tag...", text: input)
                .submitLabel(.done)
                .onSubmit { onAdd() }
            Button("Adicionar") { onAdd() }
                .disabled(input.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}
