import SwiftUI

struct MaintenanceTaskRow: View {
    let task: MaintenanceTask

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 1) {
                Text(task.name).font(.caption).fontWeight(.medium)
                HStack(spacing: 4) {
                    if task.intervalKm > 0 {
                        Text("\(Int(task.lastKm))/\(Int(task.intervalKm)) km").font(.caption2)
                    }
                    if task.intervalHours > 0 {
                        if task.intervalKm > 0 { Text("·").font(.caption2) }
                        Text("\(String(format: "%.1f", task.lastHours))/\(String(format: "%.1f", task.intervalHours)) h").font(.caption2)
                    }
                }
                .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(Int(task.overallProgress * 100))%")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .padding(.vertical, 2)
    }

    var color: Color {
        if task.isOverdue { return .red }
        if task.isDueSoon { return .orange }
        return .green
    }
}
