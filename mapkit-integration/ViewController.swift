import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.distanceFilter = 10 // Set distance filter to 10 meters
        manager.desiredAccuracy = kCLLocationAccuracyBest // Set desired accuracy to the best possible
        return manager
    }()

    // Array of attractions with names, descriptions, and coordinates
    let attractions = [
        ("High Park", "Waterfront park with cherry blossoms", CLLocationCoordinate2D(latitude: 43.6465, longitude: -79.4637)),
        ("Royal Ontario Museum", "Canada's largest and most comprehensive museum", CLLocationCoordinate2D(latitude: 43.6677, longitude: -79.3948)),
        ("CN Tower", "World's tallest freestanding structure until 2007", CLLocationCoordinate2D(latitude: 43.6426, longitude: -79.3871)),
        ("Art Gallery of Ontario", "Free on the first Wednesday night of each month", CLLocationCoordinate2D(latitude: 43.6536, longitude: -79.3925))
    ]

    let defaultLocation = CLLocationCoordinate2D(latitude: 43.6635, longitude: -79.3961) // UofT
    var hasCenteredOnUserLocation = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup location manager and map view delegates
        locationManager.delegate = self
        mapView.delegate = self

        locationManager.requestWhenInUseAuthorization() // Request location authorization

        // Add annotations for attractions
        for attraction in attractions {
            addAnnotation(at: attraction.2, with: attraction.0, subtitle: attraction.1)
        }

        // Set the map to the default location initially
        let region = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)

        locationManager.startUpdatingLocation() // Start updating location
    }

    // Called when the authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation() // Start updating location if authorized
        case .denied, .restricted:
            // Handle the case when the user denies location access
            let region = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        default:
            break
        }
    }

    // Called when new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return } // Get the last location
        updateLocationOnMap(to: location, with: "Current Location") // Update map with current location

        // Center the map on the user's location initially if it hasn't been centered yet
        if !hasCenteredOnUserLocation {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            hasCenteredOnUserLocation = true // Set the flag to true after centering the map
        }
    }

    // Update the map with a given location and title
    func updateLocationOnMap(to location: CLLocation, with title: String?) {
        // Remove any existing current location annotation
        let currentAnnotations = mapView.annotations.filter { $0.title == "Current Location" }
        mapView.removeAnnotations(currentAnnotations)
        
        // Add a new annotation for the current location
        let point = MKPointAnnotation()
        point.title = title
        point.coordinate = location.coordinate
        mapView.addAnnotation(point) // Add annotation to map
    }

    // Add an annotation to the map at a specified coordinate with a title and subtitle
    func addAnnotation(at coordinate: CLLocationCoordinate2D, with title: String, subtitle: String) {
        let point = MKPointAnnotation()
        point.title = title
        point.subtitle = subtitle
        point.coordinate = coordinate
        mapView.addAnnotation(point) // Add annotation to map
    }
}
