//
//  Space.swift
//  Pillowz
//
//  Created by Samat on 27.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

public enum SpaceStatus: Int {
    case DRAFT = 0
    case VISUAL = 1
    case BLOCKED = 2
    case ARCHIVED = 3
    case MODERATION = 4
}

public enum OfferState: Int {
    case available = 0
    case alreadyOffered = 1
    case busy = 2
    case notSuitable = 3
}


@objcMembers public class Space: NSObject, PropertyNames {
    static let currentEditingSpaceSharedInstance = Space()    
    
    public var lon : NSNumber = NSNumber(value: 0)
    public var favourite : Bool?
    public var rule : Rule? = Rule()
    public var cancellation_policy : String = ""
    public var infrastructure : String = ""
    public var comforts : Array<ComfortItem>?
    public var category : SpaceCategory?
    var reviews : Array<Review>?
    public var lat : NSNumber = NSNumber(value: 0)
    public var prices : [Price]?
    public var destination : String = ""
    public var images : Array<Image>?
    public var additional_charges : String = ""
    public var address : String = ""
    public var name : String = ""
    public var review : Int?

    public var arrival_and_checkout:String = ""
    public var arrival_time:Int = 0
    public var checkout_time:Int = 0
    public var additional_features : String = ""
    public var deposit:String = ""

    public var fields : Array<Field>?
    public var space_id : NSNumber = NSNumber(value: 10)
    var realtor : Realtor?
    public var spaceDescription : String = ""
    public var status_display : String = ""
    public var status: SpaceStatus = .DRAFT
    public var published_date : Int?
    public var view_count : Int?
    public var offerState : OfferState?

    public var open_name : String? {
        get {
            return MultiLanguageResponseHandler.getStringFromDict(dict: open_name_lang!)
        }
    }
    public var open_name_lang: [String:String]?

    //for offer
    public var offerPrice = 0

    public var can_review = false

    var spaceIcons:[SpaceIcon]!

    convenience init(json:JSON) {
        self.init()

        self.lon = json["lon"].numberValue
        self.favourite = json["favourite"].bool
        self.rule = Rule(json:json["rule"])
        self.infrastructure = json["infrastructure"].stringValue
        self.comforts = ComfortItem.parseComfortItemsArray(json: json["comforts"].array!)
        self.category = SpaceCategory(json: json["category"])
        self.reviews = Review.parseReviewsArray(json: json["reviews"].array)
        self.lat = json["lat"].numberValue
        self.prices = Price.getPricesFromJSON(json: json["prices"])
        self.destination = json["destination"].stringValue
        self.images = Image.parseImagesArray(json: json["images"].array!)
        self.additional_charges = json["additional_charges"].stringValue
        self.address = json["address"].stringValue
        self.name = json["name"].stringValue
        self.review = json["review"].int

        self.arrival_time = json["arrival_time"].intValue
        self.checkout_time = json["checkout_time"].intValue

        self.arrival_and_checkout = json["arrival_and_checkout"].stringValue
        self.additional_features = json["additional_features"].stringValue
        self.deposit = json["deposit"].stringValue
        self.cancellation_policy = json["cancellation_policy"].stringValue

        if (json["fields"] != JSON.null) {
            self.fields = Field.parseFieldsArray(json: json["fields"].array!)
        }
        self.space_id = json["space_id"].numberValue
        self.realtor = Realtor(json:json["realtor"])
        self.spaceDescription = json["description"].stringValue
        self.status_display = json["status_display"].stringValue

        self.can_review = json["can_review"].boolValue

        self.published_date = json["published_date"].int
        self.view_count = json["view_count"].int
        self.open_name_lang = json["open_name"].dictionaryObject as? [String:String]

        self.spaceIcons = SpaceIcon.parseSpaceIconsArray(json: json["icon_info"].array)

        let intStatus = json["status"].int
        if (intStatus != nil) {
            self.status = SpaceStatus(rawValue: intStatus!)!
        }

        if let offerState = json["enumeration"].int {
            self.offerState = OfferState(rawValue: offerState)
        }
    }

    convenience init(forMap json:JSON) {
        self.init()

        self.lon = json["lon"].numberValue
        self.lat = json["lat"].numberValue
        self.space_id = json["space_id"].numberValue
        self.prices = Price.getPricesFromJSON(json: json["prices"])
    }


    class func parseSpacesArray(json:[JSON], forMap:Bool) -> [Space] {
        var spacesArray:[Space] = []

