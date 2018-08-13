//
//  User.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/2/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

enum UserRole: String {
    case client = "client"
    case realtor = "realtor"
}

enum Gender: Int {
    case none = 0
    case male = 1
    case female = 2
    
    static let allValues = [none, male, female]
}

@objcMembers class User: NSObject, PropertyNames {
    static var shared = User.getSavedUser()
    
    static var currentRole: UserRole { //this is a current role in app UI as user can change roles
        set {
            User.saveCurrentRole(newValue)
            
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            appDelegate.tabbarController?.setClientOrRealtorControllers()
                        
            ProfileTabViewController.shared.profileVC.headerView.snp.updateConstraints { (make) in
                if (newValue == .client) {
                    make.height.equalTo(114)
                } else {
                    make.height.equalTo(174)
                }
            }
            
            User.setupCurrentRoleBadges()
        }
        
        get {
            return User.getCurrentRole()
        }
    }
    
    var avatar_big: String? = ""
    var avatar: String? = ""
    
    var name: String? = ""
    var userDescription: String? = ""
    var gender: Gender? = .none
    var birthday: Int? = 0
    var phone: String? = ""
    var languages: [String]? = []
    var country:Country?
    var job: String? = ""
    var education: String? = ""
    
    var email: String?
    var reviews: [Review]?
    var realtor:Realtor?
    var review: Int?
    var user_id: Int?
    
    var address:String?
    
    static var token:String {
        set {
            let keychain = KeychainSwift()
            keychain.set(newValue, forKey: "PillowzAuthToken")
        }
        get {
            let keychain = KeychainSwift()
            let token = keychain.get("PillowzAuthToken")
            
            if (token==nil) {
                return ""
            }
            
            return token!
        }
    }
    
    convenience init(json:JSON) {
        self.init()

        languages = json["languages"].arrayObject as? [String]
        
        let birthdayString = json["birthday"].string
        if (birthdayString != nil) {
            if (birthdayString != "") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                
                let date = dateFormatter.date(from: birthdayString!)
                
                if (date != nil) {
                    birthday = Int(date!.timeIntervalSince1970)
                }
            }
        }
        
        let genderString = json["gender"].string
        if (genderString == "NONE") {
            gender = .none
        } else if (genderString == "MALE") {
            gender = .male
        } else {
            gender = .female
        }
        
        job = json["job"].string
        email = json["email"].string
        reviews = Review.parseReviewsArray(json: json["reviews"].array)
        education = json["education"].string
        phone = json["phone"].string
        name = json["name"].string
        userDescription = json["description"].string
        country = Country(json:json["country"])
        realtor = Realtor(json:json["realtor"])
        review = json["review"].int
        user_id = json["user_id"].int
        
        avatar_big = json["avatar_big"].string
        avatar = json["avatar"].string

        
        self.avatar = json["avatar"].stringValue
        self.avatar_big = json["avatar_big"].stringValue

        let isFree = !json["realtor"]["busy"].boolValue
        
        User.saveIsFreeStatus(isFree)
        
        //self.avatar!.remove(at: self.avatar!.startIndex)
        //self.avatar_big!.remove(at: self.avatar_big!.startIndex)
        
