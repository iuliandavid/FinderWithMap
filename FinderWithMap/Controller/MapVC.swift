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
        print("\(photoId)")
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
    }
    
    
    
    @objc func animateViewDown() {
        pullUpViewHeight.constant = 1
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        touchedLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
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



