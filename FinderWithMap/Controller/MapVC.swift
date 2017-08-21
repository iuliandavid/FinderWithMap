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

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var pullUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var hasCenteredOnMap = false
    
    @IBOutlet weak var pullUpView: UIView!
    
    var collectionView: UICollectionView?
    
    //firebase and geofire objects
    var geofire: GeoFire!
    var geofireRef : DatabaseReference!
    
    
    var touchedLocation: CLLocation?
    
    let regionRadius: Double = 1000
    
    // send button
    let pullDownButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "Auto-Complete Bar Closed.png"),for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(animateViewDown), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geofireRef = Database.database().reference()
        geofire = GeoFire(firebaseRef: geofireRef)
        
        addDoubleTap()
    }
    
    private func setupPullUpView() {
        let myFrame = CGRect(x: 0, y: 15, width: self.view.frame.width, height: self.view.frame.height - 15)
        collectionView = UICollectionView(frame: myFrame, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: Constants.collectionViewReuseIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        
        pullUpView.addSubview(pullDownButton)
        pullUpView.addSubview(collectionView!)
        
        pullDownButton.topAnchor.constraint(equalTo: pullUpView.topAnchor).isActive = true
        pullDownButton.leftAnchor.constraint(equalTo: pullUpView.leftAnchor).isActive = true
        pullDownButton.rightAnchor.constraint(equalTo: pullUpView.rightAnchor).isActive = true
        pullDownButton.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        collectionView!.topAnchor.constraint(equalTo: pullDownButton.bottomAnchor).isActive = true
        collectionView!.leftAnchor.constraint(equalTo: pullUpView.leftAnchor).isActive = true
        collectionView!.rightAnchor.constraint(equalTo: pullUpView.rightAnchor).isActive = true
        collectionView!.heightAnchor.constraint(equalTo: pullUpView.heightAnchor).isActive = true
        
        
        collectionView?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationAuthStatus()
        setupPullUpView()
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
    
    func photoSelected(with photoId: Int) {
        animateViewDown()

        let location: CLLocation
        
        //if touchedLocation is set, use it
        if touchedLocation != nil {
            location = touchedLocation!
        } else {
            //grab the center of the current map view
            location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            
        }
        
        createSighting(for: location, with: photoId)
        //reset it
        touchedLocation = nil
        removePin()
    }
    
    
    
    @objc func animateViewDown() {
        pullUpViewHeight.constant = 1
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addDoubleTap() {
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        longTap.minimumPressDuration = 2
        mapView.addGestureRecognizer(longTap)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        //Force to stop if the gesture is not in the began state
        guard sender.state != UIGestureRecognizerState.began else { return }
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        touchedLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
        
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: Constants.pinAnnotation)
        mapView.addAnnotation(annotation)
        
        //TODO : See if it's really needed
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: Geofire access methods
    //saves a photo location to geofire
    func createSighting(for location: CLLocation, with photoId: Int) {
        geofire.setLocation(location, forKey: "\(photoId)")
    }
    
    //queries geofire to find if a photo is stored at a certain location
    func showSightingsOnMap(location: CLLocation) {
        let circleQuery = geofire.query(at: location, withRadius: 2.5)
        circleQuery?.observe(.keyEntered, with: { (key, location) in
            guard let key = key, let location = location else {
                return
            }
            
            let anno = PhotoAnnotation(coordinate: location.coordinate, identifier: Constants.photoAnnotation, photoId: Int(key)!)
            self.mapView.addAnnotation(anno)
        })
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            if annotation.isKind(of: DroppablePin.self) {
                mapView.removeAnnotation(annotation)
            }
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
    //it will be called after each ``self.mapView.addAnnotation(anno)``
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView?
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = #imageLiteral(resourceName: "ash")
        } else if let deqAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.photoAnnotation) {
            annotationView = deqAnnotation
            annotationView?.annotation = annotation
        } else if let _ =  annotation as? PhotoAnnotation {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.photoAnnotation)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
            
        } else if let annotation =  annotation as? DroppablePin {
            let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.pinAnnotation)
            pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinAnnotation.canShowCallout = true
            
            pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
            pinAnnotation.animatesDrop = true
            
            //add button with map refference
            let mapButton = UIButton()
            mapButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            mapButton.setImage(#imageLiteral(resourceName: "pokeball"), for: .normal)
            
            mapButton.addTarget(self, action: #selector(placeObject(_:)), for: .touchUpInside)
            pinAnnotation.rightCalloutAccessoryView = mapButton
            
            annotationView = pinAnnotation
        }
        
        if  let annotationView = annotationView, let anno = annotation as? PhotoAnnotation {
            annotationView.canShowCallout = true
            annotationView.image =  UIImage(named: "\(anno.photoId)")
            
            //add button with map refference
            let mapButton = UIButton()
            mapButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            mapButton.setImage(#imageLiteral(resourceName: "location-map-flat"), for: .normal)
            annotationView.rightCalloutAccessoryView = mapButton
            
        }
        
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: location)
    }
    
    //executed when the annotation map button is pressed
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let anno = view.annotation as? PhotoAnnotation {
            //getting the destination(start and end) for Apple MapKit
            let placemark = MKPlacemark(coordinate: anno.coordinate)
            
            let destination = MKMapItem(placemark: placemark)
            
            destination.name = "Photo Sighting"
            
            //defining region Span, so the map will show correctly
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            //define options for layout of the maps
            let options = [
                MKLaunchOptionsMapCenterKey : NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey : NSValue(mkCoordinateSpan: regionSpan.span),
                MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                ] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
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



