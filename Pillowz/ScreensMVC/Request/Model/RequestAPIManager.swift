//
//  RequestAPIManager.swift
//  Pillowz
//
//  Created by Samat on 09.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RequestAPIManager: NSObject {
    static func createRequest(completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        Alamofire.request(Constants.baseAPIURL + "client/requests/create/", method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["result"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getClientRequests(limit:Int, page:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = [
            "limit":String(limit),
            "page":String(page),
        ]
        
        Alamofire.request(Constants.baseAPIURL + "client/requests/get/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        let requests = Request.parseRequestsArray(json: json["requests"].array!)
                        
                        let num_pages = json["num_pages"].intValue

                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion([requests, num_pages] as AnyObject, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getSingleRequest(request_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["request_id":String(request_id)]
        
        var clientOrRealtorURL = "client/requests/get/single/"
        if (User.currentRole == .realtor) {
            clientOrRealtorURL = "realtor/requests/single/"
        }
        
        Alamofire.request(Constants.baseAPIURL + clientOrRealtorURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        let request = Request(json: json["request"])
                        
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion(request as AnyObject, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func deleteRequest(request_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["request_id":String(request_id)]
        
        Alamofire.request(Constants.baseAPIURL + "client/delete_request/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["result"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    static func createPersonalRequestForSpaceId(spaceId:Int, price:Int, bargain:String, startTime:Int, endTime:Int, rentType:Int, guests_count:[String:Int], completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["space_id":String(spaceId), "price":String(price), "bargain":bargain, "start_time":String(startTime), "end_time":String(endTime), "rent_type":String(rentType), "guests_count":guests_count.json]
        
        Alamofire.request(Constants.baseAPIURL + "client/requests/personal/create/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["request"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    static func createOfferForRequestId(requestId:Int, prices:[Int], spaceIds:[Int], completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let url = Constants.baseAPIURL + "realtor/requests/create_offer/"
        
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                multipartFormData.append(String(requestId).data(using: String.Encoding.utf8)!, withName: "request_id")
                
                for price in prices {
                    let priceString = String(price)
                    
                    multipartFormData.append(priceString.data(using: String.Encoding.utf8)!, withName: "prices")
                }
                
                for spaceId in spaceIds {
                    let spaceIdString = String(spaceId)
                    
                    multipartFormData.append(spaceIdString.data(using: String.Encoding.utf8)!, withName: "space_ids")
                }
        },
            to:url,
            method: .post,
            headers:headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    
                })
                
                upload.responseJSON { response in
                    checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                        if (error == nil) {
                            let json = APIResponse as! JSON
                            
                            let request = Request(json: json["request"])
                            
                            completion(request as AnyObject, error)
                        } else {
                            completion(nil, error)
                        }
                    })
                }
            case .failure(let encodingError):
                completion(nil, encodingError)
            }
        }
    }
    
    static func getRealtorRequests(limit:Int, page:Int, my:Bool, sort_by:String, requestFilter:RequestFilter, only_count:Bool, completion:@escaping APIClosure) {
        var  headers: HTTPHeaders = [:]
        
        if (User.shared.user_id != nil) {
            headers = [
                "auth-token": User.token,
                ]
        }
        
        var parameters = ["limit":String(limit),
                          "page":String(page),
                          "my":my.description,
                          "sort_by":sort_by,
                          "only_count":only_count.description,
        ]
//
        if (requestFilter.chosenSpaceCategory != nil) {
            parameters["category"] = requestFilter.chosenSpaceCategory!
        }

        for field in requestFilter.parameters {
            if (field.type != "InlineField") {
                if (field.value != "") {
                    parameters[field.param_name!] = String(describing: field.value)
                }
            } else {
                if (field.first!.value != "") {
                    parameters[field.first!.param_name!] = String(describing: field.first!.value)
                }
                if (field.second!.value != "") {
                    parameters[field.second!.param_name!] = String(describing: field.second!.value)
                }
            }
        }
        
        for parameter in parameters {
            print("REQUEST FILTER VALUE - \(parameter.value) FOR KEY - \(parameter.key)")
        }
        
        Alamofire.request(Constants.baseAPIURL + "realtor/requests/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    if (!only_count) {
                        // Move to a background thread to do some long running work
                        DispatchQueue.global(qos: .userInitiated).async {
                            let requests = Request.parseRequestsArray(json: json["requests"].array!)
                            
                            let num_pages = json["num_pages"].intValue

                            // Bounce back to the main thread to update the UI
                            DispatchQueue.main.async {
                                completion([requests, num_pages] as AnyObject, error)
                            }
                        }
                    } else {
                        let count = json["count"].intValue
                        
                        completion(count as AnyObject, nil)
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    
    
    static func updateOfferPrice(offer:Offer, price:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        var clientOrRealtorString = "client"
        if (User.currentRole == .realtor) {
            clientOrRealtorString = "realtor"
        }

        let parameters = ["offer_id":String(offer.id!), "new_price":String(price)]
        
        Alamofire.request(Constants.baseAPIURL + clientOrRealtorString + "/requests/update_offer_price/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["request"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func updatePersonalRequestPrice(request:Request, price:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["request_id":String(request.request_id!), "new_price":String(price)]
        
        var clientOrRealtorString = "client"
        if (User.currentRole == .realtor) {
            clientOrRealtorString = "realtor"
        }
        
        Alamofire.request(Constants.baseAPIURL + clientOrRealtorString + "/requests/personal/update_price/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["request"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func updatePersonalRequestStatus(request:Request, status:RequestStatus, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["request_id":String(request.request_id!), "new_status":String(status.rawValue)]
        
        var clientOrRealtorURL = "client"
        if (User.currentRole == .realtor) {
            clientOrRealtorURL = "realtor"
        }
        
        Alamofire.request(Constants.baseAPIURL + clientOrRealtorURL + "/requests/personal/update_status/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["request"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func updateOfferStatus(offer:Offer, status:RequestStatus, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["offer_id":String(offer.id!), "new_status":String(status.rawValue)]
        
        var clientOrRealtorURL = "client"
        if (User.currentRole == .realtor) {
            clientOrRealtorURL = "realtor"
        }
        
        Alamofire.request(Constants.baseAPIURL + clientOrRealtorURL + "/requests/update_offer_status/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["request"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    
    static func createRequest(address:String, lat:Double, lon:Double, start_time:Int?, end_time:Int?, rent_type:RENT_TYPES, price:Int, bargain:Bool, rules:Rule, fields:[Field], category:String, comforts:[ComfortItem], urgent:Bool, photo:Bool, owner:Bool, guests_count:[String:Int], completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let url = Constants.baseAPIURL + "client/requests/create/"
        
        var debuggingArrayKeys:[String] = []
        var debuggingArrayValues:[String] = []

        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                multipartFormData.append(guests_count.json.data(using: String.Encoding.utf8)!, withName: "guests_count")

                multipartFormData.append(address.data(using: String.Encoding.utf8)!, withName: "address")
                multipartFormData.append(String(lat).data(using: String.Encoding.utf8)!, withName: "lat")
                multipartFormData.append(String(lon).data(using: String.Encoding.utf8)!, withName: "lon")
                
                debuggingArrayKeys.append("address")
                debuggingArrayValues.append(address)
                debuggingArrayKeys.append("lat")
                debuggingArrayValues.append(String(describing: lat))
                debuggingArrayKeys.append("lon")
                debuggingArrayValues.append(String(describing: lon))

                var start_time_any = false
                var end_time_any = false
                
                if (start_time==nil) {
                    start_time_any = true
                } else {
                    multipartFormData.append(String(start_time!).data(using: String.Encoding.utf8)!, withName: "start_time")
                    
                    debuggingArrayKeys.append("start_time")
                    debuggingArrayValues.append(String(describing: start_time!))

                }
                if (end_time==nil) {
                    end_time_any = true
                } else {
                    multipartFormData.append(String(end_time!).data(using: String.Encoding.utf8)!, withName: "end_time")
                    
                    debuggingArrayKeys.append("end_time")
                    debuggingArrayValues.append(String(describing: end_time!))
                }
                multipartFormData.append(start_time_any.description.data(using: String.Encoding.utf8)!, withName: "start_time_any")
                debuggingArrayKeys.append("start_time_any")
                debuggingArrayValues.append(String(describing: start_time_any))

                multipartFormData.append(end_time_any.description.data(using: String.Encoding.utf8)!, withName: "end_time_any")
                debuggingArrayKeys.append("end_time_any")
                debuggingArrayValues.append(String(describing: end_time_any))

                multipartFormData.append(String(rent_type.rawValue).data(using: String.Encoding.utf8)!, withName: "rent_type")
                debuggingArrayKeys.append("rent_type")
                debuggingArrayValues.append(String(describing: rent_type))
                
                multipartFormData.append(String(price).data(using: String.Encoding.utf8)!, withName: "price")
                debuggingArrayKeys.append("price")
                debuggingArrayValues.append(String(describing: price))

                multipartFormData.append(bargain.description.data(using: String.Encoding.utf8)!, withName: "bargain")
                debuggingArrayKeys.append("bargain")
                debuggingArrayValues.append(String(describing: bargain))


                multipartFormData.append(rules.child.description.data(using: String.Encoding.utf8)!, withName: "child")
                multipartFormData.append(rules.additional_rule.data(using: String.Encoding.utf8)!, withName: "additional_rule")
                multipartFormData.append(rules.smoking.description.data(using: String.Encoding.utf8)!, withName: "smoking")
                multipartFormData.append(rules.pet.description.data(using: String.Encoding.utf8)!, withName: "pet")
                multipartFormData.append(rules.limited.description.data(using: String.Encoding.utf8)!, withName: "limited")
                multipartFormData.append(rules.party.description.data(using: String.Encoding.utf8)!, withName: "party")
                multipartFormData.append(rules.baby.description.data(using: String.Encoding.utf8)!, withName: "baby")
                                
                multipartFormData.append(category.data(using: String.Encoding.utf8)!, withName: "category")
                debuggingArrayKeys.append("category")
                debuggingArrayValues.append(String(describing: category))

                for field in fields {
                    if (field.value != "") {
                        multipartFormData.append(String(describing: field.value).data(using: String.Encoding.utf8)!, withName: field.param_name!)
                        
                        debuggingArrayKeys.append(field.param_name!)
                        debuggingArrayValues.append(String(describing: field.value))
                    }
                }
                
                for comfortItem in comforts {
                    let id = String(describing: comfortItem.comfort_item_id)
                    let value = comfortItem.checked!.description
                    
                    multipartFormData.append(id.data(using: String.Encoding.utf8)!, withName: "comfort_item_ids")
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: "values")
                    
                    debuggingArrayKeys.append("comfort_item_ids")
                    debuggingArrayValues.append(String(describing: id))
                    debuggingArrayKeys.append("values")
                    debuggingArrayValues.append(String(describing: value))
                }
                
                multipartFormData.append(urgent.description.data(using: String.Encoding.utf8)!, withName: "urgent")
                multipartFormData.append(photo.description.data(using: String.Encoding.utf8)!, withName: "photo")
                multipartFormData.append(owner.description.data(using: String.Encoding.utf8)!, withName: "owner")
                
                debuggingArrayKeys.append("urgent")
                debuggingArrayValues.append(String(describing: urgent))
                debuggingArrayKeys.append("photo")
                debuggingArrayValues.append(String(describing: photo))
                debuggingArrayKeys.append("owner")
                debuggingArrayValues.append(String(describing: owner))
                
                for i in 0..<debuggingArrayKeys.count {
                    print("REQUEST VALUE \(debuggingArrayKeys[i]) - \(debuggingArrayValues[i])")
                }

        },
            to:url,
            method: .post,
            headers:headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    
                })
                
                upload.responseJSON { response in
                    checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                        if (error == nil) {
                            let json = APIResponse as! JSON
                            let request = Request(json: json["request"])
                            
                            completion(request as AnyObject, error)
                        } else {
                            completion(nil, error)
                        }
                    })
                }
            case .failure(let encodingError):
                completion(nil, encodingError)
            }
            
        }
    }

    static func hideRequest(_ request_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["request_id":String(request_id)]
        
        var clientOrRealtorURL = "client"
        if (User.currentRole == .realtor) {
            clientOrRealtorURL = "realtor"
        }
        
        Alamofire.request(Constants.baseAPIURL + clientOrRealtorURL + "/requests/hide/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["request"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func deleteRequest(_ request_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["request_id":String(request_id)]
        
        Alamofire.request(Constants.baseAPIURL + "client/requests/delete/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["request"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func setRequestFavourite(_ favourite:Bool, request_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["request_id":String(request_id), "value":favourite.description]
        
        Alamofire.request(Constants.baseAPIURL + "realtor/requests/favourite/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    let request = Request(json: json["request"])
                    
                    completion(request as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func viewOffer(_ offer_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["offer_id":String(offer_id)]
        
        Alamofire.request(Constants.baseAPIURL + "client/requests/view_offer/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    //let request = Request(json: json["request"])
                    
                    completion(json as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
}

extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func dict2json() -> String {
        return json
    }
}
