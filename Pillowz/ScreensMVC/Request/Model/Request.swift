                                                                                              //
//  self.swift
//  Pillowz
//
//  Created by Samat on 09.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD

enum RequestType: Int {
    case OPEN = 0
    case PERSONAL = 1
}

enum RequestStatus: Int {
    case NOT_VIEWED = 0 //(Заявка не просмотрена)
    case VIEWED = 1 //(Заявка просмотрена. Ответа пока нет)
    case CLIENT_OFFER = 2 //(Ваша стоимость не просмотрена)
    case CLIENT_OFFER_VIEWED = 3 //(Ваша стоимость просмотрена. Ответа пока нет)
    case REALTOR_OFFER = 4 //(Новая стоимость)
    case REALTOR_OFFER_VIEWED = 5 //(Новая стоимость)
    case CLIENT_REJECTED = 6 //(Заявка отклонена)
    case REALTOR_REJECTED = 7 //(Заявка отклонена)
    case COMPLETED = 8 //(Заявка одобрена)
    case COMPLETED_WITH_OTHER = 9 //(Одобрена с другим риэлтором)
    case MAX_ITERATIONS_EXCEEDED = 10 //(Максимальное количество итераций в торге)
    case REQUEST_TIMED_OUT = 11 //(Заявка не актуальна по времени)
    case CANCELLED = 12 //(Общая заявка отменена)
}

class Request: NSObject {    
    var address : String?
    var lon : Double?
    var space_rule : Rule?
    var comforts : [ComfortItem]?
    var lat : Double?
    var space_fields : [Field]?
    var status_display : String?
    
    var realtor_price : Int?
    var left_time : String?
    var rent_type : RENT_TYPES?
    var request_id : Int?
    var city : City?
    var end_time : Int?
    var price : Int?
    var owner : Bool?
    var deposit : Bool?
    var chat_room : String?
    var start_time : Int?
    var space_name : String?
    var bargain : Bool?
    var timestamp : Int?
    var status : RequestStatus?
    var is_p_status_offer : Bool = false
    var suitable : Bool?
    var rent_type_display : String?
    var space_category : SpaceCategory?
    var rooms : Int?
    var urgent : Bool?
    var photo : Bool?
    var offers : [Offer]?
    var favourite : Bool?
    
    var offers_count : Int?
    var new_offers_count : Int?
    var new_prices_count : Int?
    var view_count : Int?
    
    var guests_count: [String:Int]?
    
    var space_info:[String:Any]?
    var realtor:User?
    
    var client_viewed:Bool!
    var realtor_viewed:Bool!
    
    var can_review:Bool!

    public var open_name : String? {
        get {
            return MultiLanguageResponseHandler.getStringFromDict(dict: open_name_lang)
        }
    }
    public var open_name_lang: [String:String]?
    
    public var open_price : String? {
        get {
            return MultiLanguageResponseHandler.getStringFromDict(dict: open_price_lang)
        }
    }
    var open_price_lang: [String:String]?

    var user:User?
    
    var req_type:RequestType?
    public var fields : Array<Field>?

    var space:Space?
    public var price_histories:[[String:Any]]?

    var deadline:Int?
    
    var offersAreOpenedInList:Bool = false
    
    var otherUser:User {
        if (self.user?.user_id == User.shared.user_id && User.currentRole == .client) {
            return self.realtor!
        } else {
            return self.user!
        }
    }
    
    var agreePrice:Int {
        if (User.currentRole == .client) {
            return self.realtor_price!
        } else {
            return self.price!
        }
    }
    
