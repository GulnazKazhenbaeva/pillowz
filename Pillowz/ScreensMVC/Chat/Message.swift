//
//  Message.swift
//  Pillowz
//
//  Created by Samat on 10.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

class Message: NSObject {
    var text:String?
    var me:Bool?
    var chat_id:Int? // this is actually message id
    var user:User?
    var timestamp:Int!

    convenience init(json:JSON) {
        self.init()
        
        self.text = json["text"].string
        self.me = json["me"].bool
        self.chat_id = json["chat_id"].int
        self.user = User(forMessages: json["user"])
        self.timestamp = json["timestamp"].intValue
    }
    
    class func parseMessagesArray(json:[JSON]?) -> [Message] {
        var messagesArray:[Message] = []
        
        if json == nil {
            return []
        }
 
        for messageJSON in json! {
            let message = Message(json: messageJSON)
            
            messagesArray.append(message)
        }
        
        return messagesArray
    }
}
