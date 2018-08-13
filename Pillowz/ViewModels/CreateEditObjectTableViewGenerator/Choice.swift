//
//  Choice.swift
//  Pillowz
//
//  Created by Samat on 28.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

@objcMembers public class Choice: NSObject {
    public var value : String?
    public var name: String? {
        get {
            if multiLanguageName == nil {
                return ""
            }
            
            return MultiLanguageResponseHandler.getStringFromDict(dict: multiLanguageName!)
        }
    }
    public var multiLanguageName: [String:String]?

    convenience init(json:JSON) {
        self.init()
        
        self.value = json["value"].stringValue
        self.multiLanguageName = json["name"].dictionaryObject as? [String:String]
    }
    
    override public var description : String {
        get {
            if (self.value == nil) {
                return ""
            }
            return self.value!.description
        }
    }
    
    class func parseChoicesArray(json:[JSON]) -> [Choice] {
        var choicesArray:[Choice] = []
        
        for choiceJSON in json {
            let choice = Choice(json: choiceJSON)
                        
            choicesArray.append(choice)
        }
        
        return choicesArray
    }
}