        //self.avatar = self.avatar!
        //self.avatar_big = self.avatar_big!

    }

    func getEditableKeys() -> [String] {
        return ["name", "userDescription", /*"gender",*/ /*"birthday",*/ "phone", /*"languages", "country",*/"address", "job", "education"];
    }
    
    func getMultiLanguageNames() -> [String : Any] {
        return [
            "name":["ru":"Имя Фамилия", "en":"Имя Фамилия"],
            "userDescription":["ru":"Обо мне", "en":"Обо мне"],
            "phone":["ru":"Контактный телефон", "en":"Контактный телефон"],
            "address":["ru":"Место проживания", "en":"Место проживания"],
            "job":["ru":"Работа", "en":"Работа"],
            "education":["ru":"Образование", "en":"Образование"],
        ]
    }
    
    class func setupCurrentRoleBadges() {
        let isClient = self.currentRole == .client
        
        BadgeView.myRequestsClientBadge.shouldBeShown = isClient
        BadgeView.myRequestsRealtorBadge.shouldBeShown = !isClient
        BadgeView.myRequestsRealtorTopTabBadge.shouldBeShown = !isClient
    }
    
    class func saveUserJsonString(jsonString:String) {
        let json = JSON.init(parseJSON: jsonString)
        
        if let userJsonString = json["user"].rawString() {
            //Do something you want
            UserDefaults.standard.set(userJsonString, forKey: Constants.userDefaultsUserJsonStringKey)
            
            User.shared = User.getSavedUser()
        }
        
        if (json["token"].exists()) {
            User.token = json["token"].stringValue
        }
    }
    
    class func getSavedUser() -> User {
        let jsonString = UserDefaults.standard.value(forKey: Constants.userDefaultsUserJsonStringKey) as? String
        
        if (jsonString != nil) {
            let json = JSON.init(parseJSON: jsonString!)
            
            let user = User(json: json)
            
            return user
        } else {
            User.token = ""
            return User()
        }
    }
    
    class func isLoggedIn() -> Bool {
        if User.token=="" {
            return false
        } else {
            return true
        }
    }
    
    class func logout() {
        UserDefaults.standard.removeObject(forKey: Constants.userDefaultsUserJsonStringKey)
        User.token = ""
    }
    
    convenience init(forMessages json:JSON) {
        self.init()
        
        self.phone = json["phone"].string
        self.name = json["name"].string
        self.userDescription = json["description"].string
        self.avatar = json["avatar"].string
        self.user_id = json["user_id"].int
    }
    
    convenience init(forRequest json:JSON) {
        self.init()
        
        self.name = json["name"].string
        self.avatar = json["avatar"].string
        self.user_id = json["id"].int
        self.phone = json["contact_number"].string
        self.address = json["address_info"].string
        self.review = json["review"].int
        
        if (self.review == nil) {
            review = 5
        }
        
        self.reviews = Review.parseReviewsArray(json: json["reviews"].array)
    }

    convenience init(forReview json:JSON) {
        self.init()
        
        self.name = json["name"].string
        self.avatar = json["avatar"].string
        
        if (self.avatar != nil) {
            self.avatar = String(Constants.baseURL.dropLast()) + self.avatar!
        }
        
        self.user_id = json["user_id"].int
        self.phone = json["phone"].string
        self.address = json["address"].string
    }

    
    class func getDisplayNameForGender(gender:Gender) -> [String:String] {
        var gender_display:[String:String]!
        
        switch (gender) {
        case (.none):
            gender_display = ["ru":"Не выбран", "en":"Не выбран"]
        case (.male):
            gender_display = ["ru":"Мужской", "en":"Мужской"]
        case (.female):
            gender_display = ["ru":"Женский", "en":"Женский"]
        }
        
        return gender_display
    }

    class func saveCurrentRole(_ role:UserRole) {
        var roleString:String
        if (role == .client) {
            roleString = "client"
        } else {
            roleString = "realtor"
        }
        
        UserDefaults.standard.set(roleString, forKey: Constants.userCurrentRoleStringKey)
    }
    
    class func getCurrentRole() -> UserRole {
        let roleString = UserDefaults.standard.value(forKey: Constants.userCurrentRoleStringKey) as? String

        if (roleString == nil) {
            return .client
        } else {
            if (roleString! == "client") {
                return .client
            } else {
                return .realtor
            }
        }
    }
    
    class func saveIsFreeStatus(_ isFree:Bool) {
        var isFreeString:String
        
        isFreeString = isFree.description
        
        UserDefaults.standard.set(isFreeString, forKey: Constants.userIsFreeStatusStringKey)
    }
    
    class func getIsFreeStatus() -> Bool {
        let isFreeString = UserDefaults.standard.value(forKey: Constants.userIsFreeStatusStringKey) as? String
        
        if (isFreeString == nil) {
            return true
        } else {
            return isFreeString!.toBool()
        }
    }
    
    
    class func saveRecentPlaces(_ recentPlaces:[[String: Any]]) {
        UserDefaults.standard.set(recentPlaces, forKey: "recentPlaces")
    }
    
    class func getRecentPlaces() -> [[String: Any]] {
        if let recentPlaces = UserDefaults.standard.array(forKey: "recentPlaces") as? [[String: Any]] {

            return recentPlaces
        } else {
            return [[:]]
        }
    }
    
    class func addRecentPlace(_ place:[String: Any]) {
        if ((place["address"] as! String) == "") {
            return
        }
        
        var recentPlaces = User.getRecentPlaces()
        
        var replaced = false
        for recentPlace in recentPlaces {
            if ((recentPlace["address"] as? String) == (place["address"] as? String)) {
                let index = recentPlaces.index { (place) -> Bool in
                    return (recentPlace["address"] as! String) == (place["address"] as! String)
                }

                if (index != nil) {
                    replaced = true
                    recentPlaces[index!] = place
                }
            }
        }
        
        if (!replaced) {
            if (recentPlaces.count>4) {
                recentPlaces.removeLast()
            }
            
            recentPlaces.insert(place, at: 0)
        }

        User.saveRecentPlaces(recentPlaces)
    }
    
    class func getRtypeNameFor(_ rtype:RealtorType) -> String {
        switch rtype {
        case .owner:
            return "владелец"
        case .agent:
            return "частный агент"
        case .agency:
            return "агенство недвижимости"
        case .hostel:
            return "хостел"
        case .hotel:
            return "гостиница"
        }
    }
    
    func isRealtor() -> Bool {
        return (self.realtor?.business_id != nil && self.realtor?.business_id != "") || (self.realtor?.person_id != nil && self.realtor?.person_id != "")
    }
    
    func shouldLetLeaveReviewAndComplain() -> Bool {
        if self.user_id == User.shared.user_id {
            return false
        }
        
        if let contact_number = self.realtor?.contact_number, let phone = self.phone {
            if contact_number.contains("*") || phone .contains("*") {
                return false
            }
        }
        
        return true
    }
}
