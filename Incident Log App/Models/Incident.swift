import Foundation
import SwiftData

// MARK: - Severity

enum Severity: String, Codable, CaseIterable {
    case p1 = "P1"
    case p2 = "P2"
    case p3 = "P3"
    case p4 = "P4"

    var description: String {
        switch self {
        case .p1: return "Crítico — sistema fora do ar"
        case .p2: return "Alto — funcionalidade comprometida"
        case .p3: return "Médio — degradação parcial"
        case .p4: return "Baixo — impacto mínimo"
        }
    }

    var colorName: String {
        switch self {
        case .p1: return "red"
        case .p2: return "orange"
        case .p3: return "yellow"
        case .p4: return "blue"
        }
    }
}

// MARK: - Status

enum IncidentStatus: String, Codable {
    case open       = "Aberto"
    case inProgress = "Em andamento"
    case resolved   = "Encerrado"
}

// MARK: - TimelineUpdate

@Model
final class TimelineUpdate {
    var id: UUID
    var text: String = ""
    var timestamp: Date = Date()
    var order: Int = 0

    init(text: String, order: Int) {
        self.id        = UUID()
        self.text      = text
        self.timestamp = Date()
        self.order     = order
    }
}

// MARK: - ActionItem

@Model
final class ActionItem {
    var id: UUID
    var title: String = ""
    var responsible: String = ""
    var deadline: Date?
    var isCompleted: Bool = false
    var isLongTerm: Bool = false

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

// MARK: - Incident

@Model
final class Incident {

    var id: UUID
    var title: String = ""
    var body: String = ""
    var severity: Severity = Severity.p3
    var status: IncidentStatus = IncidentStatus.open
    var tags: [String] = []
    var affectedTeams: String = ""
    var openedAt: Date = Date()
    var resolvedAt: Date?
    var rootCause: String = ""
    var lessonsLearned: String = ""
    var notes: String = ""

    @Relationship(deleteRule: .cascade) var updates: [TimelineUpdate] = []
    @Relationship(deleteRule: .cascade) var actionItems: [ActionItem] = []

    init(
        title: String,
        body: String = "",
        severity: Severity = .p3,
        tags: [String] = [],
        affectedTeams: String = ""
    ) {
        self.id             = UUID()
        self.title          = title
        self.body           = body
        self.severity       = severity
        self.status         = .open
        self.tags           = tags
        self.affectedTeams  = affectedTeams
        self.openedAt       = Date()
        self.resolvedAt     = nil
        self.rootCause      = ""
        self.lessonsLearned = ""
        self.notes          = ""
        self.updates        = []
        self.actionItems    = []
    }

    // MARK: - Computed

    var isOpen: Bool { status != .resolved }

    var resolutionTime: TimeInterval? {
        guard let resolved = resolvedAt else { return nil }
        return resolved.timeIntervalSince(openedAt)
    }

    var resolutionTimeFormatted: String? {
        guard let seconds = resolutionTime else { return nil }
        let hours   = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)min" : "\(minutes)min"
    }

    var sortedUpdates: [TimelineUpdate] {
        updates.sorted { $0.order < $1.order }
    }

    var shortTermActions: [ActionItem] { actionItems.filter { !$0.isLongTerm } }
    var longTermActions:  [ActionItem] { actionItems.filter {  $0.isLongTerm } }

    var isPostmortemComplete: Bool {
        !rootCause.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lessonsLearned.trimmingCharacters(in: .whitespaces).isEmpty &&
        !actionItems.isEmpty
    }

    // MARK: - Actions

    func addUpdate(text: String) {
        let update = TimelineUpdate(text: text, order: updates.count)
        updates.append(update)
        if status == .open { status = .inProgress }
    }

    func close() {
        status     = .resolved
        resolvedAt = Date()
    }

    func reopen() {
        status     = .open
        resolvedAt = nil
    }
}
