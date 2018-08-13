//
//  LocationManager.swift
//  Pillowz
//
//  Created by Samat on 25.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    var locationManager:CLLocationManager!

    var didLoadLocation = false

    var currentLocation:CLLocationCoordinate2D?
    
    override init() {
        super.init()
        
        DispatchQueue.main.async { [weak self] in
            self?.locationManager = CLLocationManager()
            self?.locationManager.delegate = self
            self?.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self?.locationManager.requestWhenInUseAuthorization()
            self?.locationManager.startUpdatingLocation()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                openAlertForOpeningSettings()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
        } else {
            openAlertForOpeningSettings()
            print("Location services are not enabled")
        }
    }
    
    func openAlertForOpeningSettings() {
        if (!User.isLoggedIn() && !UserLastUsedValuesForFieldAutofillingHandler.shared.didChooseRentTypeForFirstTime) {
            return
        }
        
        let alert = UIAlertController(title: "Location", message: "Pillowz нужно Ваше местоположение", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.openSettingsToAllowLocation()
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { action in
            
        }))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }

    }
    
    func openSettingsToAllowLocation() {
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) as URL? {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updated location")
        if (!didLoadLocation) {
            currentLocation = locations.first?.coordinate
            
            didLoadLocation = true
            
            locationManager?.stopUpdatingLocation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                self.didLoadLocation = false
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //openSettingsToAllowLocation()
    }
}

extension CLLocation {
    // In meteres
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}

