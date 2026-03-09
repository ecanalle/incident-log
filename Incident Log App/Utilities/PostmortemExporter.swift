import Foundation

// MARK: - PostmortemExporter

enum PostmortemExporter {

    static func export(incident: Incident) -> URL? {
        let md  = buildMarkdown(incident: incident)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(slug(incident.title)).md")
        do {
            try md.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Builder

    private static func buildMarkdown(incident: Incident) -> String {
        var md = ""

        // Header
        md += "# Incidente — \(incident.title)\n\n"
        md += "**Data:** \(incident.openedAt.formatted(date: .long, time: .omitted))  \n"
        md += "**Severidade:** \(incident.severity.rawValue)  \n"
        md += "**Status:** \(incident.status.rawValue)  \n"
        if !incident.affectedTeams.isEmpty {
            md += "**Times afetados:** \(incident.affectedTeams)  \n"
        }
        if !incident.tags.isEmpty {
            md += "**Tags:** \(incident.tags.joined(separator: ", "))  \n"
        }
        md += "\n---\n\n"

        // Resumo
        if !incident.body.isEmpty {
            md += "## Resumo Executivo\n\n\(incident.body)\n\n"
        }

        // Timeline
        if !incident.sortedUpdates.isEmpty {
            md += "## Linha do Tempo\n\n"
            md += "| Evento | Horário |\n"
            md += "| :----- | :------ |\n"
            for update in incident.sortedUpdates {
                let time = update.timestamp.formatted(date: .omitted, time: .shortened)
                md += "| \(update.text) | \(time) |\n"
            }
            if let duration = incident.resolutionTimeFormatted {
                md += "| **Duração total** | **\(duration)** |\n"
            }
            md += "\n"
        }

        // Causa raiz
        if !incident.rootCause.isEmpty {
            md += "## Análise da Causa Raiz\n\n\(incident.rootCause)\n\n"
        }

        // Plano de ação
        let short = incident.shortTermActions
        let long  = incident.longTermActions
        if !short.isEmpty || !long.isEmpty {
            md += "## Plano de Ação\n\n"
            if !short.isEmpty {
                md += "### Curto Prazo\n\n"
                for item in short {
                    let check    = item.isCompleted ? "x" : " "
                    let resp     = item.responsible.isEmpty ? "" : " — \(item.responsible)"
                    let deadline = item.deadline.map { " — \($0.formatted(date: .abbreviated, time: .omitted))" } ?? ""
                    md += "- [\(check)] \(item.title)\(resp)\(deadline)\n"
                }
                md += "\n"
            }
            if !long.isEmpty {
                md += "### Longo Prazo\n\n"
                for item in long {
                    let check    = item.isCompleted ? "x" : " "
                    let resp     = item.responsible.isEmpty ? "" : " — \(item.responsible)"
                    let deadline = item.deadline.map { " — \($0.formatted(date: .abbreviated, time: .omitted))" } ?? ""
                    md += "- [\(check)] \(item.title)\(resp)\(deadline)\n"
                }
                md += "\n"
            }
        }

        // Lições aprendidas
        if !incident.lessonsLearned.isEmpty {
            md += "## Lições Aprendidas\n\n"
            let lessons = incident.lessonsLearned
                .components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            for (i, lesson) in lessons.enumerated() {
                md += "\(i + 1). \(lesson)\n"
            }
            md += "\n"
        }

        // Notas
        if !incident.notes.isEmpty {
            md += "## Notas Internas\n\n\(incident.notes)\n\n"
        }

        // Footer
        md += "---\n\n"
        md += "*Postmortem gerado em \(Date().formatted(date: .long, time: .shortened)) pelo Incident Log*\n"

        return md
    }

    private static func slug(_ title: String) -> String {
        let date  = Date().formatted(.iso8601.year().month().day())
        let clean = title
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
            .prefix(40)
        return "\(date)-\(clean)"
    }
}
