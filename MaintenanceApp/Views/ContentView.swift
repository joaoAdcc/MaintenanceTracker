import SwiftUI

struct ContentView: View {
    @State private var vehicles: [Vehicle] = []
    @State private var showAddVehicle = false
    @State private var dueCount = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                if vehicles.isEmpty {
                    ContentUnavailableView(
                        "No Vehicles",
                        systemImage: "car",
                        description: Text("Add a vehicle to start tracking maintenance.")
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(vehicles) { vehicle in
                            VehicleCardView(vehicle: vehicle)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Vehicle Tracker")
            .toolbar {
                if dueCount > 0 {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                            Text("\(dueCount) due").font(.caption).foregroundStyle(.orange)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddVehicle = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddVehicle) {
                AddVehicleView()
            }
            .onAppear { refresh() }
            .onChange(of: showAddVehicle) { if !$1 { refresh() } }
        }
    }

    func refresh() {
        vehicles = DataStore.shared.vehicles
        dueCount = vehicles.reduce(0) { $0 + $1.maintenanceTasks.filter { $0.isOverdue || $0.isDueSoon }.count }
    }
}
