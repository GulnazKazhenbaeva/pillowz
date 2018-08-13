//
//  Spaces.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 03.08.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import ObjectMapper

class Spaces: Mappable {
    var id: Int = 0
    var fields: FieldsModel!
    var rent_type: String = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id          <- map["id"]
        fields      <- map["fields"]
        rent_type   <- map["rent_type"]
    }

}
