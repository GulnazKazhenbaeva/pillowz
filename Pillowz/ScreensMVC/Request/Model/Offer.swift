//
//  Offer.swift
//  Pillowz
//
//  Created by Samat on 09.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD

class Offer: NSObject {
    public var chat_room:String?
    public var id:Int?
    public var messages_count:Int?
    public var price_client:Int?
    public var price_realtor:Int?
    public var status : RequestStatus?
    public var space:Space?
    public var price_histories:[[String:Any]]?
    
    var client_viewed:Bool!
    var realtor_viewed:Bool!
    
    var request:Request!
    
    var otherUser:User {
        if (User.currentRole == .client) {
            return self.space!.realtor!.user
        } else {
            return request.otherUser
        }
    }
    
    var agreePrice:Int {
        if (User.currentRole == .client) {
            return self.price_realtor!
        } else {
            return self.price_client!
        }
    }
    
    var firstPrice:Int {
        var varThatWillBeFirstPrice:Int?
        
        if (price_histories != nil) {
            if (price_histories!.count > 0) {
                let iteration = price_histories!.first!
                
                if (User.currentRole == .client) {
                    varThatWillBeFirstPrice = iteration["price_client"] as? Int
                } else {
                    varThatWillBeFirstPrice = iteration["price_realtor"] as? Int
                }
            }
        }
        
        if (varThatWillBeFirstPrice == nil) {
            if (User.currentRole == .client) {
                varThatWillBeFirstPrice = price_client
            } else {
                varThatWillBeFirstPrice = price_realtor
            }
        }
        
        if (varThatWillBeFirstPrice == nil) {
            varThatWillBeFirstPrice = 0
        }
        
        return varThatWillBeFirstPrice!
    }

    convenience init(json:JSON) {
        self.init()
        
        self.messages_count = json["messages_count"].int
        self.chat_room = json["chat_room"].string
        self.price_client = json["price_client"].int
        self.price_realtor = json["price_realtor"].int
        self.id = json["id"].int
        self.space = Space(json:json["space"])
        self.status = RequestStatus(rawValue: json["status"].intValue)
        self.price_histories = json["price_histories"].arrayObject as? [[String : Any]]
        
        self.client_viewed = json["client_viewed"].boolValue
        self.realtor_viewed = json["realtor_viewed"].boolValue
    }
    
    class func parseOffersArray(json:[JSON]?) -> [Offer] {
        var offersArray:[Offer] = []
        
        if (json == nil) {
            return []
        }
        
        for offerJSON in json! {
            let offer = Offer(json: offerJSON)
            
            offersArray.append(offer)
        }
        
