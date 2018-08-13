//
//  Certificate.swift
//  Pillowz
//
//  Created by Samat on 15.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

@objcMembers class Certificate: NSObject {
    var certificate_id:Int?
    var certificate_url:String?
    
    convenience init(json:JSON) {
        self.init()
        
        certificate_id = json["certificate_id"].int
        certificate_url = json["certificate_url"].string
    }
    
    class func parseCertificatesArray(json:[JSON]?) -> [Certificate] {
        var certificatesArray:[Certificate] = []
        
        if (json == nil) {
            return []
        }
        
        for certificateJSON in json! {
            let certificate = Certificate(json: certificateJSON)
            
            certificatesArray.append(certificate)
        }
        
        return certificatesArray
    }
}
