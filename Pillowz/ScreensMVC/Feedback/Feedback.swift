//
//  Compliant.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 22.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

enum HeaderType: Int {
    case INVALID_ADDRESS = 0
    case ROUGH_TREATMENT = 1
    case IMPROVEMENT_OFFER = 2
    case OTHER = 3
    case NOT_OWNER = 4

    static let allValues = [INVALID_ADDRESS, ROUGH_TREATMENT, IMPROVEMENT_OFFER, OTHER, NOT_OWNER]
}

enum FeedbackStatus: Int {
    case OPEN = 0
    case ANSWERED = 1
    case CLOSED = 2
    
    static let allValues = [OPEN, ANSWERED, CLOSED]
}


class Feedback: NSObject {
    var author:User!
    var contact_number:String!
    var feedback_id:Int!
    var header:HeaderType!
    var message:String!
    var offer_id:Int?
    var request_id:Int?
    var room:String!
    var space_id:Int?
    var status:FeedbackStatus!
    var time:Int!
    var user_id:Int?
    var messages_count:Int!

    convenience init(json:JSON) {
        self.init()
        
        self.author = User(json: json["author"])
        self.contact_number = json["contact_number"].stringValue
        self.feedback_id = json["feedback_id"].intValue
        self.header = HeaderType(rawValue: json["header"].intValue)!
        self.message = json["message"].stringValue
        self.offer_id = json["offer_id"].int
        self.request_id = json["request_id"].int
        self.space_id = json["space_id"].int
        self.room = json["room"].stringValue
        self.status = FeedbackStatus(rawValue: json["status"].intValue)!
        self.time = json["time"].intValue
        self.user_id = json["user_id"].int
        self.messages_count = json["messages_count"].intValue
    }
    
    class func parseFeedbackArray(json:[JSON]) -> [Feedback] {
        var feedbackArray:[Feedback] = []
        
        for feedbackJSON in json {
            let feedback = Feedback(json: feedbackJSON)
            
            feedbackArray.append(feedback)
        }
        
        return feedbackArray
    }
    
    class func getDisplayNameForHeaderType(headerType:HeaderType) -> [String:String] {
        var headerTypeDisplayName:[String:String]!
        
        switch (headerType) {
        case (.INVALID_ADDRESS):
            headerTypeDisplayName = ["ru":"Жилье недостоверное", "en":"Жилье недостоверное"]
        case (.ROUGH_TREATMENT):
            headerTypeDisplayName = ["ru":"Грубое обращение", "en":"Грубое обращение"]
        case (.IMPROVEMENT_OFFER):
            headerTypeDisplayName = ["ru":"Предложение по улучшению", "en":"Предложение по улучшению"]
        case (.OTHER):
            headerTypeDisplayName = ["ru":"Другое", "en":"Другое"]
        case (.NOT_OWNER):
            headerTypeDisplayName = ["ru":"Посредник", "en":"Посредник"]
        }

        return headerTypeDisplayName
    }
}