        return offersArray
    }
    
    
    func agreeTapped(completion:@escaping APIClosure) {
        var titleText:String = ""
        var descriptionText:String = ""
        var viewIdentifier:String = ""
        
        if (User.currentRole == .client) {
            titleText = "Вы уверены что хотите согласится на цену в " + String(self.price_realtor!) + " тенге за жилье " + self.space!.name + " от " + self.otherUser.name! + "?"
            descriptionText = "В случае согласия, заявка будет закрыта со статусом “Одобрена”, и Вам будет открыта контактная информация арендодателя. Созвонитесь или напишите в чат или на email арендодателю, чтобы обговорить дальнейшие Ваши действия."
            viewIdentifier = "agreeTapped" + "Offer" + "Client"
        } else {
            titleText = "Вы уверены что хотите согласится на цену в " + String(self.price_client!) + " тенге за жилье " + self.space!.name + " от " + self.otherUser.name! + "?"
            descriptionText = "В случае согласия, заявка будет закрыта со статусом “Одобрена”, и Вам будет открыта контактная информация клиента. Созвонитесь или напишите в чат или на email клиенту, чтобы обговорить дальнейшие Ваши действия."
            viewIdentifier = "agreeTapped" + "Offer" + "Realtor"
        }
        
        let window = UIApplication.shared.delegate!.window!!

        let infoView = ModalInfoView(titleText: titleText, descriptionText: descriptionText, viewIdentifier: viewIdentifier)
        
        infoView.addButtonWithTitle("Да", action: {
            var status:RequestStatus
            
            status = .COMPLETED
            
            MBProgressHUD.showAdded(to: window, animated: true)
            
            RequestAPIManager.updateOfferStatus(offer: self, status: status, completion: { (responseObject, error) in
                MBProgressHUD.hide(for: window, animated: true)
                
                completion(responseObject, error)
            })
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
            titleText = "Ваша цена отправлена Арендодателю"
            descriptionText = "Необходимо дождаться ответа от Арендодателя. Арендодатель может сразу согласиться на вашу цену и тогда заявка будет считаться одобренной или предложит свою новую цену. Если по исчерпании 5 шагов торга ни одна из сторон ни даст согласие, то предложение автоматически будет отклонено."
            viewIdentifier = "offerNewPriceTapped" + "Offer" + "Client"
        } else {
            titleText = "Ваша цена отправлена Клиенту"
            descriptionText = "Необходимо дождаться ответа от Клиента. Клиент может сразу согласиться на вашу цену и тогда заявка будет считаться одобренной или предложит свою новую цену. Если по исчерпании 5 шагов торга ни одна из сторон ни даст согласие, то заявка автоматически будет отклонена."
            viewIdentifier = "offerNewPriceTapped" + "Offer" + "Realtor"
        }
        
        let window = UIApplication.shared.delegate!.window!!

        let infoView = ModalInfoView(titleText: titleText, descriptionText: descriptionText, viewIdentifier: viewIdentifier)
        
        infoView.addButtonWithTitle("OK", action: {
            
        })
        
        MBProgressHUD.showAdded(to: window, animated: true)
        
        RequestAPIManager.updateOfferPrice(offer: self, price: newPrice, completion: { (responseObject, error) in
            infoView.show()

            MBProgressHUD.hide(for: window, animated: true)
            
            completion(responseObject, error)
        })
    }
    
    func rejectTapped(completion:@escaping APIClosure) {
        var titleText:String = ""
        var descriptionText:String = ""
        var viewIdentifier:String = ""
        
        if (User.currentRole == .client) {
            titleText = "Вы уверены что хотите отклонить предложение на жилье " + self.space!.name + "?"
            descriptionText = "Предложение будет отклонено, но вы можете и дальше получать и просматривать предложения от других арендодателей."
            viewIdentifier = "rejectTapped" + "Offer" + "Client"
        } else {
            titleText = "Вы уверены что хотите отклонить заявку на жилье " + self.space!.name + "?"
            descriptionText = "Предложение будет отменено, но клиент может и дальше получать и просматривать ваши предложения или предложения от других арендодателей."
            viewIdentifier = "rejectTapped" + "Offer" + "Realtor"
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
            
            RequestAPIManager.updateOfferStatus(offer: self, status: status, completion: { (responseObject, error) in
                MBProgressHUD.hide(for: window, animated: true)
                
                completion(responseObject, error)
            })
        })
        
        infoView.addButtonWithTitle("Нет", action: {
            
        })
        
        infoView.show()
    }
    
    
    func isWaitingForAnswer() -> Bool {
        return (User.currentRole == .client && (status == .CLIENT_OFFER || status == .CLIENT_OFFER_VIEWED)) || (User.currentRole == .realtor && (status == .REALTOR_OFFER || status == .REALTOR_OFFER_VIEWED || justSentAnOffer()))
    }
    
    func justSentAnOffer() -> Bool {
        return User.currentRole == .realtor && (status == .VIEWED || status == .NOT_VIEWED)
    }
    
    func isCompleted() -> Bool {
        return status == .COMPLETED || status == .COMPLETED_WITH_OTHER || status == .CLIENT_REJECTED || status == .REALTOR_REJECTED || status == .MAX_ITERATIONS_EXCEEDED || status == .REQUEST_TIMED_OUT
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
                varThatWillBeLastPrice = price_client
            } else {
                varThatWillBeLastPrice = price_realtor
            }
        }
        
        return varThatWillBeLastPrice
    }
}
