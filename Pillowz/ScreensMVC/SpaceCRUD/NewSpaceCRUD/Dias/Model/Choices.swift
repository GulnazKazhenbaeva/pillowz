//
//  Choices.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 04.08.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import ObjectMapper

class Choices: Mappable {
    var categories: [String] = []
    var icon: String = ""
    var id: String = ""
    var rent_type: [String] = []
    var text: String = ""
    var extra: Extra?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        categories  <- map["categories"]
        icon        <- map["icon"]
        id          <- map["id"]
        rent_type   <- map["rent_type"]
        text        <- map["text"]
        extra       <- map["extra"]
    }
}

class Extra: Mappable {
    var name: String = ""
    var request: String = ""
    var studio: Bool = false
    var type: String = ""
    var value: Bool = false
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name    <- map["name"]
        request <- map["request"]
        studio  <- map["studio"]
        type    <- map["type"]
        value   <- map["value"]
    }
}
