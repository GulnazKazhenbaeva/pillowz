//
//  LocationManager.swift
//  Pillowz
//
//  Created by Samat on 08.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import CoreLocation

class MapLocationManager: NSObject {
    var googleMapView: GMSMapView!
    
    var shouldUpdateCamera = true
    
    var didLoadLocation = false

    init(mapView:GMSMapView) {
        super.init()
        
        googleMapView = mapView
        
        googleMapView.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let location = change?[NSKeyValueChangeKey.newKey] as? CLLocation else {
            fatalError("Could not unwrap optional content of new key")
        }
        
        if (!didLoadLocation) {
            if (shouldUpdateCamera) {
                googleMapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 14)
            }
            
            didLoadLocation = true
        }
    }
    
    deinit {
        googleMapView.removeObserver(self, forKeyPath: "myLocation")
    }
}
