//
//  ClusteringPin.swift
//  Pillowz
//
//  Created by Samat on 04.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import Foundation
import GoogleMaps

/// Point of Interest Item which implements the GMUClusterItem protocol.
class ClusteringPin: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    
    var space:Space!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}
