import SwiftUI
import SwiftData
import Charts

// MARK: - DashboardView

struct DashboardView: View {

    @Query private var incidents: [Incident]
    @Environment(IncidentViewModel.self) private var vm

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards
                    resolutionTimeChart
                    incidentsByTagChart
                    ExportButton(incidents: incidents)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Abertos",
                value: "\(openCount)",
                icon: "exclamationmark.circle.fill",
                color: .red
            )
            statCard(
                title: "Resolvidos",
                value: "\(resolvedCount)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            statCard(
                title: "Tempo médio",
                value: avgResolutionFormatted,
                icon: "clock.fill",
                color: .blue
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon).foregroundStyle(color).font(.title3)
            Text(value).font(.title2).bold()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Chart 1: Avg Resolution Time per Tag

    private var resolutionTimeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tempo médio de resolução por tag")
                .font(.headline)

            if avgTimePerTag.isEmpty {
                emptyChart
            } else {
                Chart(avgTimePerTag, id: \.tag) { item in
                    BarMark(
                        x: .value("Minutos", item.avgMinutes),
                        y: .value("Tag", item.tag)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(6)
                }
                .frame(height: CGFloat(max(120, avgTimePerTag.count * 44)))
                .chartXAxisLabel("Minutos")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Chart 2: Incidents by Tag (count)

    private var incidentsByTagChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Incidentes por tag")
                .font(.headline)

            if countPerTag.isEmpty {
                emptyChart
            } else {
                Chart(countPerTag, id: \.tag) { item in
                    SectorMark(
                        angle: .value("Total", item.count),
                        innerRadius: .ratio(0.55),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Tag", item.tag))
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, alignment: .center)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var emptyChart: some View {
        Text("Nenhum dado ainda.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
    }

    // MARK: - Computed Stats

    private var openCount: Int     { incidents.filter { $0.isOpen }.count }
    private var resolvedCount: Int { incidents.filter { !$0.isOpen }.count }

    private var avgResolution: TimeInterval? {
        let resolved = incidents.compactMap { $0.resolutionTime }
        guard !resolved.isEmpty else { return nil }
        return resolved.reduce(0, +) / Double(resolved.count)
    }

    private var avgResolutionFormatted: String {
        guard let avg = avgResolution else { return "—" }
        let mins = Int(avg) / 60
        let hrs  = mins / 60
        return hrs > 0 ? "\(hrs)h \(mins % 60)m" : "\(mins)m"
    }

    private var avgTimePerTag: [TagTimeStat] {
        let tags = vm.allTags(from: incidents)
        return tags.compactMap { tag in
            let times = incidents
                .filter { $0.tags.contains(tag) }
                .compactMap { $0.resolutionTime }
            guard !times.isEmpty else { return nil }
            let avg = times.reduce(0, +) / Double(times.count) / 60
            return TagTimeStat(tag: tag, avgMinutes: avg)
        }
    }

    private var countPerTag: [TagCountStat] {
        let tags = vm.allTags(from: incidents)
        return tags.map { tag in
            let count = incidents.filter { $0.tags.contains(tag) }.count
            return TagCountStat(tag: tag, count: count)
        }.filter { $0.count > 0 }
    }
}

// MARK: - Chart Data Models

private struct TagTimeStat  { let tag: String; let avgMinutes: Double }
private struct TagCountStat { let tag: String; let count: Int }
