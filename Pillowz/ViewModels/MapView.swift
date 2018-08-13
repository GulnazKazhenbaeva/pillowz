//
//  MapView.swift
//  Pillowz
//
//  Created by Samat on 08.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import GoogleMaps

class MapView: UIView {
    var googleMapView: GMSMapView!
    var centerPosition = CLLocationCoordinate2D()
    var locationManager:MapLocationManager!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let camera = GMSCameraPosition.camera(withLatitude: centerPosition.latitude, longitude: centerPosition.longitude, zoom: 14)
        googleMapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        googleMapView.isMyLocationEnabled = true
        googleMapView.settings.compassButton = true;
        googleMapView.settings.myLocationButton = true;
        googleMapView.isMyLocationEnabled = true;

        self.addSubview(googleMapView)
        googleMapView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        locationManager = MapLocationManager(mapView: googleMapView)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
