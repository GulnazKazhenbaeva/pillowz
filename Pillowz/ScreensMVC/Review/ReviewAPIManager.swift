//
//  ReviewAPIManager.swift
//  Pillowz
//
//  Created by Samat on 15.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class ReviewAPIManager: NSObject {
    static func leaveSpaceReview(_ text:String, value:Int, space_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["text":text, "value":String(value), "space_id":String(space_id), "price":String(value), "infrastructure":String(value), "cleanness":String(value), "service":String(value)]
        
        Alamofire.request(Constants.baseAPIURL + "client/leave_space_review/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    //                let space = Space(json: json["space"])
                    //
                    completion(json as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func leaveUserReview(_ text:String, value:Int, user_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["text":text, "value":String(value), "user_id":String(user_id)]
        
        Alamofire.request(Constants.baseAPIURL + "client/leave_user_review/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    //                let space = Space(json: json["space"])
                    //
                    completion(json as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

}
