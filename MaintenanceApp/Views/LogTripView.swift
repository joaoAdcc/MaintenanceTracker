import SwiftUI

struct LogTripView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var vehicle: Vehicle
    @State private var km = ""
    @State private var hours = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Distance (km)", text: $km)
                        .keyboardType(.decimalPad)
                    TextField("Engine Hours", text: $hours)
                        .keyboardType(.decimalPad)
                }
                Section("Current Readings") {
                    HStack {
                        Text("Odometer")
                        Spacer()
                        Text("\(Int(vehicle.odometerKm)) km").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Engine")
                        Spacer()
                        Text(String(format: "%.1f h", vehicle.engineHours)).foregroundStyle(.secondary)
                    }
                }
                if let kmVal = Double(km), kmVal > 0, let hVal = Double(hours), hVal > 0 {
                    Section("After Trip") {
                        HStack {
                            Text("Odometer")
                            Spacer()
                            Text("\(Int(vehicle.odometerKm + kmVal)) km").foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Engine")
                            Spacer()
                            Text(String(format: "%.1f h", vehicle.engineHours + hVal)).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Log Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled((Double(km) ?? 0) == 0 && (Double(hours) ?? 0) == 0)
                }
            }
        }
    }

    func save() {
        let kmVal = Double(km) ?? 0
        let hVal = Double(hours) ?? 0
        DataStore.shared.logTrip(for: vehicle, km: kmVal, hours: hVal)
        dismiss()
    }
}
