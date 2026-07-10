import Foundation
import SwiftData

@MainActor
final class DataStore {
    static let shared = DataStore()

    var container: ModelContainer?
    private var context: ModelContext?

    private init() {}

    func setup(in memoryOnly: Bool = false) {
        let schema = Schema([Vehicle.self, Trip.self, MaintenanceTask.self])
        let config = memoryOnly
            ? ModelConfiguration(isStoredInMemoryOnly: true)
            : ModelConfiguration(isStoredInMemoryOnly: false)
        container = try? ModelContainer(for: schema, configurations: [config])
        if let container {
            context = ModelContext(container)
        }
    }

    var vehicles: [Vehicle] {
        guard let context else { return [] }
        let descriptor = FetchDescriptor<Vehicle>(sortBy: [SortDescriptor(\.name)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func addVehicle(name: String, model: String, plate: String,
                    odometerKm: Double, engineHours: Double) {
        guard let context else { return }
        let v = Vehicle(name: name, model: model, plate: plate,
                        odometerKm: odometerKm, engineHours: engineHours)
        context.insert(v)
        try? context.save()
    }

    func deleteVehicle(_ vehicle: Vehicle) {
        guard let context else { return }
        context.delete(vehicle)
        try? context.save()
    }

    func logTrip(for vehicle: Vehicle, km: Double, hours: Double) {
        guard let context else { return }
        let trip = Trip(km: km, hours: hours)
        trip.vehicle = vehicle
        vehicle.trips.append(trip)
        vehicle.odometerKm += km
        vehicle.engineHours += hours
        try? context.save()
    }

    func addMaintenanceTask(to vehicle: Vehicle, name: String,
                            intervalKm: Double, intervalHours: Double) {
        guard let context else { return }
        let task = MaintenanceTask(name: name, intervalKm: intervalKm,
                                   intervalHours: intervalHours,
                                   lastKm: vehicle.odometerKm,
                                   lastHours: vehicle.engineHours)
        task.vehicle = vehicle
        vehicle.maintenanceTasks.append(task)
        try? context.save()
    }

    func resetMaintenanceTask(_ task: MaintenanceTask) {
        guard let vehicle = task.vehicle else { return }
        task.lastKm = vehicle.odometerKm
        task.lastHours = vehicle.engineHours
        try? context?.save()
    }

    func deleteMaintenanceTask(_ task: MaintenanceTask) {
        guard let context else { return }
        context.delete(task)
        try? context.save()
    }
}
