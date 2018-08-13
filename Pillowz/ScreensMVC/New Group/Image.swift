//
//  Image.swift
//  Pillowz
//
//  Created by Samat on 01.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Image: NSObject {
    public var image_id : Int!
    public var image : String!
    public var image_big : String!
    
    convenience init(json:JSON) {
        self.init()
        
        self.image_id = json["image_id"].intValue
        
        self.image = json["image"].stringValue
        self.image_big = json["image_big"].stringValue
    }
    
    class func parseImagesArray(json:[JSON]) -> [Image] {
        var imagesArray:[Image] = []
        
        for imageJSON in json {
            let image = Image(json: imageJSON)
            
            imagesArray.append(image)
        }
        
        return imagesArray
    }
}
