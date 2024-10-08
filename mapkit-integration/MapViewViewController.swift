//
//  MapViewViewController.swift
//  mapkit-integration
//
//  Created by Kosaran Gumarathas on 2024-07-23.
//

import UIKit
import Foundation
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
class MapViewViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapview: MKMapView!
    
    func didUpdateCurrentUserLocation(newLocation: CLLocationCoordinate2D) {
        
    }
    
    func didAddAnnotations(annotations: [any MKAnnotation]) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let highPark = CLLocationCoordinate2D(latitude: 43.6465, longitude: -79.4637)
        
        let highParkPin = AnnotationPin(title: "High Park", subtitle: "Cherry Blossom", coordinate: highPark)
        mapview.addAnnotation(highParkPin)

        let rom = CLLocationCoordinate2D(latitude: 43.6677, longitude: -79.3948)
        let romPin = AnnotationPin(title: "ROM", subtitle: "Museum", coordinate: rom)
        mapview.addAnnotation(romPin)

        let region = MKCoordinateRegion(center: rom, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        mapview.setRegion(region, animated: true)
        

        mapview.delegate = self
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
