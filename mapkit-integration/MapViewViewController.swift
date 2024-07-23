import UIKit
import MapKit

class AnnotationPin: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

class MapViewViewController: UIViewController, MKMapViewDelegate, MapViewModelDelegate {
    var mapViewModel = MapViewModel()

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewModel.delegate = self  // Set the delegate
        mapView.delegate = self

        mapViewModel.setupTouristAnnotations()  // Prepare and add tourist annotations

        // Center the map on the user's location initially if available
        if let userLocation = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        } else {
            // Fallback location (University of Toronto)
            let uoft = CLLocationCoordinate2D(latitude: 43.664486, longitude: -79.399689)
            let uoftPin = AnnotationPin(title: "UofT", subtitle: "The Best!", coordinate: uoft)
            mapView.addAnnotation(uoftPin)
            let initialRegion = MKCoordinateRegion(center: uoft, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(initialRegion, animated: true)
        }

    }

    func didUpdateCurrentUserLocation(newLocation: CLLocationCoordinate2D) {
        // Optional: Center the map on the user's location
        let region = MKCoordinateRegion(center: newLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    func didAddAnnotations(annotations: [MKAnnotation]) {
        mapView.addAnnotations(annotations)
    }

    func didUpdateModelState(newState: MapViewModel.LocationModelState) {
        switch newState.status {
        case .notDetermined, .restricted, .denied:
            mapView.showsUserLocation = false
            print("Access to location services is restricted or denied.")
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
        default:
            mapView.showsUserLocation = false
        }
    }
}
