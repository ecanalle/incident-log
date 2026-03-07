import SwiftUI

// MARK: - EditIncidentView

struct EditIncidentView: View {

    @Environment(IncidentViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    let incident: Incident

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            Form {
                Section("Informações") {
                    TextField("Título", text: $vm.formTitle)
                    TextField("Descrição", text: $vm.formBody, axis: .vertical)
                        .lineLimit(3...6)
                }

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
                        TextField("Adicionar tag...", text: $vm.formTagInput)
                            .submitLabel(.done)
                            .onSubmit { vm.addTagFromInput() }
                        Button("Adicionar") { vm.addTagFromInput() }
                            .disabled(vm.formTagInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("Notas") {
                    TextField("Observações...", text: $vm.formNotes, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle("Editar Incidente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        vm.update(incident)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(vm.formTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
