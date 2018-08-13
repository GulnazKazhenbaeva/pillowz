//
//  Chat.swift
//  Pillowz
//
//  Created by Samat on 08.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON


class Chat: NSObject {
    var last_message:Message!
    var user1:User!
    var user2:User!
    var new_messages:Int!
    var timestamp:Int!
    var chat_id:String!
    var info:String!

    var otherUser:User {
        var otherUser:User
        
        if (self.user1.user_id == User.shared.user_id) {
            otherUser = self.user2
        } else {
            otherUser = self.user1
        }

        return otherUser
    }
    
    convenience init(json:JSON) {
        self.init()
        
        self.chat_id = json["chat_id"].stringValue
        self.last_message = Message(json: json["last_message"])
        self.user1 = User(json: json["user1"])
        self.user2 = User(json: json["user2"])
        self.new_messages = json["new_messages"].intValue
        self.timestamp = json["timestamp"].intValue
        self.info = json["info"].stringValue
    }

    
    class func parseChatsArray(json:[JSON]?) -> [Chat] {
        var chatsArray:[Chat] = []
        
        if json == nil {
            return []
        }
        
        for chatJSON in json! {
            let chat = Chat(json: chatJSON)
            
            chatsArray.append(chat)
        }
        
        return chatsArray
    }

}
