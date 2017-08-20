//
//  PhotoAnnotation.swift
//  FinderWithMap
//
//  Created by iulian david on 8/20/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import MapKit

class PhotoAnnotation: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var photoId: Int
    var photoName: String
    var identifier: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, identifier: String, photoId: Int) {
        self.coordinate = coordinate
        self.identifier = identifier
        self.photoId = photoId
        self.photoName = DataService.sharedInstance.photos[photoId - 1].name.capitalized
        self.title = self.photoName
        super.init()
    }
}
