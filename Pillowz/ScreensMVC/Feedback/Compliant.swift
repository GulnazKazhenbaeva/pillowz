//
//  Compliant.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 22.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

enum HeaderType: Int {
    case wrong = 0
    case rude = 1
    case improvement = 2
    case other = 3

    static let allValues = [none, rude, improvement, other]
}

class Feedback: NSObject {
    var reasonType: String = ""
    var compliantDescription: String = ""
    var status: String = ""
    var time: String = ""
    var messageCount: String = ""
    
    init(reasonType: String, compliantDescription: String, status: String, time: String, messageCount: String) {
        self.reasonType = reasonType
        self.compliantDescription = compliantDescription
        self.status = status
        self.time = time
        self.messageCount = messageCount
    }
    
    class func getDisplayNameForHeaderType(headerType:HeaderType) -> [String:String] {
        var headerTypeDisplayName:[String:String]!
        
        switch (headerType) {
        case (.wrong):
            headerTypeDisplayName = ["ru":"Неверное объявление", "en":"Неверное объявление"]
        case (.rude):
            headerTypeDisplayName = ["ru":"Грубое обращение", "en":"Грубое обращение"]
        case (.improvement):
            headerTypeDisplayName = ["ru":"Предложение по улучшению", "en":"Предложение по улучшению"]
        case (.other):
            headerTypeDisplayName = ["ru":"Другое", "en":"Другое"]
        }

        return headerTypeDisplayName
    }
}
