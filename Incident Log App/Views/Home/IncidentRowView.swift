import SwiftUI

// MARK: - IncidentRowView

struct IncidentRowView: View {

    let incident: Incident

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                // Status dot
                Circle()
                    .fill(statusColor)
                    .frame(width: 9, height: 9)
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 3) {
                    Text(incident.title)
                        .font(.headline)
                        .lineLimit(1)

                    if !incident.body.isEmpty {
                        Text(incident.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Resolution time badge
                if let time = incident.resolutionTimeFormatted {
                    Text(time)
                        .font(.caption2).bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 6) {
                // Tags
                ForEach(incident.tags.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())
                }

                Spacer()

                // Opened at
                Text(incident.openedAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch incident.status {
        case .open:       return .red
        case .inProgress: return .orange
        case .resolved:   return .green
        }
    }
}