    var firstPrice:Int {
        var varThatWillBeFirstPrice:Int?
        
        if (price_histories != nil) {
            if (price_histories!.count > 0) {
                let iteration = price_histories!.first!
                
                if (status! == .CLIENT_OFFER || status! == .CLIENT_OFFER_VIEWED) {
                    varThatWillBeFirstPrice = iteration["price_client"] as? Int
                } else {
                    varThatWillBeFirstPrice = iteration["price_realtor"] as? Int
                }
            }
        }
        
        if (varThatWillBeFirstPrice == nil) {
            if (User.currentRole == .client) {
                varThatWillBeFirstPrice = price
            } else {
                varThatWillBeFirstPrice = realtor_price
            }
        }
        
        if (varThatWillBeFirstPrice == nil) {
            varThatWillBeFirstPrice = 0
        }
        
        return varThatWillBeFirstPrice!
    }

    
    convenience init(json:JSON) {
        self.init()
        
        self.lon = json["lon"].double
        self.space_rule = Rule(json:json["space_rule"])
        self.comforts = ComfortItem.parseComfortItemsArray(json: json["comforts"].array)
        self.lat = json["lat"].double
        self.address = json["address"].string
        self.space_fields = Field.parseFieldsArray(json: json["space_fields"]["all"].array)
        self.status_display = json["status_display"].string
        
        self.realtor_price = json["realtor_price"].int
        self.left_time = json["left_time"].string
        self.rent_type = RENT_TYPES(rawValue: json["rent_type"].intValue)
        self.request_id = json["request_id"].int
        self.city = City(json:json["city"])
        self.end_time = json["end_time"].int
        self.price = json["price"].int
        self.owner = json["owner"].bool
        self.deposit = json["deposit"].bool
        self.chat_room = json["chat_room"].string
        self.start_time = json["start_time"].int
        self.space_name = json["space_name"].string
        self.bargain = json["bargain"].bool
        self.timestamp = json["timestamp"].int
        
        if (json["p_status"].exists()) {
            self.status = RequestStatus(rawValue: json["p_status"].intValue)
        } else {
            self.status = RequestStatus(rawValue: json["status"].intValue)
        }
        self.is_p_status_offer = json["is_p_status_offer"].boolValue
        
        self.suitable = json["suitable"].bool
        self.rent_type_display = json["rent_type_display"].string
        self.space_category = SpaceCategory(json: json["space_category"])
        self.rooms = json["rooms"].int
        self.urgent = json["urgent"].bool
        self.photo = json["photo"].bool
        
        self.offers_count = json["offers_count"].int
        self.new_offers_count = json["new_offers_count"].int
        self.new_prices_count = json["new_prices_count"].int
        self.view_count = json["view_count"].int

        
        if (json["guests_count"] != JSON.null) {
            self.guests_count = json["guests_count"].dictionaryObject as? [String:Int]
        }
        
        if (json["offers"].exists()) {
            self.offers = Offer.parseOffersArray(json: json["offers"].array)
            
            for offer in self.offers! {
                offer.request = self
            }
        }
        
        self.can_review = json["can_review"].boolValue
        
        self.favourite = json["favourite"].boolValue
        
        self.user = User(forRequest: json["user_info"])
        
        self.space_info = json["space_info"].dictionaryObject
        
        self.realtor = User(forRequest: json["realtor_info"])
        
        if (self.realtor?.user_id == nil) {
            self.realtor = self.user
        }
        
        self.req_type = RequestType(rawValue: json["req_type"].intValue)!
        if (json["fields"] != JSON.null) {
            self.fields = Field.parseFieldsArray(json: json["fields"].array!)
        }
        
        if (json["space"] != JSON.null) {
            self.space = Space(json: json["space"])
        }
        
        self.open_name_lang = json["space_info"]["open_name_lang"].dictionaryObject as? [String:String]
        
        if (self.open_name_lang == nil) {
            self.open_name_lang = json["space_info"]["open_name"].dictionaryObject as? [String:String]
        }
        
        self.open_price_lang = json["space_info"]["open_price"].dictionaryObject as? [String:String]
        
        self.price_histories = json["price_histories"].arrayObject as? [[String : Any]]
        
        self.deadline = json["deadline"].int
        
        self.client_viewed = json["client_viewed"].boolValue
        self.realtor_viewed = json["realtor_viewed"].boolValue
    }
    
    class func parseRequestsArray(json:[JSON]) -> [Request] {
        var requestArray:[Request] = []
        
        for requestJSON in json {
            let request = Request(json: requestJSON)
            
            requestArray.append(request)
        }
        
        return requestArray
    }

    func getPricesText() -> String {
        let rentTypeString = getRequestPeriodString()
        
        return "на " + rentTypeString + " за " + self.price!.formattedWithSeparator + "₸"
    }
    
    func getRequestPeriodString() -> String {
        return Request.getPeriodString(start_time: self.start_time, end_time: self.end_time, rent_type: self.rent_type)
    }
    
    class func getPeriodString(start_time:Int?, end_time:Int?, rent_type:RENT_TYPES?) -> String {
        var rentTypeString:String = ""
        
