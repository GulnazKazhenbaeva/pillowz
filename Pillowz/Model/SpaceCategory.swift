//
//  SpaceCategory.swift
//  Pillowz
//
//  Created by Samat on 30.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

@objcMembers public class SpaceCategory: NSObject {    
    var value:String?
    public var name : String? {
        get {
            if (multiLanguageName != nil) {
                return MultiLanguageResponseHandler.getStringFromDict(dict: multiLanguageName!)
            }
            
            return ""
        }
    }
    public var multiLanguageName : [String:String]?
    var fields:[Field]?
    var search_fields:[Field]?
    var request_fields:[Field]?
    var group:String?
    var unselectedImage = UIImage()
    var selectedImage = UIImage()
    
    convenience init(json:JSON) {
        self.init()
        
        self.value = json["value"].stringValue
        self.multiLanguageName = json["name"].dictionaryObject as? [String:String]
        self.group = json["group"].stringValue

        
        
        if (json["fields"] != JSON.null) {
            let spaceFields = json["fields"]
            
            switch spaceFields.type {
            case .array: do {
                self.fields = Field.parseFieldsArray(json: json["fields"].array!)
                }
            default: do {
                self.fields = []
                }
            }
        }

        
        if (json["search_fields"] != JSON.null) {
            let searchFields = json["search_fields"]
            
            switch searchFields.type {
                case .array: do {
                    self.search_fields = Field.parseFieldsArray(json: json["search_fields"].array!)
                }
                default: do {
                    self.search_fields = []
                }
            }
        }
        
        if (json["request_fields"] != JSON.null) {
            let requestFields = json["request_fields"]
            
            switch requestFields.type {
            case .array: do {
                self.request_fields = Field.parseFieldsArray(json: json["request_fields"].array!)
                }
            default: do {
                self.request_fields = []
                }
            }
        }
    }
    
    class func parseSpaceCategoriesArray(json:[JSON]?) -> [SpaceCategory] {
        var spaceCategoriesArray:[SpaceCategory] = []
        
        if (json == nil) {
            return []
        }
        
        for spaceCategoryJSON in json! {
            let spaceCategory = SpaceCategory(json: spaceCategoryJSON)
                        
            spaceCategoriesArray.append(spaceCategory)
        }
        
        return spaceCategoriesArray
    }
}
