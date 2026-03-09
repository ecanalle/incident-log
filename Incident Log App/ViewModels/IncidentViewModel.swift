import Foundation
import SwiftData

// MARK: - IncidentViewModel

@Observable
final class IncidentViewModel {

    // MARK: - Filter State
    var searchText: String   = ""
    var selectedTag: String? = nil
    var showOnlyOpen: Bool   = false

    // MARK: - Form State (básico)
    var formTitle: String      = ""
    var formBody: String       = ""
    var formSeverity: Severity = .p3
    var formTags: [String]     = []
    var formNotes: String      = ""
    var formTagInput: String   = ""

    // MARK: - Form State (postmortem)
    var formRootCause: String      = ""
    var formLessonsLearned: String = ""
    var formAffectedTeams: String  = ""

    // MARK: - Form State (action items)
    var formActionItems: [ActionItemDraft] = []
    var formActionTitle: String       = ""
    var formActionResponsible: String = ""
    var formActionDeadline: Date      = Date().addingTimeInterval(60*60*24*7)
    var formActionIsLongTerm: Bool    = false

    // MARK: - Form State (timeline)
    var formTimelineEvents: [TimelineEventDraft] = []
    var formTimelineLabel: String    = ""
    var formTimelineDate: Date       = Date()

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

    func addActionItemDraft() {
        let title = formActionTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        formActionItems.append(ActionItemDraft(
            title: title,
            responsible: formActionResponsible,
            deadline: formActionDeadline,
            isLongTerm: formActionIsLongTerm
        ))
        formActionTitle       = ""
        formActionResponsible = ""
        formActionIsLongTerm  = false
    }

    func addTimelineEventDraft() {
        let label = formTimelineLabel.trimmingCharacters(in: .whitespaces)
        guard !label.isEmpty else { return }
        formTimelineEvents.append(TimelineEventDraft(label: label, timestamp: formTimelineDate))
        formTimelineLabel = ""
        formTimelineDate  = Date()
    }

    func resetForm() {
        formTitle          = ""
        formBody           = ""
        formSeverity       = .p3
        formTags           = []
        formNotes          = ""
        formTagInput       = ""
        formRootCause      = ""
        formLessonsLearned = ""
        formAffectedTeams  = ""
        formActionItems    = []
        formTimelineEvents = []
    }

    func loadForm(from incident: Incident) {
        formTitle          = incident.title
        formBody           = incident.body
        formSeverity       = incident.severity
        formTags           = incident.tags
        formNotes          = incident.notes
        formRootCause      = incident.rootCause
        formLessonsLearned = incident.lessonsLearned
        formAffectedTeams  = incident.affectedTeams
        formActionItems    = incident.actionItems.map {
            ActionItemDraft(title: $0.title, responsible: $0.responsible, deadline: $0.deadline, isLongTerm: $0.isLongTerm)
        }
        formTimelineEvents = incident.sortedTimeline.map {
            TimelineEventDraft(label: $0.label, timestamp: $0.timestamp)
        }
    }

    // MARK: - CRUD

    func createIncident(in context: ModelContext) {
        let incident = Incident(
            title:          formTitle,
            body:           formBody,
            severity:       formSeverity,
            tags:           formTags,
            notes:          formNotes,
            rootCause:      formRootCause,
            lessonsLearned: formLessonsLearned,
            affectedTeams:  formAffectedTeams
        )
        // Persist timeline events
        for (i, draft) in formTimelineEvents.enumerated() {
            incident.addTimelineEvent(label: draft.label, timestamp: draft.timestamp, order: i)
        }
        // Persist action items
        for draft in formActionItems {
            let item = ActionItem(
                title: draft.title,
                responsible: draft.responsible,
                deadline: draft.deadline,
                isLongTerm: draft.isLongTerm
            )
            context.insert(item)
            incident.actionItems.append(item)
        }
        context.insert(incident)
        resetForm()
    }

    func update(_ incident: Incident, in context: ModelContext) {
        incident.title          = formTitle
        incident.body           = formBody
        incident.severity       = formSeverity
        incident.tags           = formTags
        incident.notes          = formNotes
        incident.rootCause      = formRootCause
        incident.lessonsLearned = formLessonsLearned
        incident.affectedTeams  = formAffectedTeams

        // Replace timeline
        incident.timeline.forEach { context.delete($0) }
        incident.timeline = []
        for (i, draft) in formTimelineEvents.enumerated() {
            incident.addTimelineEvent(label: draft.label, timestamp: draft.timestamp, order: i)
        }

        // Replace action items
        incident.actionItems.forEach { context.delete($0) }
        incident.actionItems = []
        for draft in formActionItems {
            let item = ActionItem(
                title: draft.title,
                responsible: draft.responsible,
                deadline: draft.deadline,
                isLongTerm: draft.isLongTerm
            )
            context.insert(item)
            incident.actionItems.append(item)
        }
    }

    func delete(_ incident: Incident, from context: ModelContext) {
        context.delete(incident)
    }

    func resolve(_ incident: Incident) { incident.resolve() }
    func reopen(_ incident: Incident)  { incident.reopen() }
}

// MARK: - Draft Types (form-only, not persisted)

struct ActionItemDraft: Identifiable {
    let id = UUID()
    var title: String
    var responsible: String
    var deadline: Date?
    var isLongTerm: Bool
}

struct TimelineEventDraft: Identifiable {
    let id = UUID()
    var label: String
    var timestamp: Date
}
