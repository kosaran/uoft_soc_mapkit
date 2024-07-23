//
//  MapViewViewController.swift
//  mapkit-integration
//
//  Created by Kosaran Gumarathas on 2024-07-23.
//

import UIKit
import Foundation
import MapKit

class MapViewViewController: UIViewController, MKMapViewDelegate, MapViewModelDelegate {
    
    let mapViewModel = MapViewModel()

    
    @IBOutlet weak var mapview: MKMapView!
    
    func didUpdateCurrentUserLocation(newLocation: CLLocationCoordinate2D) {
        
    }
    
    func didAddAnnotations(annotations: [any MKAnnotation]) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func didUpdateModelState(newState: MapViewModel.LocationModelState) {
        
        guard let permissionStatus = newState.status else {
            mapview.showsUserLocation = false
            return
        }
        switch permissionStatus {
        case .notDetermined:
            print("Please go to Settings and authorize location services.")
            mapview.showsUserLocation = false
        case .restricted:
            print("Location authorized restricted likely due to parental controls.")
            mapview.showsUserLocation = false
        case .denied:
            print("You have denied permissions to this Application. Please go to Settings and authorize location services.")
            mapview.showsUserLocation = false
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            mapview.showsUserLocation = true
        default:
            break
        }
        self.mapview.showsUserLocation = true
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
