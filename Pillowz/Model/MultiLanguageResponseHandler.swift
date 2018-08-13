//
//  MultiLanguageResponseHandler.swift
//  Pillowz
//
//  Created by Samat on 13.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class MultiLanguageResponseHandler: NSObject {
    class func getStringFromDict(dict:[String:String]?) -> String {
        if dict == nil {
            return ""
        }
        
        var result = dict![/*Constants.currentLanguage!*/ "ru"]
        
        if (result == nil) {
            result = dict!["ru"] //russian is default language
        }
        
        return result!
    }
}
