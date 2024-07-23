//
//  MapViewModel.swift
//  mapkit-integration
//
//  Created by Cynthia Zhou on 2024-07-23.
//

import Foundation
import MapKit

let attractions = [
    ("High Park", "Waterfront park with  cherry blossoms", CLLocationCoordinate2D(latitude: 43.6465, longitude: -79.4637)),
    ("Royal Ontario Museum", "Canada's largest and most comprehensive museum", CLLocationCoordinate2D(latitude: 43.6677, longitude: -79.3948)),
    ("CN Tower", "World's tallest freestanding structure until 2007", CLLocationCoordinate2D(latitude: 43.6426, longitude: -79.3871)),
    ("Art Gallery of Ontario","Free on the first Wednesday night of each month", CLLocationCoordinate2D(latitude: 43.6536, longitude: -79.3925))
]

// Delegate protocol for updating view controller
protocol MapViewModelDelegate: AnyObject {
    func didUpdateModelState(newState: MapViewModel.LocationModelState)
    func didUpdateCurrentUserLocation(newLocation: CLLocationCoordinate2D)
    func didAddAnnotations(annotations: [MKAnnotation])
}

// ViewModel managing the map and location services
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    enum LocationModelState {
        case notInitialized
        case locationServicesDisabled
        case locationServicesEnabled(CLAuthorizationStatus)

        var status: CLAuthorizationStatus? {
            switch self {
            case .notInitialized, .locationServicesDisabled:
                return nil
            case .locationServicesEnabled(let s):
                return s
            }
        }
    }

    weak var delegate: MapViewModelDelegate?

    @Published var modelState = LocationModelState.notInitialized {
        didSet {
            delegate?.didUpdateModelState(newState: modelState)
        }
    }
    @Published var currentUserLocation: CLLocationCoordinate2D? {
        didSet {
            if let location = currentUserLocation {
                delegate?.didUpdateCurrentUserLocation(newLocation: location)
            }
        }
    }

    var locationManager: CLLocationManager?

    override init() {
        super.init()
        setupLocationManager()
        setupTouristAnnotations()
    }
    
    func setupTouristAnnotations() {
        var annotations: [AnnotationPin] = []
        for attraction in attractions {
            let annotation = AnnotationPin(title: attraction.0, subtitle: attraction.1, coordinate: attraction.2)
            annotations.append(annotation)
        }
        print("Annotations ready to be added: \(annotations.count)")
        delegate?.didAddAnnotations(annotations: annotations)
    }

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            modelState = .locationServicesDisabled
        case .authorizedAlways, .authorizedWhenInUse:
            if CLLocationManager.locationServicesEnabled() {
                modelState = .locationServicesEnabled(manager.authorizationStatus)
                manager.startUpdatingLocation()
            } else {
                modelState = .locationServicesDisabled
            }
        @unknown default:
            modelState = .locationServicesDisabled
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentUserLocation = location.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
}
