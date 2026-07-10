import SwiftUI

struct AddMaintenanceView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var vehicle: Vehicle
    @State private var name = ""
    @State private var intervalKm = ""
    @State private var intervalHours = ""
    @State private var editingTask: MaintenanceTask?

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Task Name", text: $name)
                    TextField("Interval (km)", text: $intervalKm)
                        .keyboardType(.decimalPad)
                    TextField("Interval (hours)", text: $intervalHours)
                        .keyboardType(.decimalPad)
                }

                if !vehicle.maintenanceTasks.isEmpty {
                    Section("Existing Tasks") {
                        ForEach(vehicle.maintenanceTasks) { task in
                            MaintenanceTaskRow(task: task)
                                .swipeActions(edge: .trailing) {
                                    Button("Delete", role: .destructive) {
                                        DataStore.shared.deleteMaintenanceTask(task)
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button("Reset") {
                                        DataStore.shared.resetMaintenanceTask(task)
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Maintenance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(name.isEmpty || ((Double(intervalKm) ?? 0) == 0 && (Double(intervalHours) ?? 0) == 0))
                }
            }
        }
    }

    func save() {
        DataStore.shared.addMaintenanceTask(
            to: vehicle, name: name,
            intervalKm: Double(intervalKm) ?? 0,
            intervalHours: Double(intervalHours) ?? 0
        )
        name = ""
        intervalKm = ""
        intervalHours = ""
    }
}