        if (rent_type! == .HALFDAY) {
            rentTypeString = "полсуток"
        } else if (rent_type! == .HOURLY) {
            if (start_time != nil && end_time != nil) {
                let numberOfHours = Date(timeIntervalSince1970: TimeInterval(end_time!)).hours(from: Date(timeIntervalSince1970: TimeInterval(start_time!)))
                
                rentTypeString = String(numberOfHours) + " " + Helpers.returnSuffix(count: numberOfHours, type: "hour")
            }
            
        } else if (rent_type! == .DAILY) {
            if (start_time != nil && end_time != nil) {
                let numberOfDays = Date(timeIntervalSince1970: TimeInterval(end_time!)).days(from: Date(timeIntervalSince1970: TimeInterval(start_time!)))
                
                let numberOfHours = Date(timeIntervalSince1970: TimeInterval(end_time!)).hours(from: Date(timeIntervalSince1970: TimeInterval(start_time!)))%24
                
                rentTypeString = String(numberOfDays) + " " + Helpers.returnSuffix(count: numberOfDays, type: "day")
                
                if numberOfHours != 0 {
                    rentTypeString = rentTypeString + " " + String(numberOfHours) + " " + Helpers.returnSuffix(count: numberOfHours, type: "hour")
                }
            }
        } else {
            if (start_time != nil && end_time != nil) {
                rentTypeString = "помесячно"
            }
        }
        
        return rentTypeString
    }
        
    func getGuestsFields() -> [Field] {
        var guestsFields:[Field] = []
        
        let guests_count = self.guests_count
        
        let numberOfAdults = guests_count?["adult_guest"]
        let numberOfChildren = guests_count?["child_guest"]
        let numberOfBabies = guests_count?["baby_guest"]

        if (numberOfAdults != nil && numberOfAdults != 0) {
            let guestField = Field()
            guestField.multiLanguageName = ["ru":"Взрослые", "en":"Взрослые"]
            guestField.value = String(numberOfAdults!)
            
            guestsFields.append(guestField)
        }
        
        if (numberOfChildren != nil && numberOfChildren != 0) {
            let guestField = Field()
            guestField.multiLanguageName = ["ru":"Дети", "en":"Дети"]
            guestField.value = String(numberOfChildren!)
            
            guestsFields.append(guestField)
        }
        
        if (numberOfBabies != nil && numberOfBabies != 0) {
            let guestField = Field()
            guestField.multiLanguageName = ["ru":"Младенцы", "en":"Младенцы"]
            guestField.value = String(numberOfBabies!)
            
            guestsFields.append(guestField)
        }

        return guestsFields
    }
    
    class func getStringForRentType(_ rentType:RENT_TYPES, startTime:Int?, endTime:Int?, shouldGoToNextLine:Bool = false, includeRentTypeText:Bool = true) -> String {
        if (startTime == nil) {
            return ""
        }
        
        let rentTypeText = Price.getDisplayNameForRentType(rent_type: rentType, isForPrice: false)["ru"]!
        
        var fullText:String = ""
            
        if (includeRentTypeText) {
            fullText = rentTypeText
        }
        
        let todayDate = Date()
        let tomorrowDate = todayDate.add(.init(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
        
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "dd MMM"
        dayDateFormatter.locale = Locale(identifier: "ru_RU")
        
        let todayDateString = dayDateFormatter.string(from: todayDate)
        let tomorrowDateString = dayDateFormatter.string(from: tomorrowDate)

        let timeDateFormatter = DateFormatter()
        timeDateFormatter.dateFormat = "HH:mm"
        timeDateFormatter.locale = Locale(identifier: "ru_RU")
        
        if (startTime != nil || endTime != nil) && includeRentTypeText {
            fullText = fullText + ", "
        }
        
        var startDateDayText = dayDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTime!)))
        
        if startDateDayText == todayDateString {
            startDateDayText = "Сегодня"
        } else if startDateDayText == tomorrowDateString {
            startDateDayText = "Завтра"
        }
        
