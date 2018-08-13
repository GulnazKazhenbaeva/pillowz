//
//  Language.swift
//  Pillowz
//
//  Created by Samat on 03.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

@objcMembers class Language: NSObject {
    var name:String!
    var language_id:Int!
    
    convenience init(json:JSON) {
        self.init()
        
        name = json["name"].string
        language_id = json["language_id"].int
    }
    
    class func parseLanguagesArray(json:[JSON]) -> [Language] {
        var languagesArray:[Language] = []
        
        for languageJSON in json {
            let language = Language(json: languageJSON)
            
            languagesArray.append(language)
        }
        
        return languagesArray
    }
}
