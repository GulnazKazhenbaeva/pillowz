/* 
Copyright (c) 2017 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import SwiftyJSON

/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

@objcMembers public class Rule:NSObject, PropertyNames {
    public var baby : Bool = false
    public var child : Bool = false
    public var smoking : Bool = false
	public var pet : Bool = false
    public var party : Bool = false
    public var limited : Bool = false
    public var additional_rule : String = ""
    
    /*
    "additional_rule" = "";
    baby = 0;
    child = 0;
    limited = 1;
    party = 1;
    pet = 0;
    smoking = 0;
     */

    
    
    convenience init(json:JSON) {
        self.init()
        
        self.smoking = json["smoking"].boolValue
        self.additional_rule = json["additional_rule"].stringValue
        self.child = json["child"].boolValue
        self.pet = json["pet"].boolValue
        self.limited = json["limited"].boolValue
        self.party = json["party"].boolValue
        self.baby = json["baby"].boolValue
    }
    
    func getMultiLanguageNames() -> [String : Any] {
        return [
            "smoking":["ru":"Разрешено курить", "en":"Разрешено курить"],
            "additional_rule":["ru":"Дополнительные правила", "en":"Дополнительные правила"],
            "child":["ru":"Подходит для младенцев (до 2 лет)", "en":"Подходит для младенцев (до 2 лет)"],
            "pet":["ru":"Разрешено с питомцами", "en":"Разрешено с питомцами"],
            "limited":["ru":"Подходит для гостей с ограниченными физическими возможностями", "en":"Подходит для гостей с ограниченными физическими возможностями"],
            "party":["ru":"Разрешено проведение вечеринок и праздников", "en":"Разрешено проведение вечеринок и праздников"],
            "baby":["ru":"Подходит для детей (от 2 до 12 лет)", "en":"Подходит для детей (от 2 до 12 лет)"],
        ]
    }
    
    func getIcons() -> [String : String] {
        return ["smoking":"smoke",
                "child":"child",
                "pet":"pets",
                "limited":"limited",
                "party":"party",
                "baby":"baby"]
    }
}
