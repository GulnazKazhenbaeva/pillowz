//
//  ChatAPIManager.swift
//  Pillowz
//
//  Created by Samat on 10.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChatAPIManager: NSObject {
    static func getMessages(room:String, lastId:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["room":room, "last_id":String(lastId)]
        
        Alamofire.request(Constants.baseAPIURL + "chat/get_messages/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        let messages = Message.parseMessagesArray(json: json["messages"].array)

                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion(messages as AnyObject, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func sendMessage(room:String, text:String, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["room":room, "text":text]
        
        Alamofire.request(Constants.baseAPIURL + "chat/send_message/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let message = Message(json: json["message"])
                    
                    completion(message as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    static func getChats(timestamp:Int, limit:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        //let parameters = ["timestamp":timestamp, "limit":limit]
        
        Alamofire.request(Constants.baseAPIURL + "chat/get_chats/", method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        let chats = Chat.parseChatsArray(json: json["chats"].array)

                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion(chats as AnyObject, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    
    
}
