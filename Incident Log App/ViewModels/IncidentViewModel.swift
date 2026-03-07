import Foundation
import SwiftData
import Combine

// MARK: - IncidentViewModel

@Observable
final class IncidentViewModel {

    // MARK: - Filter State
    var searchText: String       = ""
    var selectedTag: String?     = nil
    var showOnlyOpen: Bool       = false

    // MARK: - Form State (New / Edit)
    var formTitle: String        = ""
    var formBody: String         = ""
    var formSeverity: Severity   = .p3
    var formTags: [String]       = []
    var formNotes: String        = ""
    var formTagInput: String     = ""

    // MARK: - Filtering

    func filtered(_ incidents: [Incident]) -> [Incident] {
        incidents.filter { incident in
            let matchesSearch = searchText.isEmpty
                || incident.title.localizedCaseInsensitiveContains(searchText)
                || incident.body.localizedCaseInsensitiveContains(searchText)

            let matchesTag = selectedTag == nil
                || incident.tags.contains(selectedTag!)

            let matchesStatus = !showOnlyOpen || incident.isOpen

            return matchesSearch && matchesTag && matchesStatus
        }
        .sorted { $0.openedAt > $1.openedAt }
    }

    // MARK: - All Tags (unique, sorted)

    func allTags(from incidents: [Incident]) -> [String] {
        let all = incidents.flatMap { $0.tags }
        return Array(Set(all)).sorted()
    }

    // MARK: - Form Helpers

    func addTagFromInput() {
        let tag = formTagInput.trimmingCharacters(in: .whitespaces)
        guard !tag.isEmpty, !formTags.contains(tag) else { return }
        formTags.append(tag)
        formTagInput = ""
    }

    func resetForm() {
        formTitle    = ""
        formBody     = ""
        formSeverity = .p3
        formTags     = []
        formNotes    = ""
        formTagInput = ""
    }

    func loadForm(from incident: Incident) {
        formTitle    = incident.title
        formBody     = incident.body
        formSeverity = incident.severity
        formTags     = incident.tags
        formNotes    = incident.notes
    }

    // MARK: - CRUD

    func createIncident(in context: ModelContext) {
        let incident = Incident(
            title:    formTitle,
            body:     formBody,
            severity: formSeverity,
            tags:     formTags,
            notes:    formNotes
        )
        context.insert(incident)
        resetForm()
    }

    func update(_ incident: Incident) {
        incident.title    = formTitle
        incident.body     = formBody
        incident.severity = formSeverity
        incident.tags     = formTags
        incident.notes    = formNotes
    }

    func delete(_ incident: Incident, from context: ModelContext) {
        context.delete(incident)
    }

    func resolve(_ incident: Incident) {
        incident.resolve()
    }

    func reopen(_ incident: Incident) {
        incident.reopen()
    }
}
