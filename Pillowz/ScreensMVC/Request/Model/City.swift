//
//  City.swift
//  Pillowz
//
//  Created by Samat on 09.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

class City: NSObject {
    var name : String?
    var subject : String?
    var city_id : Int?
    
    convenience init(json:JSON) {
        self.init()
        
        self.name = json["name"].stringValue
        self.subject = json["subject"].stringValue
        self.city_id = json["city_id"].intValue
    }
    
    class func parseCitiesArray(json:[JSON]) -> [City] {
        var citiesArray:[City] = []
        
        for cityJSON in json {
            let city = City(json: cityJSON)
            
            citiesArray.append(city)
        }
        
        return citiesArray
    }
    
    override var description: String {
        get {
            return String(self.city_id!)
        }
    }
}
