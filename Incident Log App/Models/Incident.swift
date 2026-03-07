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

// MARK: - Incident Model

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

    init(
        title: String,
        body: String = "",
        severity: Severity = .p3,
        tags: [String] = [],
        notes: String = ""
    ) {
        self.id         = UUID()
        self.title      = title
        self.body       = body
        self.severity   = severity
        self.status     = .open
        self.tags       = tags
        self.openedAt   = Date()
        self.resolvedAt = nil
        self.notes      = notes
    }

    // MARK: - Computed

    /// Tempo de resolução em segundos. Nil se ainda aberto.
    var resolutionTime: TimeInterval? {
        guard let resolved = resolvedAt else { return nil }
        return resolved.timeIntervalSince(openedAt)
    }

    /// Tempo de resolução formatado (ex: "1h 23min")
    var resolutionTimeFormatted: String? {
        guard let seconds = resolutionTime else { return nil }
        let hours   = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)min" }
        return "\(minutes)min"
    }

    var isOpen: Bool { status != .resolved }

    // MARK: - Actions

    func resolve() {
        self.status     = .resolved
        self.resolvedAt = Date()
    }

    func reopen() {
        self.status     = .open
        self.resolvedAt = nil
    }
}
