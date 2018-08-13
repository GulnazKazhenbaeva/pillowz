//
//  HelpersAPIManager.swift
//  Pillowz
//
//  Created by Samat on 13.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HelpersAPIManager: NSObject {
    static func getCategories(completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        Alamofire.request(Constants.baseAPIURL + "helper/categories_and_comforts/", method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let jsonCategories = json["categories"]
                    let jsonComforts = json["comforts"]
                    
                    let categories = SpaceCategory.parseSpaceCategoriesArray(json: jsonCategories.array)
                    let comforts = ComfortItem.parseComfortItemsArray(json: jsonComforts.array)
                    
                    completion([categories, comforts] as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getCountries(completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let params: [String: Any] = [:]
        
        Alamofire.request(Constants.baseAPIURL + "auth/countries/", method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let countries = Country.parseCountriesArray(json: json["countries"].array)
                    
                    completion(countries as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getLanguages(completion: @escaping APIClosure) {
        Alamofire.request(Constants.baseAPIURL + "client/get_all_languages/", method: .post, parameters: nil).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let languages = Language.parseLanguagesArray(json: json["languages"].array!)
                    
                    completion(languages as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
}
