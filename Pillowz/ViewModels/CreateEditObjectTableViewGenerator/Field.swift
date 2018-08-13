/* 
Copyright (c) 2017 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import SwiftyJSON

@objc protocol EditableCellDelegate {
    func didSetValue(value: String)
    func didSetCustomText(text: String)
}

public typealias DidPickFieldValueClosure = (_ value: Any) -> Void

@objcMembers public class Field:NSObject {
    public var required_request: Bool?
    public var required_space: Bool?
    public var required_search: Bool?
    public var required: Bool = false
	public var type : String?
    public var defaultValue: String?
    public var value : String = "" {
        didSet {
            if (self.choices == nil) { //if user not picking from list of choices
                self.delegate?.didSetValue(value: value)
            }
        }
    }
    public var choices: [Choice]?
    public var selectedChoice: Choice?
    public var second: Field?
    public var first: Field?
    public var name: String? {
        get {
            if let multiLanguageName = multiLanguageName {
                return MultiLanguageResponseHandler.getStringFromDict(dict: multiLanguageName)
            } else {
                return "no name"
            }
        }
    }
    public var multiLanguageName: [String:String]?
    public var param_name: String?
    public var didPickFieldValueClosure:DidPickFieldValueClosure!
    public var didPickRangeValueClosure:DidPickRangeValueClosure?
    public var didSelectClosure:DidSelectClosure?
    var delegate:EditableCellDelegate?
        
    //this is for providing custom cells for crud VM
    var customCellClassString:String?
    var customCellObject:AnyObject?
    var isCustomCellField = false
    
    //this is for custom text
    var customText:String? {
        didSet {
            delegate?.didSetCustomText(text: customText!)
        }
    }
    
    //this is for rules and comforts that are with icons
    var icon:String?
    var notAllowed:Bool?
    
    //this is for range slider
    public var min: Int?
    public var max: Int?
    
    
    //this is for integerfield input
    var isInput: Bool?
    public var unit: String? {
        get {
            return MultiLanguageResponseHandler.getStringFromDict(dict: multiLanguageUnit!)
        }
    }
    public var multiLanguageUnit: [String:String]?

    override init() {
        super.init()
        
        self.didPickFieldValueClosure = { (newValue) in
            self.value = String(describing:newValue)
        }
        
        self.didPickRangeValueClosure = { (value1, value2) in
            if (value1 != nil) {
                self.first!.value = String(describing:value1!)
            } else {
                self.first!.value = ""
            }
            if (value2 != nil) {
                self.second!.value = String(describing:value2!)
            } else {
                self.second!.value = ""
            }
        }
    }
    
    convenience init(json:JSON) {
        self.init()
                
        self.param_name = json["param_name"].stringValue
        self.type = json["type"].stringValue
        self.required_space = json["required_space"].boolValue
        self.required_search = json["required_search"].boolValue
        self.required_request = json["required_request"].boolValue
        self.defaultValue = json["default"].stringValue
        self.multiLanguageName = json["name"].dictionaryObject as? [String:String]
        
        self.min = json["min"].int
        self.max = json["max"].int
        
        self.isInput = json["is_input"].bool
        self.multiLanguageUnit = json["unit"].dictionaryObject as? [String:String]
        
        if (json["value"] != JSON.null) {
            let intValue = json["value"].int
            
            if (intValue != nil) {
                self.value = String(intValue!)
            } else {
                self.value = json["value"].stringValue
            }
        }
        
        if (json["first"].exists()) {
            self.first = Field(json: json["first"])
            self.second = Field(json: json["second"])
        }
        
        if (json["choices"] != JSON.null) {
            self.choices = Choice.parseChoicesArray(json: json["choices"].array!)
            
            if (self.value != "") {
                for choice in self.choices! {
                    if choice.value! == self.value {
                        self.selectedChoice = choice
                    }
                }
            }
        }
        
        if self.type=="ChoiceField" {
            self.didPickFieldValueClosure = { (newValue) in
                let choice = newValue as! Choice
                self.value = String(choice.value!)
            }
        } else {
            self.didPickFieldValueClosure = { (newValue) in
                self.value = String(describing:newValue)
            }
        }
    }
    
    class func parseFieldsArray(json:[JSON]?) -> [Field] {
        var fieldsArray:[Field] = []
        
        if (json == nil) {
            return []
        }
        
        for fieldJSON in json! {
            let field = Field(json: fieldJSON)
            
            fieldsArray.append(field)
        }
        
        return fieldsArray
    }
    
    func setCustomText(text:String) {
        self.customText = text
    }
        
    class func getNonEmptyFields(fields:[Field]?) -> [Field] {
        var nonEmptyFields = [Field]()
        
        if (fields==nil) {
            return nonEmptyFields
        }
        
        for field in fields! {
            if (field.value != "" && field.value != "0") {
                nonEmptyFields.append(field)
            }
        }
        
        return nonEmptyFields
    }
    
    func shouldAddHeader() -> Bool {
        if ((self.type == "IntegerField" && (self.isInput == nil || self.isInput == false)) || self.type == "BooleanField") {
            return false
        } else {
            return true
        }
    }
}
