//
//  Country.swift
//  Pillowz
//
//  Created by Samat on 27.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

@objcMembers class Country: NSObject {
    var iso:String?
    var name:String?
    var code:String?
    
    convenience init(json:JSON) {
        self.init()

        iso = json["iso"].string
        name = json["name"].string
        code = json["code"].string
    }
    
    class func parseCountriesArray(json:[JSON]?) -> [Country] {
        var countriesArray:[Country] = []
        
        if json == nil {
            return []
        }
        
        for countryJSON in json! {
            let country = Country(json: countryJSON)
            
            countriesArray.append(country)
        }
        
        return countriesArray
    }

}
