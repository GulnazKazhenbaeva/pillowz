//
//  Price.swift
//  Pillowz
//
//  Created by Samat on 06.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

public enum RENT_TYPES : Int {
    case HOURLY = 0
    case HALFDAY = 1
    case DAILY = 2
    case MONTHLY = 3
    case bugi = 4
    
    static let allValues = [HALFDAY, DAILY, MONTHLY]
}

@objcMembers public class Price: NSObject {
    var rent_type:RENT_TYPES? {
        didSet {
            rent_type_display = Price.getDisplayNameForRentType(rent_type: rent_type!, isForPrice: true)
        }
    }
    var price:Int?
    var rent_type_display:[String:String]?
    
    convenience init(json:JSON) {
        self.init()
        
        if (json != JSON.null) {
            self.rent_type = RENT_TYPES(rawValue: json["rent_type"].intValue)!
            self.price = json["price"].intValue
        }
    }
    
    class func getDisplayNameForRentType(rent_type:RENT_TYPES, isForPrice:Bool, isForSpaceView:Bool = false) -> [String:String] {
        var rent_type_display:[String:String]!
        
        if !isForSpaceView {
            if (isForPrice) {
                switch (rent_type) {
                case (.HOURLY):
                    rent_type_display = ["ru":"Цена за час", "en":"Цена за час"]
                case (.DAILY):
                    rent_type_display = ["ru":"Цена за день", "en":"Цена за день"]
                case (.MONTHLY):
                    rent_type_display = ["ru":"Цена за месяц", "en":"Цена за месяц"]
                case (.HALFDAY):
                    rent_type_display = ["ru":"Цена за полсуток", "en":"Цена за полсуток"]
                case (.bugi):
                    rent_type_display = ["ru":"Цена за полсуток", "en":"Цена за полсуток"]
                }
            } else {
                switch (rent_type) {
                case (.HOURLY):
                    rent_type_display = ["ru":"Почасово", "en":"Почасово"]
                case (.DAILY):
                    rent_type_display = ["ru":"Посуточно", "en":"Посуточно"]
                case (.MONTHLY):
                    rent_type_display = ["ru":"Помесячно", "en":"Помесячно"]
                case (.HALFDAY):
                    rent_type_display = ["ru":"На полсуток", "en":"На полсуток"]
                case (.bugi):
                    rent_type_display = ["ru":"На полсуток", "en":"На полсуток"]
                }
            }
        } else {
            switch (rent_type) {
            case (.HOURLY):
                rent_type_display = ["ru":"за час", "en":"за час"]
            case (.DAILY):
                rent_type_display = ["ru":"за сутки", "en":"за сутки"]
            case (.MONTHLY):
                rent_type_display = ["ru":"за месяц", "en":"за месяц"]
            case (.HALFDAY):
                rent_type_display = ["ru":"за полсуток", "en":"за полсуток"]
            case (.bugi):
                rent_type_display = ["ru":"На полсуток", "en":"На полсуток"]
            }
        }
        
        
        return rent_type_display
    }
    
    class func getPricesFromJSON(json:JSON) -> [Price] {
        var prices:[Price] = []
        
        let HOURLY_price = Price()
        HOURLY_price.rent_type = .HOURLY
        HOURLY_price.price = json["HOURLY"]["price"].int
        prices.append(HOURLY_price)

        let HALFDAY_price = Price()
        HALFDAY_price.rent_type = .HALFDAY
        HALFDAY_price.price = json["HALFDAY"]["price"].int
        prices.append(HALFDAY_price)
        
        let DAILY_price = Price()
        DAILY_price.rent_type = .DAILY
        DAILY_price.price = json["DAILY"]["price"].int
        prices.append(DAILY_price)
        
        let MONTHLY_price = Price()
        MONTHLY_price.rent_type = .MONTHLY
        MONTHLY_price.price = json["MONTHLY"]["price"].int
        prices.append(MONTHLY_price)
        
        return prices
    }
}
