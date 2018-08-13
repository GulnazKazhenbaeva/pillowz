//
//  UserLastUsedValuesForFieldAutofillingHandler.swift
//  Pillowz
//
//  Created by Samat on 21.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class UserLastUsedValuesForFieldAutofillingHandler: NSObject {
    static let shared = UserLastUsedValuesForFieldAutofillingHandler()
    
    var rentType:RENT_TYPES {
        set {
            saveRentType(newValue)
        }
        get {
            return getRentType()
        }
    }
    let rentTypeKey = "rentType"
    
    func saveRentType(_ rentType:RENT_TYPES) {
        UserDefaults.standard.set(rentType.rawValue, forKey: rentTypeKey)
    }
    
    func getRentType() -> RENT_TYPES {
        if let rentType = UserDefaults.standard.value(forKey: rentTypeKey) as? Int {
            return RENT_TYPES(rawValue: rentType)!
        } else {
            return RENT_TYPES.DAILY
        }
    }
        
    var didChooseRentTypeForFirstTime:Bool {
        set {
            saveDidChooseRentTypeForFirstTime(newValue)
        }
        get {
            return getDidChooseRentTypeForFirstTime()
        }
    }
    let didChooseRentTypeForFirstTimeKey = "didChooseRentTypeForFirstTime"

    func saveDidChooseRentTypeForFirstTime(_ value:Bool) {
        UserDefaults.standard.set(value, forKey: didChooseRentTypeForFirstTimeKey)
    }
    func getDidChooseRentTypeForFirstTime() -> Bool {
        if let didChooseRentTypeForFirstTime = UserDefaults.standard.value(forKey: didChooseRentTypeForFirstTimeKey) as? Bool {
            return didChooseRentTypeForFirstTime
        } else {
            return false
        }
    }
    
    var address:String {
        set {
            saveAddress(newValue)
            
            let filterDict = ["delegate": Filter.shared, "address":newValue] as [String : Any]
            let openRequestFirstStepDict = ["delegate": OpenRequestFirstStepViewController.shared, "address":newValue] as [String : Any]

//            Filter.shared.addressField?.customCellObject = filterDict as AnyObject
            OpenRequestFirstStepViewController.shared.addressField?.customCellObject = openRequestFirstStepDict as AnyObject
        }
        get {
            return getAddress()
        }
    }
    let addressKey = "address"
    
    func saveAddress(_ address:String) {
        UserDefaults.standard.set(address, forKey: addressKey)
    }
    
    func getAddress() -> String {
        if let address = UserDefaults.standard.value(forKey: addressKey) as? String {
            return address
        } else {
            return ""
        }
    }
    
    
    
    var lat:Double {
        set {
            saveLat(newValue)
        }
        get {
            return getLat()
        }
    }
    let latKey = "lat"
    
    func saveLat(_ lat:Double) {
        UserDefaults.standard.set(lat, forKey: latKey)
    }
    
    func getLat() -> Double {
        if let lat = UserDefaults.standard.value(forKey: latKey) as? Double {
            return lat
        } else {
            return 0
        }
    }

    
    
    
    
    
    var lon:Double {
        set {
            saveLon(newValue)
        }
        get {
            return getLon()
        }
    }
    let lonKey = "lon"
    
    func saveLon(_ lon:Double) {
        UserDefaults.standard.set(lon, forKey: lonKey)
    }
    
    func getLon() -> Double {
        if let lon = UserDefaults.standard.value(forKey: lonKey) as? Double {
            return lon
        } else {
            return 0
        }
    }

    
    
    
    
    
    var chosenSpaceCategory:String {
        set {
            saveChosenSpaceCategory(newValue)
        }
        get {
            return getChosenSpaceCategory()
        }
    }
    let chosenSpaceCategoryKey = "chosenSpaceCategory"
    
    func saveChosenSpaceCategory(_ chosenSpaceCategory:String) {
        UserDefaults.standard.set(chosenSpaceCategory, forKey: chosenSpaceCategoryKey)
    }
    
    func getChosenSpaceCategory() -> String {
        if let chosenSpaceCategory = UserDefaults.standard.value(forKey: chosenSpaceCategoryKey) as? String {
            return chosenSpaceCategory
        } else {
            return ""
        }
    }
    
    
    
    
    var price:Int {
        set {
            savePrice(newValue)
        }
        get {
            return getPrice()
        }
    }
    let priceKey = "price"
    
    func savePrice(_ price:Int) {
        UserDefaults.standard.set(price, forKey: priceKey)
    }
    
    func getPrice() -> Int {
        if let price = UserDefaults.standard.value(forKey: priceKey) as? Int {
            return price
        } else {
            return 0
        }
    }
    
    var startTime:Int?
    var endTime:Int?
}