        if (startTime != nil) {
            let startDateText = startDateDayText + " " + timeDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTime!)))
            
            fullText = fullText + startDateText
        }
        
        if (endTime != nil) {
            var endDateDayText = dayDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endTime!)))
            
            if endDateDayText == todayDateString {
                endDateDayText = "Сегодня"
            } else if endDateDayText == tomorrowDateString {
                endDateDayText = "Завтра"
            }
            
            var endDateText:String = endDateDayText + " " + timeDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endTime!)))
            
            if (endDateDayText == startDateDayText) {
                endDateText = timeDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endTime!)))
            }
            
            if (shouldGoToNextLine) {
                fullText = fullText + "\n"
            }
            
            fullText = fullText + " - " + endDateText
        }

        return fullText
    }
    
    class func getStatusText(isOffer:Bool, request:Request?, offer:Offer?) -> (String, UIColor, UIFont) {
        var isOffer = isOffer
        var statusText = ""
        var statusColor = Constants.paletteLightGrayColor
        var statusFont = UIFont(name: "OpenSans-SemiBold", size: 10)!
        
        var status:RequestStatus
        
        if (!isOffer && offer == nil) {
            if (request!.is_p_status_offer) {
                isOffer = true
            }
            status = request!.status!
        } else {
            status = offer!.status!
        }
        
        var completedText:String
        if (isOffer) {
            completedText = "Предложение одобрено"
        } else {
            completedText = "Заявка одобрена"
        }
        
        var notViewedText:String
        if (isOffer) {
            notViewedText = "Предложение не просмотрено"
        } else {
            if (User.currentRole == .client) {
                notViewedText = "Заявка не просмотрена"
            } else {
                notViewedText = "Новая заявка"
            }
        }
        
        var viewedText:String
        if (isOffer) {
            viewedText = "Предложение просмотрено. Ответа пока не"
        } else {
            viewedText = "Заявка просмотрена. Ответа пока нет"
        }
        
        var rejectedText:String
        if (isOffer) {
            rejectedText = "Предложение отклонено"
        } else {
            rejectedText = "Заявка отклонена"
        }

        let newPriceText = "Новая цена"
        let yourNewPriceNotViewedText = "Ваша цена не просмотрена"
        let yourNewPriceViewedText = "Ваша цена просмотрена. Ответа пока нет"
        
        switch status {
        case .COMPLETED:
            statusText = completedText
            statusColor = UIColor(hexString: "#B1E37F")
        case .COMPLETED_WITH_OTHER:
            statusText = "Заявка согласована с другим владельцем"
            statusColor = UIColor(hexString: "#FA3C3C")
        case .REQUEST_TIMED_OUT:
            statusText = "Заявка просрочена"
            statusColor = UIColor(hexString: "#FA3C3C")
        default:
            statusText = ""
        }
        
        if statusColor !== Constants.paletteLightGrayColor {
            statusFont = UIFont(name: "OpenSans-Bold", size: 10)!
        }

        if (statusText != "") {
            return (statusText, statusColor, statusFont)
        }
        
        
        if (request!.req_type! == .OPEN && !isOffer && User.currentRole == .client) {
            if (request!.offers_count != nil) {
                if (request!.offers_count! != 0) {
                    statusText = "Новых предложений: " + String(request!.offers_count!)
                }
            }
            
            if (request!.new_prices_count != nil) {
                if (request!.new_prices_count! != 0) {
                    let pricesString = "Новых цен: " + String(request!.new_prices_count!)
                    
                    if (statusText == "") {
                        statusText = pricesString
                    } else {
                        statusText = statusText + ", " + pricesString
                    }
                }
            }
        } else {
            switch status {
            case .CLIENT_OFFER:
                if (User.currentRole == .realtor) {
                    statusText = newPriceText
                } else {
                    statusText = yourNewPriceNotViewedText
                }
            case .CLIENT_OFFER_VIEWED:
                if (User.currentRole == .realtor) {
                    statusText = newPriceText
                } else {
                    statusText = yourNewPriceViewedText
                }
            case .REALTOR_OFFER:
                if (User.currentRole == .realtor) {
                    statusText = yourNewPriceNotViewedText
                } else {
                    statusText = newPriceText
                }
            case .REALTOR_OFFER_VIEWED:
                if (User.currentRole == .realtor) {
                    statusText = yourNewPriceViewedText
                } else {
                    statusText = newPriceText
                }
            default:
                statusText = ""
            }
        }
        
        if statusColor !== Constants.paletteLightGrayColor {
            statusFont = UIFont(name: "OpenSans-Bold", size: 10)!
        }

        if (statusText != "") {
            return (statusText, statusColor, statusFont)
        }
        
        if (request!.req_type! == .OPEN && !isOffer && User.currentRole == .client) {
            if let view_count = request!.view_count {
                if (view_count == 0) {
                    statusText = "Заявка никем не просмотрена"
                } else {
                    statusText = "Заявка просмотрена " + String(view_count) + " раз. Ответа пока нет."
                }
            }
            
            if statusColor !== Constants.paletteLightGrayColor {
                statusFont = UIFont(name: "OpenSans-Bold", size: 10)!
            }

            if (statusText != "") {
                return (statusText, statusColor, statusFont)
            }
        }

        switch status {
        case .NOT_VIEWED:
            statusText = notViewedText
        case .VIEWED:
            statusText = viewedText
        case .CLIENT_REJECTED:
            statusText = rejectedText
            statusColor = UIColor(hexString: "#FA3C3C")
        case .REALTOR_REJECTED:
            statusText = rejectedText
            statusColor = UIColor(hexString: "#FA3C3C")
        case .MAX_ITERATIONS_EXCEEDED:
            statusText = "Количество шагов торга превышено"
            statusColor = UIColor(hexString: "#FA3C3C")
        case .CANCELLED:
            statusText = "Заявка отменена"
            statusColor = UIColor(hexString: "#FA3C3C")
        default:
            statusText = ""
        }
        
        if statusColor !== Constants.paletteLightGrayColor {
            statusFont = UIFont(name: "OpenSans-Bold", size: 10)!
        }

        return (statusText, statusColor, statusFont)
    }
    
    func getRequestActiveTimeLeftText() -> String {
        let deadline = self.deadline
        
        if (deadline != nil) {
            let fullTimeText = Request.getTimeLeftStringForTimestamp(deadline!)
            
            if (fullTimeText == "") {
                return "Заявка аннулирована"
            } else {
                //return "Аннулируется через " + fullTimeText
                return fullTimeText
            }
        } else {
            return "Время не ограничено"
        }
    }
    
    func getRequestStartTimeLeftText() -> String {
        let startTime = self.start_time
        
        if (startTime != nil) {
            let fullTimeText = Request.getTimeLeftStringForTimestamp(startTime!)
            
            if (fullTimeText == "") {
                return "Бронь прошла"
            } else {
                return "Осталось " + fullTimeText
            }
        } else {
            return "Время брони не указано"
        }
    }
    
    class func getTimeLeftStringForTimestamp(_ timestamp:Int) -> String {
        let endDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        var fullTimeText = ""
        
        let days = endDate.daysUntil
        
        if (days > 0) {
            fullTimeText = fullTimeText + String(days)+"д "
        }
        
        var hours = endDate.hoursUntil
        
        if (hours > 0) {
            hours = hours - 24*days
            
            fullTimeText = fullTimeText + String(hours)+"ч "
        }
        
        var minutes = endDate.minutesUntil
        
        if (minutes > 0) {
            minutes = minutes - 24*60*days - 60*hours
            
            fullTimeText = fullTimeText + String(minutes)+"м"
        }
        
        return fullTimeText
    }
    
    func getNumberOfGuests() -> Int {
        var totalNumberOfGuests = 0
        
        let numberOfAdults = guests_count?["adult_guest"]
        let numberOfChildren = guests_count?["child_guest"]
        
        if (numberOfAdults != nil) {
            totalNumberOfGuests = totalNumberOfGuests + numberOfAdults!
        }
        
        if (numberOfChildren != nil) {
            totalNumberOfGuests = totalNumberOfGuests + numberOfChildren!
        }
        
        return totalNumberOfGuests
    }
    
    
    func agreeTapped(completion:@escaping APIClosure) {
        var titleText:String = ""
        var descriptionText:String = ""
        var viewIdentifier:String = ""

        if (User.currentRole == .client) {
            if (self.req_type! == .PERSONAL) {//----eee
                titleText = "Вы уверены что хотите согласится на жилье?"
                descriptionText = "В случае согласия, заявка будет закрыта со статусом “Одобрена”, и Вам будет открыта контактная информация владельца. Созвонитесь или напишите в чат или на email владельцу, чтобы обговорить дальнейшие Ваши действия."
                viewIdentifier = "agreeTapped" + "Personal" + "Client"
            } else {//----eee
                titleText = ""
                descriptionText = ""
                viewIdentifier = "agreeTapped" + "Open" + "Client"
            }
        } else {
            if (self.req_type! == .PERSONAL) {
                titleText = "Вы уверены что хотите согласится на жилье?"
                descriptionText = "В случае согласия, заявка будет закрыта со статусом “Одобрена”, и Вам будет открыта контактная информация клиента. Созвонитесь или напишите в чат или на email клиенту, чтобы обговорить дальнейшие Ваши действия."
                viewIdentifier = "agreeTapped" + "Personal" + "Realtor"
            } else {//---eeeee
                titleText = ""
                descriptionText = ""
                viewIdentifier = "agreeTapped" + "Open" + "Realtor"
            }
        }
        
        let window = UIApplication.shared.delegate!.window!!

        let infoView = ModalInfoView(titleText: titleText, descriptionText: descriptionText, viewIdentifier: viewIdentifier)
        
        infoView.addButtonWithTitle("Да", action: {
            var status:RequestStatus
            
            status = .COMPLETED
            
            MBProgressHUD.showAdded(to: window, animated: true)
            
            RequestAPIManager.updatePersonalRequestStatus(request: self, status: status) { (responseObject, error) in
                MBProgressHUD.hide(for: window, animated: true)

                completion(responseObject, error)
            }
        })
        
        infoView.addButtonWithTitle("Нет", action: {
            
        })
        
        infoView.show()
    }
    
    
    func offerNewPriceTapped(newPrice: Int, completion:@escaping APIClosure) {
        var titleText:String = ""
        var descriptionText:String = ""
        var viewIdentifier:String = ""
        
        if (User.currentRole == .client) {
            if (self.req_type! == .PERSONAL) {
                titleText = "Ваша цена отправлена Владельцу"
                descriptionText = "Необходимо дождаться ответа от Владельца. Владелец может сразу согласиться на вашу цену и тогда заявка будет считаться одобренной или предложит свою новую цену. Если по исчерпании 5 шагов торга ни одна из сторон ни даст согласие, то предложение автоматически будет отклонено."
                viewIdentifier = "offerNewPriceTapped" + "Personal" + "Client"
            } else {
                titleText = ""
                descriptionText = ""
                viewIdentifier = "offerNewPriceTapped" + "Open" + "Client"
            }
        } else {
            if (self.req_type! == .PERSONAL) {
                titleText = "Ваша цена отправлена Клиенту"
                descriptionText = "Необходимо дождаться ответа от Клиента. Клиент может сразу согласиться на вашу цену и тогда заявка будет считаться одобренной или предложит свою новую цену. Если по исчерпании 5 шагов торга ни одна из сторон ни даст согласие, то заявка автоматически будет отклонена."
                viewIdentifier = "offerNewPriceTapped" + "Personal" + "Realtor"
            } else {
                titleText = ""
                descriptionText = ""
                viewIdentifier = "offerNewPriceTapped" + "Open" + "Realtor"
            }
        }
        
        let window = UIApplication.shared.delegate!.window!!

        let infoView = ModalInfoView(titleText: titleText, descriptionText: descriptionText, viewIdentifier: viewIdentifier)
        
        infoView.addButtonWithTitle("OK", action: {
            
        })
        
        MBProgressHUD.showAdded(to: window, animated: true)
        
        RequestAPIManager.updatePersonalRequestPrice(request: self, price: newPrice) { (responseObject, error) in
            infoView.show()
            
            MBProgressHUD.hide(for: window, animated: true)
            
            completion(responseObject, error)
        }
    }
    
    
    func rejectTapped(completion:@escaping APIClosure) {
        var titleText:String = ""
        var descriptionText:String = ""
        var viewIdentifier:String = ""
        
        if (User.currentRole == .client) {
            if (self.req_type! == .PERSONAL) {//----eee
                titleText = "Вы уверены что хотите отменить заявку на жилье?"
                descriptionText = "Заявка будет удалена и вы больше не сможете по ней получать отклики."
                
                if (self.status == .COMPLETED) {
                    descriptionText = descriptionText + "\n\nВы отменяете заявку которая уже одобрена. Это может повлиять на Ваш рейтинг."
                }
                
                viewIdentifier = "rejectTapped" + "Personal" + "Client"
            } else {//----eee
                titleText = "Вы уверены что хотите отменить открытую заявку?"
                descriptionText = "Заявка будет удалена и вы больше не сможете по ней получать отклики."
                
                if (self.status == .COMPLETED) {
                    descriptionText = descriptionText + "\n\n Мы обнаружили что по данной заявке уже есть одно одобренное предложение. Отмена заявки может повлиять на Ваш рейтинг."
                }
                
                viewIdentifier = "rejectTapped" + "Open" + "Client"
            }
        } else {
            if (self.req_type! == .PERSONAL) {
                titleText = "Вы уверены что хотите отклонить заявку на жилье?"
                descriptionText = "Заявка будет удалена из списка и вы больше не сможете по ней делать отклики."
                viewIdentifier = "rejectTapped" + "Personal" + "Realtor"
            } else {//----eee
                titleText = ""
                descriptionText = ""
                viewIdentifier = "rejectTapped" + "Open" + "Realtor"
            }
        }
        
        let window = UIApplication.shared.delegate!.window!!

        let infoView = ModalInfoView(titleText: titleText, descriptionText: descriptionText, viewIdentifier: viewIdentifier)
        
        infoView.addButtonWithTitle("Да", action: {
            var status:RequestStatus
            
            if (User.currentRole == .client) {
                status = .CLIENT_REJECTED
            } else {
                status = .REALTOR_REJECTED
            }
            
            MBProgressHUD.showAdded(to: window, animated: true)
            
            if (self.req_type! == .PERSONAL) {
                RequestAPIManager.updatePersonalRequestStatus(request: self, status: status) { (responseObject, error) in
                    MBProgressHUD.hide(for: window, animated: true)
                    
                    completion(responseObject, error)
                }
            } else {
                RequestAPIManager.deleteRequest(self.request_id!, completion: { (responseObject, error) in
                    MBProgressHUD.hide(for: window, animated: true)
                    
                    completion(responseObject, error)
                })
            }
        })
        
        infoView.addButtonWithTitle("Нет", action: {
            
        })
        
        infoView.show()
    }
    
    
    @objc func hideTapped(completion:@escaping APIClosure) {
        let window = UIApplication.shared.delegate!.window!!

        MBProgressHUD.showAdded(to: window, animated: true)
        
        RequestAPIManager.hideRequest(self.request_id!) { (responseObject, error) in
            MBProgressHUD.hide(for: window, animated: true)
            
            completion(responseObject, error)
        }        
    }
    
    func isWaitingForAnswer() -> Bool {
        return (User.currentRole == .client && (status == .CLIENT_OFFER || status == .CLIENT_OFFER_VIEWED || justSentAnOffer())) || (User.currentRole == .realtor && (status == .REALTOR_OFFER || status == .REALTOR_OFFER_VIEWED))
    }
    
    func justSentAnOffer() -> Bool {
        return (User.currentRole == .client && (status == .VIEWED || status == .NOT_VIEWED))
    }
    
    func isCompleted() -> Bool {
        return status == .COMPLETED || status == .COMPLETED_WITH_OTHER || status == .CLIENT_REJECTED || status == .REALTOR_REJECTED || status == .MAX_ITERATIONS_EXCEEDED || status == .REQUEST_TIMED_OUT
    }
    
    func isActive() -> Bool {
        return (self.deadline! > Int(Date().timeIntervalSince1970) && self.status!.rawValue <= 5) || self.status == .COMPLETED
    }
    
    func isAbleToArchive() -> Bool {
        return !(self.deadline! > Int(Date().timeIntervalSince1970) && self.status!.rawValue <= 5)
    }
    
    
    func getLastPrice(role:UserRole) -> Int? {
        var varThatWillBeLastPrice:Int?
        
        if (price_histories != nil) {
            if (price_histories!.count > 0) {
                let iteration = price_histories!.last!
                
                if (role == .client) {
                    varThatWillBeLastPrice = iteration["price_client"] as? Int
                } else {
                    varThatWillBeLastPrice = iteration["price_realtor"] as? Int
                }
            }
        }
        
        if (varThatWillBeLastPrice == nil) {
            if (role == .client) {
                varThatWillBeLastPrice = price
            } else {
                varThatWillBeLastPrice = realtor_price
            }
        }
        
        if varThatWillBeLastPrice == 0 {
            return nil
        }
        
        return varThatWillBeLastPrice
    }

    
}
