//
//  CurrentNewOpenRequestValues.swift
//  Pillowz
//
//  Created by Samat on 21.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class CurrentNewOpenRequestValues: NSObject {
    static let shared = CurrentNewOpenRequestValues()
    
    var startTime:Int?
    var endTime:Int?
    var rentType:RENT_TYPES = UserLastUsedValuesForFieldAutofillingHandler.shared.rentType
    var lat:Double?
    var lon:Double?
    var placeID:String?
    var price:Int = 0
    var bargain:Bool!
    let rules = Rule()
    var chosenCategory:String?
    var chosenCategoryFields:[Field]!
    var comforts:[ComfortItem] = []
    var urgent:Bool = false
    var owner:Bool = false
    var guests_count:[String:Int] = ["adult_guest":1, "child_guest":0, "baby_guest":0]
    
    
}
