/* 
Copyright (c) 2017 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit
import SwiftyJSON

public enum RealtorType: Int {
    case owner = 0
    case agent = 1
    case agency = 2
    case hotel = 3
    case hostel = 4
}

@objcMembers class Realtor: NSObject, PropertyNames {
    public var business_name : String?
    public var verified : Bool?
	public var person_name : String?
	public var full : Bool?
	public var contact_number : String?
	public var certificate : String?
	public var business_id : String?
	public var person_id : String?
	public var address : String?
	public var email : String?
	public var rtype_display : String?
    public var rtype : RealtorType?
    public var certificates : [Certificate]?
    
    //user fields
    public var user_id : Int?
    var reviews: [Review]?
    var review: Int?
    var avatar: String?

    convenience init(json:JSON) {
        self.init()
        
        self.business_name = json["business_name"].string
        self.verified = json["verified"].bool
        self.person_name = json["person_name"].string
        self.full = json["full"].bool
        self.contact_number = json["contact_number"].string
        self.certificate = json["certificate"].string
        self.business_id = json["business_id"].string
        self.person_id = json["person_id"].string
        self.address = json["address"].string
        self.email = json["email"].string
        self.rtype_display = json["rtype_display"].string
        self.rtype = RealtorType(rawValue: json["rtype"].intValue)
        
        let certificatesStrings = json["certificates"].arrayObject as? [String]
        
        if (certificatesStrings == nil) {
            return
        }
        
        certificates = []
        
        for string in certificatesStrings! {
            let certificate = Certificate()
            certificate.certificate_url = string
            
            certificates?.append(certificate)
        }
        
        self.user_id = json["user_id"].int
        self.review = json["review"].int
        self.reviews = Review.parseReviewsArray(json: json["reviews"].array)
        self.avatar = json["avatar"].string
    }
    
    var user:User {
        let tempUser = User()
        tempUser.user_id = self.user_id
        tempUser.avatar = self.avatar
        tempUser.review = self.review
        tempUser.reviews = self.reviews
        tempUser.name = self.person_name
        tempUser.phone = self.contact_number
        return tempUser
    }
    
    convenience init(business_name:String, verified:Bool, person_name:String, full:Bool, contact_number:String, certificate:String, business_id:String, person_id:String, address:String, email:String, rtype_display:String, rtype:RealtorType, certificates:[Certificate]) {
        self.init()
        
        self.business_name = business_name
        self.verified = verified
        self.person_name = person_name
        self.full = full
        self.contact_number = contact_number
        self.certificate = certificate
        self.business_id = business_id
        self.person_id = person_id
        self.address = address
        self.email = email
        self.rtype_display = rtype_display
        self.rtype = rtype
        
        //self.certificates = certificates
    }
    
    func getEditableKeys() -> [String] {
        return ["business_name", "person_name", "business_id", "contact_number", "address", "email"];
    }
    
    func getMultiLanguageNames() -> [String : Any] {
        return [
            "business_name":["ru":"Наименование организации", "en":"Наименование организации"],
            "person_name":["ru":"Менеджер", "en":"Менеджер"],
            "business_id":["ru":"БИН", "en":"БИН"],
            "contact_number":["ru":"Контактный телефон", "en":"Контактный телефон"],
            "address":["ru":"Адрес", "en":"Адрес"],
            "email":["ru":"E-mail", "en":"E-mail"],
        ]
    }
}
