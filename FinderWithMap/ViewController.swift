//
//  ViewController.swift
//  FinderWithMap
//
//  Created by iulian david on 8/17/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import MapKit
import GeoFire

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var hasCenteredOnMap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationAuthStatus()
    }
    
    //MARK: - Location Manager Authorization
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
          locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    //MARK: - Actions
    @IBAction func find(_ sender: UIButton) {
    }
    
}

//MARK: - MKMapViewDelegate methods
extension ViewController: MKMapViewDelegate {
   
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let location = userLocation.location, !hasCenteredOnMap else {
            return
        }
        hasCenteredOnMap = true
        centerOnMap(location: location)
    }
    
    func centerOnMap(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //place an image insted of a red dot
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView?
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = #imageLiteral(resourceName: "ash")
        }
        
        return annotationView
        
    }
}

//MARK: - MKMapViewDelegate methods
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            print("Not authorized")
        }
    }
}



