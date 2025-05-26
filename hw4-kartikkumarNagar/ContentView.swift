//
//  ContentView.swift
//  hw4-kartikkumarNagar
//
//  Created by CDMStudent on 5/22/25.
//

import SwiftUI
import CoreLocation

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isLocationEnabled = false
    @Published var isUpdatingLocation = false
    @Published var isUpdatingHeading = false
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var horizontalAccuracy: Double?
    @Published var altitude: Double?
    @Published var floorLevel: Int?
    @Published var verticalAccuracy: Double?
    @Published var heading: CLHeading?
    @Published var speed: Double?
    @Published var course: Double?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestPermission() {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            isLocationEnabled = status == .authorizedAlways || status == .authorizedWhenInUse
        }
    }

    func startLocation() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        manager.startUpdatingLocation()
        isUpdatingLocation = true
    }

    func stopLocation() {
        manager.stopUpdatingLocation()
        stopHeading()
        isUpdatingLocation = false
    }

    func startHeading() {
        guard isUpdatingLocation, CLLocationManager.headingAvailable() else { return }
        manager.startUpdatingHeading()
        isUpdatingHeading = true
    }

    func stopHeading() {
        manager.stopUpdatingHeading()
        isUpdatingHeading = false
    }

    func updateAccuracy(to accuracy: CLLocationAccuracy) {
        let wasUpdating = isUpdatingLocation
        if wasUpdating { manager.stopUpdatingLocation() }
        manager.desiredAccuracy = accuracy
        if wasUpdating { manager.startUpdatingLocation() }

    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        isLocationEnabled = manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse
        if !isLocationEnabled { stopLocation() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
        horizontalAccuracy = loc.horizontalAccuracy
        altitude = loc.altitude
        floorLevel = loc.floor?.level
        verticalAccuracy = loc.verticalAccuracy
        speed = loc.speed
        course = loc.course
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
}

private enum Lab: String, CaseIterable, Identifiable {
    case lab1 = "Lab A"
    case lab2 = "Lab B"
    case lab3 = "Lab C"
    var id: Self { self }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(Lab.allCases) { lab in
                NavigationLink(lab.rawValue, value: lab)
            }
            .navigationTitle("Lab Screens")
            .navigationDestination(for: Lab.self) { lab in
                switch lab {
                case .lab1: LabA()
                case .lab2: LabB()
                case .lab3: LabC()
                }
            }
        }
    }
}

struct LabA: View {
    @StateObject private var locationService = LocationService()
    @State private var selectedAccuracy = 0
    private let accuracyLevels: [(label: String, value: CLLocationAccuracy)] = [
        ("Best", kCLLocationAccuracyBest),
        ("10m", kCLLocationAccuracyNearestTenMeters),
        ("100m", kCLLocationAccuracyHundredMeters)
    ]
    var body: some View {
        VStack(spacing: 16) {
            Text("Location Services: \(locationService.isLocationEnabled ? "On" : "Off")")
            Text("Location Updates: \(locationService.isUpdatingLocation ? "On" : "Off")")
            if let lat = locationService.latitude, let lon = locationService.longitude {
                Text("Latitude: \(String(format: "%.4f", lat))")
                Text("Longitude: \(String(format: "%.4f", lon))")
            } else {
                Text("Location unavailable")
            }
            if let acc = locationService.horizontalAccuracy {
                Text("Horizontal Accuracy: \(String(format: "%.4f", acc)) m")
            }
            Picker("Precision", selection: $selectedAccuracy) {
                ForEach(accuracyLevels.indices, id: \.self) { i in
                    Text(accuracyLevels[i].label)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedAccuracy) { _, newValue in
                locationService.updateAccuracy(to: accuracyLevels[newValue].value)
            }
            Toggle("Location Updates", isOn: $locationService.isUpdatingLocation)
                .onChange(of: locationService.isUpdatingLocation) { _, on in
                    on ? locationService.startLocation() : locationService.stopLocation()
                }
        }
        .padding()
        .onAppear { locationService.requestPermission() }
    }
}

struct LabB: View {
    @StateObject private var locationService = LocationService()
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Latitude: \(locationService.latitude.map { String(format: "%.4f", $0) } ?? "--")")
            Text("Longitude: \(locationService.longitude.map { String(format: "%.4f", $0) } ?? "--")")
            Text("Horizontal Accuracy: \(locationService.horizontalAccuracy.map { String(format: "%.4f", $0) } ?? "--") m")
            Text("Altitude: \(locationService.altitude.map { String(format: "%.4f", $0) } ?? "--") m")
            Text("Floor: \(locationService.floorLevel.map { String($0) } ?? "--")")
            Text("Vertical Accuracy: \(locationService.verticalAccuracy.map { String(format: "%.4f",  $0) } ?? "--") m")
            Text("Heading: \(locationService.heading.map { String(format: "%.4f", $0.trueHeading) } ?? "--")°")
            Text("Speed: \(locationService.speed.map { String(format: "%.4f", $0) } ?? "--") m/s")
            Text("Course: \(locationService.course.map { String(format: "%.4f", $0) } ?? "--")°")
            Toggle("Location Updates", isOn: $locationService.isUpdatingLocation)
                .onChange(of: locationService.isUpdatingLocation) { _, on in
                    on ? locationService.startLocation() : locationService.stopLocation()
                }
            Toggle("Heading Updates", isOn: $locationService.isUpdatingHeading)
                .disabled(!locationService.isUpdatingLocation)
                .onChange(of: locationService.isUpdatingHeading) { _, on in
                    on ? locationService.startHeading() : locationService.stopHeading()
                }
            Spacer()
        }
        .padding()
        .onAppear { locationService.requestPermission() }
    }
}

struct LabC: View {
    var body: some View {
        Text("Lab 3")
    }
}

#Preview {
    ContentView()
}
