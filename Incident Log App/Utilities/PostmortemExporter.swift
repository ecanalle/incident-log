import Foundation

// MARK: - PostmortemExporter

enum PostmortemExporter {

    /// Gera o postmortem em Markdown e retorna a URL do arquivo temporário.
    static func export(incident: Incident) -> URL? {
        let md = buildMarkdown(incident: incident)
        let filename = "\(slug(incident.title)).md"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
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

        // Resumo executivo
        if !incident.body.isEmpty {
            md += "## Resumo Executivo\n\n"
            md += "\(incident.body)\n\n"
        }

        // Timeline
        if !incident.sortedTimeline.isEmpty {
            md += "## Linha do Tempo\n\n"
            md += "| Evento | Horário |\n"
            md += "| :----- | :------ |\n"
            for event in incident.sortedTimeline {
                let time = event.timestamp.formatted(date: .omitted, time: .shortened)
                md += "| \(event.label) | \(time) |\n"
            }
            if let duration = incident.resolutionTimeFormatted {
                md += "| **Duração da indisponibilidade** | **\(duration)** |\n"
            }
            md += "\n"
        }

        // Causa raiz
        if !incident.rootCause.isEmpty {
            md += "## Análise da Causa Raiz\n\n"
            md += "\(incident.rootCause)\n\n"
        }

        // Plano de ação
        let shortTerm = incident.shortTermActions
        let longTerm  = incident.longTermActions

        if !shortTerm.isEmpty || !longTerm.isEmpty {
            md += "## Plano de Ação\n\n"

            if !shortTerm.isEmpty {
                md += "### Ações de Curto Prazo\n\n"
                for item in shortTerm {
                    let check    = item.isCompleted ? "x" : " "
                    let deadline = item.deadline.map { " — Prazo: \($0.formatted(date: .abbreviated, time: .omitted))" } ?? ""
                    let resp     = item.responsible.isEmpty ? "" : " — Responsável: \(item.responsible)"
                    md += "- [\(check)] \(item.title)\(resp)\(deadline)\n"
                }
                md += "\n"
            }

            if !longTerm.isEmpty {
                md += "### Ações de Longo Prazo\n\n"
                for item in longTerm {
                    let check    = item.isCompleted ? "x" : " "
                    let deadline = item.deadline.map { " — Prazo: \($0.formatted(date: .abbreviated, time: .omitted))" } ?? ""
                    let resp     = item.responsible.isEmpty ? "" : " — Responsável: \(item.responsible)"
                    md += "- [\(check)] \(item.title)\(resp)\(deadline)\n"
                }
                md += "\n"
            }
        }

        // Lições aprendidas
        if !incident.lessonsLearned.isEmpty {
            md += "## Lições Aprendidas\n\n"
            // Split by line breaks for numbered list
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
            md += "## Notas\n\n"
            md += "\(incident.notes)\n\n"
        }

        // Footer
        md += "---\n\n"
        md += "*Postmortem gerado em \(Date().formatted(date: .long, time: .shortened)) pelo Incident Log*\n"

        return md
    }

    // MARK: - Helpers

    private static func slug(_ title: String) -> String {
        let date = Date().formatted(.iso8601.year().month().day())
        let clean = title
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
            .prefix(40)
        return "\(date)-\(clean)"
    }
}
