import SwiftUI
import MapKit
import CoreLocation

// MARK: - Filter Options Model
struct FilterOptions {
    var radius: Double = 5.0                   // miles
    var priceRange: ClosedRange<Double> = 10...30 // $/hour
    var availableNow: Bool = false
    var backgroundCheckedOnly: Bool = false
    var coordinate: CLLocationCoordinate2D? = nil  // center for map/proximity
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var coordinate: CLLocationCoordinate2D?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        DispatchQueue.main.async {
            self.coordinate = loc.coordinate
        }
        manager.stopUpdatingLocation()
    }
}

// MARK: - MapView (overlay circle)
struct MapView: UIViewRepresentable {
    @Binding var center: CLLocationCoordinate2D?
    @Binding var radius: Double

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.removeOverlays(map.overlays)
        guard let center = center else { return }

        // set region
        let meters = radius * 1609.34 * 2
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: meters,
            longitudinalMeters: meters
        )
        map.setRegion(region, animated: true)

        // add circle overlay
        let circle = MKCircle(center: center, radius: radius * 1609.34)
        map.addOverlay(circle)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.strokeColor = UIColor.blue.withAlphaComponent(0.6)
                renderer.fillColor   = UIColor.blue.withAlphaComponent(0.2)
                renderer.lineWidth   = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: - ProximityFilterView
struct ProximityFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filterOptions: FilterOptions
    @State private var tempOptions: FilterOptions
    @StateObject private var locationManager = LocationManager()

    init(filterOptions: Binding<FilterOptions>) {
        self._filterOptions = filterOptions
        self._tempOptions   = State(initialValue: filterOptions.wrappedValue)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MapView at top
                MapView(
                    center: $tempOptions.coordinate,
                    radius: $tempOptions.radius
                )
                .frame(height: 200)

                Form {
                    // — Distance —
                    Section(header: Text("Distance")) {
                        Text(String(format: "Radius: %.1f miles", tempOptions.radius))
                        Slider(value: $tempOptions.radius, in: 1...15, step: 0.5)
                    }

                    // — Price —
                    Section(header: Text("Price")) {
                        Text("Max Price: $\(Int(tempOptions.priceRange.upperBound))/hr")
                        Slider(
                            value: Binding(
                                get: { tempOptions.priceRange.upperBound },
                                set: { newVal in tempOptions.priceRange = 10...newVal }
                            ),
                            in: 10...100, step: 5
                        )
                    }

                    // — Preferences —
                    Section {
                        Toggle("Available Now", isOn: $tempOptions.availableNow)
                        Toggle("Background Checked Only", isOn: $tempOptions.backgroundCheckedOnly)
                    }

                    // — Actions —
                    Section {
                        Button("Reset Filters") {
                            tempOptions = FilterOptions()
                        }
                        .foregroundColor(.red)

                        Button("Apply Filters") {
                            filterOptions = tempOptions
                            dismiss()
                        }
                        .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Proximity Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Use My Location") {
                        locationManager.requestLocation()
                    }
                }
            }
            .onReceive(locationManager.$coordinate) { coord in
                guard let coord = coord else { return }
                tempOptions.coordinate = coord
            }
        }
    }
}

// MARK: - Preview
struct ProximityFilterView_Previews: PreviewProvider {
    static var previews: some View {
        ProximityFilterView(filterOptions: .constant(
            FilterOptions(
                radius: 5,
                priceRange: 10...30,
                availableNow: false,
                backgroundCheckedOnly: false,
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            )
        ))
    }
}

