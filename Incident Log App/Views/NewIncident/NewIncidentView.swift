import SwiftUI

// MARK: - NewIncidentView

struct NewIncidentView: View {

    @Environment(IncidentViewModel.self) private var vm
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            Form {
                // MARK: Info básica
                Section("Informações") {
                    TextField("Título do incidente", text: $vm.formTitle)
                    TextField("Descrição (opcional)", text: $vm.formBody, axis: .vertical)
                        .lineLimit(3...6)
                }

                // MARK: Tags
                Section("Tags") {
                    if !vm.formTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(vm.formTags, id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text(tag).font(.caption).fontWeight(.medium)
                                        Button {
                                            vm.formTags.removeAll { $0 == tag }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.caption2)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.accentColor.opacity(0.12))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    HStack {
                        TextField("Adicionar tag...", text: $vm.formTagInput)
                            .submitLabel(.done)
                            .onSubmit { vm.addTagFromInput() }
                        Button("Adicionar") { vm.addTagFromInput() }
                            .disabled(vm.formTagInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                // MARK: Notas
                Section("Notas") {
                    TextField("Observações, links, contexto...", text: $vm.formNotes, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle("Novo Incidente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        vm.resetForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Registrar") {
                        vm.createIncident(in: context)
                        dismiss()
                    }
                    .disabled(vm.formTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
