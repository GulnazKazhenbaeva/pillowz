//
//  RegistrationViewController.swift
//  Pillowz
//
//  Created by Samat on 29.11.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegistrationViewController: PillowzViewController {
    static let shared = RegistrationViewController()
    var socialNetworkInfo:[String:String]?
    var socialType:SocialNetworkLinks?
    var accessToken:String?
    
    var edittedPhoneNumberWithoutCode:String?
    
    var haveSocialNetwork: Bool = false
    var hasPhone: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForSocialNetworkData()
    }
    
    func checkForSocialNetworkData() {
        if RegistrationViewController.shared.socialNetworkInfo != nil {
            self.haveSocialNetwork = true
            if RegistrationViewController.shared.socialNetworkInfo!["phone"] != "" {
                edittedPhoneNumberWithoutCode = RegistrationViewController.shared.socialNetworkInfo!["phone"]!
                
                if edittedPhoneNumberWithoutCode!.count > 2 {
                    edittedPhoneNumberWithoutCode = String(edittedPhoneNumberWithoutCode!.dropFirst(2))
                }
                self.hasPhone = true
            } else {
                self.hasPhone = false
            }
        } else {
            self.haveSocialNetwork = false
        }
    }
}
