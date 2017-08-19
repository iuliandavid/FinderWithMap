//
//  MapVC.swift
//  FinderWithMap
//
//  Created by iulian david on 8/17/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import MapKit
import GeoFire
import Firebase

class MapVC: UIViewController {

    
    @IBOutlet weak var pullUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var hasCenteredOnMap = false
    
    @IBOutlet weak var pullUpView: UIView!
    
    var collectionView: UICollectionView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: Constants.collectionViewReuseIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
        
        collectionView?.reloadData()
        
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
    //Places an object selected from the collection that will popup
    @IBAction func placeObject(_ sender: UIButton) {
    
        pullUpViewHeight.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    func animateViewDown() {
        pullUpViewHeight.constant = 1
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

//MARK: - MKMapViewDelegate methods
extension MapVC: MKMapViewDelegate {
   
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

//MARK: - CLLocationManagerDelegate methods
extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            print("Not authorized")
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods
extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataService.sharedInstance.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.collectionViewReuseIdentifier, for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        
        cell.model = DataService.sharedInstance.photos[indexPath.row]
        cell.mapVC = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexPath selected: \(indexPath)")
    }
}
//MARK: - UICollectionViewDelegateFlowLayout methods
extension MapVC: UICollectionViewDelegateFlowLayout {
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGFloat = self.view.frame.width/4
        return CGSize(width: size, height: size)
    }
}



