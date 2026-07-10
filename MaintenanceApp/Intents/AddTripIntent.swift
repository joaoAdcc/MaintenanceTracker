import AppIntents
import SwiftData

struct AddTripIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Trip"
    static let description = IntentDescription("Log a trip with distance and engine hours to a vehicle.")

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$distance) km and \(\.$hours) hours to \(\.$vehicle)")
    }

    @Parameter(title: "Vehicle")
    var vehicle: VehicleEntity?

    @Parameter(title: "Distance (km)", controlStyle: .field, inclusiveRangeFor: 0...1_000_000)
    var distance: Double?

    @Parameter(title: "Engine Hours", controlStyle: .field, inclusiveRangeFor: 0...1_000_000)
    var hours: Double?

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<IntentTrip> {
        guard let vehicleEntity = vehicle else {
            throw $vehicle.needsValueError()
        }
        let dist = distance ?? 0
        let hrs = hours ?? 0
        guard dist > 0 || hrs > 0 else {
            throw $distance.needsValueError()
        }

        let vehicles = DataStore.shared.vehicles
        guard let vehicleModel = vehicles.first(where: { $0.id == vehicleEntity.id }) else {
            throw IntentError.message("Vehicle not found.")
        }

        DataStore.shared.logTrip(for: vehicleModel, km: dist, hours: hrs)

        let result = IntentTrip(km: dist, hours: hrs, vehicleName: vehicleModel.name)
        return .result(
            value: result,
            dialog: "Logged \(dist) km and \(hrs) hours to \(vehicleModel.name). Total: \(Int(vehicleModel.odometerKm)) km, \(String(format: "%.1f", vehicleModel.engineHours)) hours."
        )
    }
}

struct IntentTrip: AppEntity {
    let id: UUID = UUID()
    let km: Double
    let hours: Double
    let vehicleName: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Trip" }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(km) km, \(hours) h on \(vehicleName)")
    }

    static var defaultQuery = IntentTripQuery()
}

struct IntentTripQuery: EntityQuery {
    func entities(for ids: [UUID]) async -> [IntentTrip]? { nil }
    func suggestedEntities() async -> [IntentTrip] { [] }
}

enum IntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case message(String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .message(let msg): return "\(msg)"
        }
    }
}
