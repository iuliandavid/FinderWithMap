//
//  DroppablePin.swift
//  FinderWithMap
//
//  Created by iulian david on 8/20/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    var title: String? = "Place Photo?"
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
