import SwiftUI
import PDFKit

// MARK: - ExportButton

struct ExportButton: View {

    let incidents: [Incident]
    @State private var exportItem: ExportItem? = nil
    @State private var showingOptions = false

    var body: some View {
        VStack(spacing: 12) {
            Button {
                showingOptions = true
            } label: {
                Label("Exportar dados", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .fontWeight(.semibold)
            }
        }
        .confirmationDialog("Exportar como", isPresented: $showingOptions, titleVisibility: .visible) {
            Button("CSV") {
                if let url = ExportUtility.exportCSV(incidents: incidents) {
                    exportItem = ExportItem(url: url)
                }
            }
            Button("PDF") {
                if let url = ExportUtility.exportPDF(incidents: incidents) {
                    exportItem = ExportItem(url: url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        }
        .sheet(item: $exportItem) { item in
            ShareSheet(url: item.url)
        }
    }
}

// MARK: - ExportItem

struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - ExportUtility

enum ExportUtility {

    // MARK: CSV

    static func exportCSV(incidents: [Incident]) -> URL? {
        var csv = "ID,Título,Status,Tags,Aberto em,Resolvido em,Tempo de Resolução (min),Notas\n"

        for i in incidents {
            let tags      = i.tags.joined(separator: "|")
            let openedAt  = i.openedAt.formatted(.iso8601)
            let resolvedAt = i.resolvedAt?.formatted(.iso8601) ?? ""
            let resTime   = i.resolutionTime.map { String(Int($0 / 60)) } ?? ""
            let notes     = i.notes.replacingOccurrences(of: ",", with: ";")
                                   .replacingOccurrences(of: "\n", with: " ")
            let title     = i.title.replacingOccurrences(of: ",", with: ";")

            csv += "\(i.id),\(title),\(i.status.rawValue),\(tags),\(openedAt),\(resolvedAt),\(resTime),\(notes)\n"
        }

        return writeTemp(content: csv, filename: "incidents.csv")
    }

    // MARK: PDF

    static func exportPDF(incidents: [Incident]) -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.black
            ]

            var yOffset: CGFloat = 40
            "Incident Log — Relatório".draw(at: CGPoint(x: 40, y: yOffset), withAttributes: titleAttrs)
            yOffset += 36

            for i in incidents {
                if yOffset > 780 { ctx.beginPage(); yOffset = 40 }
                let line = "[\(i.status.rawValue)] \(i.title) — \(i.openedAt.formatted(date: .abbreviated, time: .shortened))"
                line.draw(at: CGPoint(x: 40, y: yOffset), withAttributes: attrs)
                yOffset += 22

                if !i.tags.isEmpty {
                    let tagLine = "  Tags: \(i.tags.joined(separator: ", "))"
                    tagLine.draw(at: CGPoint(x: 40, y: yOffset), withAttributes: [
                        .font: UIFont.systemFont(ofSize: 11),
                        .foregroundColor: UIColor.darkGray
                    ])
                    yOffset += 18
                }
                yOffset += 6
            }
        }

        guard let url = writeTemp(data: data, filename: "incidents.pdf") else { return nil }
        return url
    }

    // MARK: Helpers

    private static func writeTemp(content: String, filename: String) -> URL? {
        guard let data = content.data(using: .utf8) else { return nil }
        return writeTemp(data: data, filename: filename)
    }

    private static func writeTemp(data: Data, filename: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}