        for spaceJSON in json {
            var space:Space

            if (forMap) {
                space = Space(forMap: spaceJSON)
            } else {
                space = Space(json: spaceJSON)
            }

            spacesArray.append(space)
        }

        return spacesArray
    }

    func getMultiLanguageNames() -> [String : Any] {
        return [:]
    }

    func getPricesText() -> String {
        var pricesText:String = ""

        if (self.prices!.count > 0) {
            for price in self.prices! {
                if price.price != nil {
                    let totalPrice = Price.getDisplayNameForRentType(rent_type: price.rent_type!, isForPrice: false)["ru"]!

                    pricesText = totalPrice + ", " + price.price!.formattedWithSeparator + "₸"

                    break
                }
            }
        }

        if pricesText == "" {
            pricesText = "не сдается"
        }

        return pricesText
    }

    func getPricesTextForRentType(_ rent_type:RENT_TYPES) -> String {
        var pricesText:String = ""

        if (self.prices!.count > 0) {
            for price in self.prices! {
                if price.price != nil {
                    if (rent_type == price.rent_type!) {
                        let rentTypeText = Price.getDisplayNameForRentType(rent_type: price.rent_type!, isForPrice: false)["ru"]!

                        pricesText = rentTypeText + ", " + price.price!.formattedWithSeparator + "₸"

                        break
                    }
                }
            }
        }

        if pricesText == "" {
            pricesText = "не сдается"
        }

        return pricesText
    }


    func getSmallPricesTextForRentType(_ rent_type:RENT_TYPES) -> String {
        var pricesText:String = ""

        if (self.prices!.count > 0) {
            for price in self.prices! {
                if price.price != nil {
                    if (rent_type == price.rent_type!) {
                        let totalPrice = price.price!.formattedWithSeparator + "₸"

                        pricesText = totalPrice
                    }
                }
            }
        }

        if pricesText == "" {
            pricesText = "не сдается"
        }

        return pricesText
    }

    func getStringDistanceToCurrentUserLocation() -> String {
        let userLocation = LocationManager.shared.currentLocation

        if (userLocation == nil) {
            return "Ваше местоположение недоступно"
        } else {
            let distanceInMeters = Int(CLLocation.distance(from: userLocation!, to: CLLocationCoordinate2D(latitude: self.lat.doubleValue, longitude: self.lon.doubleValue)))

            if (distanceInMeters > 5000) {
                return String(distanceInMeters/1000) + " км от Вас"
            } else {
                return String(format: "%.01f", Double(distanceInMeters)/1000) + " км от Вас"
            }
        }
    }

    func getNonNilPrices() -> [Price] {
        var nonNilPrices:[Price] = []

        for price in self.prices! {
            if (price.price != nil && price.rent_type != .HOURLY) {
                nonNilPrices.append(price)
            }
        }

        return nonNilPrices
    }

    func calculateTotalPriceFor(_ rentType:RENT_TYPES, startTimestamp:Int, endTimestamp:Int) -> Int {
        var totalPrice:Int = 0

        let rentTypePrice = getPriceFor(rentType)

        let numberOfMinutes = Date(timeIntervalSince1970: TimeInterval(endTimestamp)).minutes(from: Date(timeIntervalSince1970: TimeInterval(startTimestamp)))
        var numberOfHours = Date(timeIntervalSince1970: TimeInterval(endTimestamp)).hours(from: Date(timeIntervalSince1970: TimeInterval(startTimestamp)))
        var numberOfDays = Date(timeIntervalSince1970: TimeInterval(endTimestamp)).days(from: Date(timeIntervalSince1970: TimeInterval(startTimestamp)))

        if (rentType == .HALFDAY) {
            totalPrice = rentTypePrice
        } else if (rentType == .HOURLY) {
            if (numberOfMinutes%60 > 30) {
                numberOfHours = numberOfHours + 1
            }

            totalPrice = numberOfHours * rentTypePrice
        } else if (rentType == .DAILY) {
            if (numberOfHours%24 >= 1) {
                numberOfDays = numberOfDays + 1
            }

            totalPrice = numberOfDays * rentTypePrice
        } else {
            totalPrice = rentTypePrice
        }

        return totalPrice
    }

    func getPriceFor(_ rentType:RENT_TYPES) -> Int {
        for price in prices! {
            if (price.rent_type == rentType) {
                if (price.price != nil) {
                    return price.price!
                }
            }
        }

        return 0
    }

    func shouldLetLeaveReviewAndComplain() -> Bool {
        return can_review
    }
}
