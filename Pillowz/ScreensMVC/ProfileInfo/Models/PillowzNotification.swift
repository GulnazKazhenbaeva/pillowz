//
//  Notifications.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 05.03.18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

class PillowzNotification: NSObject {
    public var contents : String {
        get {
            return MultiLanguageResponseHandler.getStringFromDict(dict: contents_lang)
        }
    }
    var contents_lang: [String:String]!

    var timestamp: Int!
    var data:[String:Any]!
    
    convenience init(json:JSON) {
        self.init()
        
        self.contents_lang = json["contents"].dictionaryObject as! [String:String]
        self.timestamp = json["timestamp"].intValue
        self.data = json["data"].dictionaryObject as! [String:Any]
    }
    
    class func parseNotificationsArray(json:[JSON]) -> [PillowzNotification] {
        var array:[PillowzNotification] = []
        
        for objectJSON in json {
            let object = PillowzNotification(json: objectJSON)
            
            array.append(object)
        }
        
        return array
    }
}

