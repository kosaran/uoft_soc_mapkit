//
//  MapViewModel.swift
//  mapkit-integration
//
//  Created by Kosaran Gumarathas on 2024-07-23.
//

import Foundation
import MapKit


let attractions = [
    ("High Park", CLLocationCoordinate2D(latitude: 43.6465, longitude: -79.4637)),
    ("Royal Ontario Museum", CLLocationCoordinate2D(latitude: 43.6677, longitude: -79.3948)),
    ("CN Tower", CLLocationCoordinate2D(latitude: 43.6426, longitude: -79.3871)),
    ("Art Gallery of Ontario", CLLocationCoordinate2D(latitude: 43.6536, longitude: -79.3925)),
    ("User Provided Location", CLLocationCoordinate2D(latitude: 43.67837848534059, longitude: -79.40946536037828))
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
    
    private func setupTouristAnnotations() {
        var annotations: [MKPointAnnotation] = []
        for attraction in attractions {
            let annotation = MKPointAnnotation()
            annotation.title = attraction.0
            annotation.coordinate = attraction.1
            annotations.append(annotation)
        }
        delegate?.didAddAnnotations(annotations: annotations)
    }

    private func setupLocationManager() {
        guard CLLocationManager.locationServicesEnabled() else {
            modelState = .locationServicesDisabled
            return
        }
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined, .restricted, .denied:
            modelState = .locationServicesDisabled
        case .authorizedAlways, .authorizedWhenInUse:
            modelState = .locationServicesEnabled(status)
            locationManager?.startUpdatingLocation()
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
