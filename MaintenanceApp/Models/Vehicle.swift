import Foundation
import SwiftData
import AppIntents

@Model
final class Vehicle {
    @Attribute(.unique) var id: UUID
    var name: String
    var model: String
    var plate: String
    var odometerKm: Double
    var engineHours: Double
    @Relationship(deleteRule: .cascade) var trips: [Trip]
    @Relationship(deleteRule: .cascade) var maintenanceTasks: [MaintenanceTask]

    init(name: String, model: String = "", plate: String = "",
         odometerKm: Double = 0, engineHours: Double = 0) {
        self.id = UUID()
        self.name = name
        self.model = model
        self.plate = plate
        self.odometerKm = odometerKm
        self.engineHours = engineHours
        self.trips = []
        self.maintenanceTasks = []
    }
}

@Model
final class Trip {
    var id: UUID
    var km: Double
    var hours: Double
    var date: Date
    var vehicle: Vehicle?

    init(km: Double, hours: Double, date: Date = Date()) {
        self.id = UUID()
        self.km = km
        self.hours = hours
        self.date = date
    }
}

@Model
final class MaintenanceTask {
    var id: UUID
    var name: String
    var intervalKm: Double
    var intervalHours: Double
    var lastKm: Double
    var lastHours: Double
    var vehicle: Vehicle?

    init(name: String, intervalKm: Double = 0, intervalHours: Double = 0,
         lastKm: Double = 0, lastHours: Double = 0) {
        self.id = UUID()
        self.name = name
        self.intervalKm = intervalKm
        self.intervalHours = intervalHours
        self.lastKm = lastKm
        self.lastHours = lastHours
    }

    var progressKm: Double {
        guard let v = vehicle, intervalKm > 0 else { return 0 }
        return min((v.odometerKm - lastKm) / intervalKm, 1)
    }

    var progressHours: Double {
        guard let v = vehicle, intervalHours > 0 else { return 0 }
        return min((v.engineHours - lastHours) / intervalHours, 1)
    }

    var overallProgress: Double {
        max(progressKm, progressHours)
    }

    var isOverdue: Bool { overallProgress >= 1 }
    var isDueSoon: Bool { overallProgress >= 0.9 && !isOverdue }
}

// MARK: - App Intents Entity

struct VehicleEntity: Identifiable, AppEntity {
    let id: UUID
    let name: String
    let model: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Vehicle" }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)\(model.isEmpty ? "" : " (\(model))")")
    }

    static var defaultQuery = VehicleQuery()
}

struct VehicleQuery: EntityStringQuery {
    func entities(matching string: String) async -> [VehicleEntity] {
        let vehicles = await DataStore.shared.vehicles
        return vehicles
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map { VehicleEntity(id: $0.id, name: $0.name, model: $0.model) }
    }

    func entities(for ids: [VehicleEntity.ID]) async -> [VehicleEntity]? {
        let vehicles = await DataStore.shared.vehicles
        return vehicles
            .filter { ids.contains($0.id) }
            .map { VehicleEntity(id: $0.id, name: $0.name, model: $0.model) }
    }

    func suggestedEntities() async -> [VehicleEntity] {
        let vehicles = await DataStore.shared.vehicles
        return vehicles.map { VehicleEntity(id: $0.id, name: $0.name, model: $0.model) }
    }
}
