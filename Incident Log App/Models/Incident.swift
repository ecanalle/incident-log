import Foundation
import SwiftData

// MARK: - Severity

enum Severity: String, Codable, CaseIterable {
    case p1 = "P1"
    case p2 = "P2"
    case p3 = "P3"
    case p4 = "P4"

    var label: String { rawValue }

    var color: String {
        switch self {
        case .p1: return "red"
        case .p2: return "orange"
        case .p3: return "yellow"
        case .p4: return "blue"
        }
    }

    var description: String {
        switch self {
        case .p1: return "Crítico — sistema fora do ar"
        case .p2: return "Alto — funcionalidade comprometida"
        case .p3: return "Médio — degradação parcial"
        case .p4: return "Baixo — impacto mínimo"
        }
    }
}

// MARK: - Status

enum IncidentStatus: String, Codable {
    case open       = "Aberto"
    case inProgress = "Em andamento"
    case resolved   = "Resolvido"
}

// MARK: - ActionItem

@Model
final class ActionItem {
    var id: UUID
    var title: String
    var responsible: String
    var deadline: Date?
    var isCompleted: Bool
    var isLongTerm: Bool

    init(
        title: String,
        responsible: String = "",
        deadline: Date? = nil,
        isLongTerm: Bool = false
    ) {
        self.id          = UUID()
        self.title       = title
        self.responsible = responsible
        self.deadline    = deadline
        self.isCompleted = false
        self.isLongTerm  = isLongTerm
    }
}

// MARK: - TimelineEvent

@Model
final class TimelineEvent {
    var id: UUID
    var label: String
    var timestamp: Date
    var order: Int

    init(label: String, timestamp: Date, order: Int) {
        self.id        = UUID()
        self.label     = label
        self.timestamp = timestamp
        self.order     = order
    }
}

// MARK: - Incident

@Model
final class Incident {

    var id: UUID
    var title: String
    var body: String
    var severity: Severity
    var status: IncidentStatus
    var tags: [String]
    var openedAt: Date
    var resolvedAt: Date?
    var notes: String

    // MARK: Postmortem
    var rootCause: String
    var lessonsLearned: String
    var affectedTeams: String

    @Relationship(deleteRule: .cascade) var actionItems: [ActionItem]
    @Relationship(deleteRule: .cascade) var timeline: [TimelineEvent]

    init(
        title: String,
        body: String = "",
        severity: Severity = .p3,
        tags: [String] = [],
        notes: String = "",
        rootCause: String = "",
        lessonsLearned: String = "",
        affectedTeams: String = ""
    ) {
        self.id             = UUID()
        self.title          = title
        self.body           = body
        self.severity       = severity
        self.status         = .open
        self.tags           = tags
        self.openedAt       = Date()
        self.resolvedAt     = nil
        self.notes          = notes
        self.rootCause      = rootCause
        self.lessonsLearned = lessonsLearned
        self.affectedTeams  = affectedTeams
        self.actionItems    = []
        self.timeline       = []
    }

    // MARK: - Computed

    var resolutionTime: TimeInterval? {
        guard let resolved = resolvedAt else { return nil }
        return resolved.timeIntervalSince(openedAt)
    }

    var resolutionTimeFormatted: String? {
        guard let seconds = resolutionTime else { return nil }
        let hours   = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)min" }
        return "\(minutes)min"
    }

    var isOpen: Bool          { status != .resolved }
    var shortTermActions: [ActionItem] { actionItems.filter { !$0.isLongTerm }.sorted { !$0.isCompleted && $1.isCompleted } }
    var longTermActions:  [ActionItem] { actionItems.filter {  $0.isLongTerm }.sorted { !$0.isCompleted && $1.isCompleted } }
    var sortedTimeline:   [TimelineEvent] { timeline.sorted { $0.order < $1.order } }

    // MARK: - Actions

    func resolve() {
        status     = .resolved
        resolvedAt = Date()
        addTimelineEvent(label: "Resolvido", timestamp: Date(), order: timeline.count)
    }

    func reopen() {
        status     = .open
        resolvedAt = nil
    }

    func addTimelineEvent(label: String, timestamp: Date = Date(), order: Int? = nil) {
        let event = TimelineEvent(
            label: label,
            timestamp: timestamp,
            order: order ?? timeline.count
        )
        timeline.append(event)
    }
}
