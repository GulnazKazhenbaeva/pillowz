//
//  Review.swift
//  Pillowz
//
//  Created by Samat on 21.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

class Review: NSObject {
    var user:User?
    var text:String?
    var value:Int?
    var timestamp:Int?
    
    convenience init(json:JSON) {
        self.init()
        
        self.user = User(forReview:json["author"])
        self.text = json["text"].string
        self.value = json["value"].int
        self.timestamp = json["timestamp"].int
    }
    
    class func parseReviewsArray(json:[JSON]?) -> [Review] {
        var reviewsArray:[Review] = []
        
        if (json == nil) {
            return []
        }
        
        for reviewJSON in json! {
            let review = Review(json: reviewJSON)
            
            reviewsArray.append(review)
        }
        
        return reviewsArray
    }
}
