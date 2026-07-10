import SwiftUI

struct VehicleCardView: View {
    @Bindable var vehicle: Vehicle
    @State private var showLogTrip = false
    @State private var showAddMaint = false
    @State private var showEditVehicle = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(vehicle.name).font(.headline)
                    if !vehicle.model.isEmpty {
                        Text(vehicle.model).font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if !vehicle.plate.isEmpty {
                    Text(vehicle.plate)
                        .font(.caption).fontWeight(.semibold)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                }
            }

            // Stats
            HStack(spacing: 16) {
                StatView(label: "Odometer", value: "\(Int(vehicle.odometerKm))", unit: "km")
                StatView(label: "Engine", value: String(format: "%.1f", vehicle.engineHours), unit: "hours")
            }

            // Action buttons
            HStack(spacing: 8) {
                Button { showLogTrip = true } label: {
                    Label("Log Trip", systemImage: "plus.circle").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                Button { showEditVehicle = true } label: {
                    Label("Edit", systemImage: "pencil").font(.caption)
                }
                .buttonStyle(.bordered)
            }

            // Trip History
            if !vehicle.trips.isEmpty {
                DisclosureGroup("Trip History (\(vehicle.trips.count))") {
                    ForEach(vehicle.trips.sorted(by: { $0.date > $1.date })) { trip in
                        HStack {
                            Text("+\(String(format: "%.1f", trip.km)) km")
                            Text("+\(String(format: "%.1f", trip.hours)) h")
                            Spacer()
                            Text(trip.date.formatted(date: .numeric, time: .omitted))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
                .font(.caption)
            }

            // Maintenance
            if !vehicle.maintenanceTasks.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Maintenance").font(.subheadline).fontWeight(.semibold)
                    ForEach(vehicle.maintenanceTasks) { task in
                        MaintenanceTaskRow(task: task)
                    }
                }
            }

            Button { showAddMaint = true } label: {
                Label("Add Maintenance Task", systemImage: "wrench").font(.caption)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .sheet(isPresented: $showLogTrip) {
            LogTripView(vehicle: vehicle)
        }
        .sheet(isPresented: $showAddMaint) {
            AddMaintenanceView(vehicle: vehicle)
        }
        .sheet(isPresented: $showEditVehicle) {
            EditVehicleView(vehicle: vehicle)
        }
    }
}

struct StatView: View {
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.title2).fontWeight(.bold)
            Text(unit).font(.caption2).foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(.quinary, in: RoundedRectangle(cornerRadius: 8))
    }
}
