/* 
Copyright (c) 2017 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import SwiftyJSON

@objcMembers public class ComfortItem:NSObject {
	public var checked : Bool?
    public var name : String? {
        get {
            return MultiLanguageResponseHandler.getStringFromDict(dict: multiLanguageName!)
        }
    }
    public var multiLanguageName : [String:String]?
	public var comfort_item_id : Int?
    public var logo_32x32 : String?
    public var logo_64x64 : String?

    public var rawJSON : JSON?
    
    convenience init(json:JSON) {
        self.init()
        
        if (json["checked"].exists()) {
            self.checked = json["checked"].boolValue
        } else {
            self.checked = false
        }
        self.comfort_item_id = json["comfort_item_id"].intValue
        self.multiLanguageName = json["name"].dictionaryObject as? [String:String]
        self.logo_32x32 = json["logo_32x32"].stringValue
        self.logo_64x64 = json["logo_64x64"].stringValue
        
        self.rawJSON = json
    }
    
    class func parseComfortItemsArray(json:[JSON]?) -> [ComfortItem] {
        var comfortItemsArray:[ComfortItem] = []
        
        if (json == nil) {
            return []
        }
        
        for comfortItemJSON in json! {
            let comfortItem = ComfortItem(json: comfortItemJSON)
                        
            comfortItemsArray.append(comfortItem)
        }
        
        return comfortItemsArray
    }
}
