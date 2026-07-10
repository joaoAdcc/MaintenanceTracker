import SwiftUI

struct AddVehicleView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var model = ""
    @State private var plate = ""
    @State private var odometerKm = ""
    @State private var engineHours = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Info") {
                    TextField("Name", text: $name)
                    TextField("Model / Year", text: $model)
                    TextField("License Plate", text: $plate)
                }
                Section("Initial Readings") {
                    TextField("Odometer (km)", text: $odometerKm)
                        .keyboardType(.decimalPad)
                    TextField("Engine Hours", text: $engineHours)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.disabled(name.isEmpty) }
            }
        }
    }

    func save() {
        DataStore.shared.addVehicle(
            name: name, model: model, plate: plate,
            odometerKm: Double(odometerKm) ?? 0,
            engineHours: Double(engineHours) ?? 0
        )
        dismiss()
    }
}

struct EditVehicleView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var vehicle: Vehicle
    @State private var name: String
    @State private var model: String
    @State private var plate: String

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        _name = State(initialValue: vehicle.name)
        _model = State(initialValue: vehicle.model)
        _plate = State(initialValue: vehicle.plate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Info") {
                    TextField("Name", text: $name)
                    TextField("Model / Year", text: $model)
                    TextField("License Plate", text: $plate)
                }
                Section {
                    Button("Delete Vehicle", role: .destructive) {
                        DataStore.shared.deleteVehicle(vehicle)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vehicle.name = name
                        vehicle.model = model
                        vehicle.plate = plate
                        dismiss()
                    }.disabled(name.isEmpty)
                }
            }
        }
    }
}
