//
//  SpaceIcon.swift
//  Pillowz
//
//  Created by Samat on 11.02.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

class SpaceIcon: NSObject {
    var logo_64x64:String!
    var icon_name_lang:[String:String]!
    var icon_name:String {
        return MultiLanguageResponseHandler.getStringFromDict(dict: icon_name_lang)
    }

    convenience init(json:JSON) {
        self.init()
        
        self.logo_64x64 = json["logo_64x64"].stringValue
        self.icon_name_lang = json["icon_name"].dictionaryObject as! [String:String]
    }
    
    class func parseSpaceIconsArray(json:[JSON]?) -> [SpaceIcon] {
        if (json == nil) {
            return []
        }
        
        var spaceIconsArray:[SpaceIcon] = []
        
        for spaceIconJSON in json! {
            let spaceIcon = SpaceIcon(json: spaceIconJSON)
            
            spaceIconsArray.append(spaceIcon)
        }
        
        return spaceIconsArray
    }
}
