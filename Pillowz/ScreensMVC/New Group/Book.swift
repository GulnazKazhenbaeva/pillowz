//
//  Book.swift
//  Pillowz
//
//  Created by Samat on 21.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

class Book: NSObject {
    var book_id : Int!
    var timestamp_start : Int!
    var timestamp_end : Int!
    var space_id : Int!
    var rent_type : RENT_TYPES!
    var name: String!
    var request: Request!

    convenience init(json:JSON) {
        self.init()
        
        self.book_id = json["book_id"].intValue
        self.timestamp_start = json["timestamp_start"].intValue
        self.timestamp_end = json["timestamp_end"].intValue
        self.space_id = json["space_id"].intValue
        self.rent_type = RENT_TYPES(rawValue: json["rent_type"].intValue)
        self.name = json["name"].stringValue
        
        if (self.name == "") {
            self.name = "Название объекта отсутствует"
        }
        
        self.request = Request(json:json["request"])
    }
    
    class func parseBooksArray(json:[JSON]) -> [Book] {
        var bookArray:[Book] = []
        
        for bookJSON in json {
            let book = Book(json: bookJSON)
            
            bookArray.append(book)
        }
        
        return bookArray
    }
}
