import Foundation
import SwiftData

// MARK: - IncidentViewModel

@Observable
final class IncidentViewModel {

    // MARK: - Filter State
    var searchText: String   = ""
    var selectedTag: String? = nil
    var showOnlyOpen: Bool   = false

    // MARK: - New Incident Form
    var formTitle: String        = ""
    var formBody: String         = ""
    var formSeverity: Severity   = .p3
    var formTags: [String]       = []
    var formTagInput: String     = ""
    var formAffectedTeams: String = ""

    // MARK: - Filtering

    func filtered(_ incidents: [Incident]) -> [Incident] {
        incidents.filter { incident in
            let matchesSearch = searchText.isEmpty
                || incident.title.localizedCaseInsensitiveContains(searchText)
                || incident.body.localizedCaseInsensitiveContains(searchText)
            let matchesTag    = selectedTag == nil || incident.tags.contains(selectedTag!)
            let matchesStatus = !showOnlyOpen || incident.isOpen
            return matchesSearch && matchesTag && matchesStatus
        }
        .sorted { $0.openedAt > $1.openedAt }
    }

    func allTags(from incidents: [Incident]) -> [String] {
        Array(Set(incidents.flatMap { $0.tags })).sorted()
    }

    // MARK: - Form Helpers

    func addTagFromInput() {
        let tag = formTagInput.trimmingCharacters(in: .whitespaces)
        guard !tag.isEmpty, !formTags.contains(tag) else { return }
        formTags.append(tag)
        formTagInput = ""
    }

    func resetForm() {
        formTitle         = ""
        formBody          = ""
        formSeverity      = .p3
        formTags          = []
        formTagInput      = ""
        formAffectedTeams = ""
    }

    // MARK: - CRUD

    func createIncident(in context: ModelContext) {
        let incident = Incident(
            title:         formTitle,
            body:          formBody,
            severity:      formSeverity,
            tags:          formTags,
            affectedTeams: formAffectedTeams
        )
        context.insert(incident) // ← insere primeiro

        // Agora cria o primeiro evento com o incident já no contexto
        let opening = TimelineUpdate(text: "Incidente aberto", order: 0)
        context.insert(opening)
        incident.updates.append(opening)

        do {
            try context.save()
            print("✅ Incidente salvo: \(incident.title)")
        } catch {
            print("❌ Erro ao salvar: \(error)")
        }

        resetForm()
    }
    
    func delete(_ incident: Incident, from context: ModelContext) {
        context.delete(incident)
    }

    // MARK: - Timeline

    func addUpdate(to incident: Incident, text: String) {
        incident.addUpdate(text: text)
    }

    // MARK: - Action Items

    func addActionItem(
        to incident: Incident,
        title: String,
        responsible: String,
        deadline: Date?,
        isLongTerm: Bool,
        context: ModelContext
    ) {
        let item = ActionItem(
            title: title,
            responsible: responsible,
            deadline: deadline,
            isLongTerm: isLongTerm
        )
        context.insert(item)
        incident.actionItems.append(item)
    }

    func deleteActionItem(_ item: ActionItem, from incident: Incident, context: ModelContext) {
        incident.actionItems.removeAll { $0.id == item.id }
        context.delete(item)
    }

    // MARK: - Close / Reopen

    /// Retorna true se pode encerrar, false se postmortem incompleto
    func tryClose(_ incident: Incident) -> Bool {
        guard incident.isPostmortemComplete else { return false }
        incident.close()
        return true
    }

    func reopen(_ incident: Incident) {
        incident.reopen()
    }
}
