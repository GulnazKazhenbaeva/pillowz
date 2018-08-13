//
//  SearchAPIManager.swift
//  Pillowz
//
//  Created by Samat on 06.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchAPIManager: NSObject {
    static func searchSpaces(filter:Filter, limit:Int, page:Int, polygonString:String?, favourite:Bool, only_count:Bool, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let url = Constants.baseAPIURL + "client/search/"
        
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                var debuggingArrayKeys:[String] = []
                var debuggingArrayValues:[String] = []
                
                if (favourite) {
                    multipartFormData.append(favourite.description.data(using: String.Encoding.utf8)!, withName: "favourite")
                    debuggingArrayKeys.append("favourite")
                    debuggingArrayValues.append(favourite.description)
                } else {
                    multipartFormData.append(String(filter.sort_by.rawValue).data(using: String.Encoding.utf8)!, withName: "sort_by")
                    debuggingArrayKeys.append("sort_by")
                    debuggingArrayValues.append(String(filter.sort_by.rawValue))
                    
                    let isSortingByDistance = filter.sort_by == .SORT_DISTANCE_ASC || filter.sort_by == .SORT_DISTANCE_DESC
                    
                    if (!isSortingByDistance && UserLastUsedValuesForFieldAutofillingHandler.shared.lat != 0) {
                        let lat = String(format: "%.6f", UserLastUsedValuesForFieldAutofillingHandler.shared.lat)
                        let lon = String(format: "%.6f", UserLastUsedValuesForFieldAutofillingHandler.shared.lon)
                        multipartFormData.append(lat.data(using: String.Encoding.utf8)!, withName: "my_lat")
                        multipartFormData.append(lon.data(using: String.Encoding.utf8)!, withName: "my_lon")

                        debuggingArrayKeys.append("my_lat")
                        debuggingArrayValues.append(lat)
                        debuggingArrayKeys.append("my_lon")
                        debuggingArrayValues.append(lon)

                    } else if (LocationManager.shared.currentLocation != nil && isSortingByDistance) {
                        let lat = String(format: "%.6f", LocationManager.shared.currentLocation!.latitude)
                        let lon = String(format: "%.6f", LocationManager.shared.currentLocation!.longitude)
                        multipartFormData.append(lat.data(using: String.Encoding.utf8)!, withName: "my_lat")
                        multipartFormData.append(lon.data(using: String.Encoding.utf8)!, withName: "my_lon")

                        debuggingArrayKeys.append("my_lat")
                        debuggingArrayValues.append(lat)
                        debuggingArrayKeys.append("my_lon")
                        debuggingArrayValues.append(lon)
                    }
                    
                    if (only_count) {
                        multipartFormData.append(only_count.description.data(using: String.Encoding.utf8)!, withName: "only_count")
                        debuggingArrayKeys.append("only_count")
                        debuggingArrayValues.append(only_count.description)
                    }
                    
                    if (filter.only_owner) {
                        multipartFormData.append(0.description.data(using: String.Encoding.utf8)!, withName: "r_types")
                        debuggingArrayKeys.append("r_types")
                        debuggingArrayValues.append(filter.only_owner.description)
                    }
                    
                    if (filter.include != "") {
                        multipartFormData.append(filter.include.data(using: String.Encoding.utf8)!, withName: "include")
                        debuggingArrayKeys.append("include")
                        debuggingArrayValues.append(filter.include)
                    }
                    
                    if (filter.exclude != "") {
                        multipartFormData.append(filter.exclude.data(using: String.Encoding.utf8)!, withName: "exclude")
                        debuggingArrayKeys.append("exclude")
                        debuggingArrayValues.append(filter.exclude)
                    }
                    
                    if (polygonString != nil) {
                        multipartFormData.append(polygonString!.data(using: String.Encoding.utf8)!, withName: "polygon")
                        debuggingArrayKeys.append("polygon")
                        debuggingArrayValues.append(polygonString!)
                    }
                    
//                    if (UserLastUsedValuesForFieldAutofillingHandler.shared.address != "") {
//                        multipartFormData.append(UserLastUsedValuesForFieldAutofillingHandler.shared.address.data(using: String.Encoding.utf8)!, withName: "address")
//                        debuggingArrayKeys.append("address")
//                        debuggingArrayValues.append(UserLastUsedValuesForFieldAutofillingHandler.shared.address)
//                    }
                    
                    for category in Filter.shared.chosenSpaceCategories {
                        multipartFormData.append(category.data(using: String.Encoding.utf8)!, withName: "categories")
                        debuggingArrayKeys.append("categories")
                        debuggingArrayValues.append(category)
                    }
                    
                    for comfortItem in filter.comforts {
                        let id = String(describing: comfortItem.comfort_item_id)

                        if (comfortItem.checked != nil) {
                            if (comfortItem.checked!) {
                                multipartFormData.append(id.data(using: String.Encoding.utf8)!, withName: "comfort_item_ids")
                                debuggingArrayKeys.append("comfort_item_ids")
                                debuggingArrayValues.append(id)
                            }
                        }
                    }
                    
                    for field in filter.rules {
                        if (field.value == true.description) {
                            multipartFormData.append(String(describing: field.value).data(using: String.Encoding.utf8)!, withName: field.param_name!)
                            debuggingArrayKeys.append(field.param_name!)
                            debuggingArrayValues.append(String(describing: field.value))
                        }
                    }
                    
                    if (filter.priceInlineField.first?.value != "") {
                        multipartFormData.append(filter.priceInlineField.first!.value.data(using: String.Encoding.utf8)!, withName: filter.priceInlineField.first!.param_name!)
                        debuggingArrayKeys.append(filter.priceInlineField.first!.param_name!)
                        debuggingArrayValues.append(filter.priceInlineField.first!.value)
                    }
                    
                    if (filter.priceInlineField.second?.value != "") {
                        multipartFormData.append(filter.priceInlineField.second!.value.data(using: String.Encoding.utf8)!, withName: filter.priceInlineField.second!.param_name!)
                        debuggingArrayKeys.append(filter.priceInlineField.second!.param_name!)
                        debuggingArrayValues.append(filter.priceInlineField.second!.value)
                    }

                    
                    
                    multipartFormData.append(UserLastUsedValuesForFieldAutofillingHandler.shared.rentType.rawValue.description.data(using: String.Encoding.utf8)!, withName: "rent_type")
                    debuggingArrayKeys.append("rent_type")
                    debuggingArrayValues.append(UserLastUsedValuesForFieldAutofillingHandler.shared.rentType.rawValue.description)
                    
                    if filter.startTime != nil {
                        multipartFormData.append(filter.startTime!.description.data(using: String.Encoding.utf8)!, withName: "timestamp_start")
                        debuggingArrayKeys.append("timestamp_start")
                        debuggingArrayValues.append(filter.startTime!.description)
                    }
                    
                    if filter.endTime != nil {
                        multipartFormData.append(filter.endTime!.description.data(using: String.Encoding.utf8)!, withName: "timestamp_end")
                        debuggingArrayKeys.append("timestamp_end")
                        debuggingArrayValues.append(filter.endTime!.description)
                    }
                    
                    for field in filter.allCategoryFields {
                        if (field.type != "InlineField") {
                            if (field.value != "" && field.value != "0") {
                                multipartFormData.append(String(describing: field.value).data(using: String.Encoding.utf8)!, withName: field.param_name!)
                                debuggingArrayKeys.append(field.param_name!)
                                debuggingArrayValues.append(String(describing: field.value))
                            }
                            
                            if (field.selectedChoice != nil) {
                                multipartFormData.append(String(describing: field.selectedChoice!.value!).data(using: String.Encoding.utf8)!, withName: field.param_name!)
                                debuggingArrayKeys.append(field.param_name!)
                                debuggingArrayValues.append(String(describing: field.selectedChoice!.value!))
                            }
                        } else {
                            if (field.first!.value != "") {
                                multipartFormData.append(field.first!.value.data(using: String.Encoding.utf8)!, withName: field.first!.param_name!)
                                debuggingArrayKeys.append(field.first!.param_name!)
                                debuggingArrayValues.append(field.first!.value)
                            }
                            
                            if (field.second!.value != "") {
                                multipartFormData.append(field.second!.value.data(using: String.Encoding.utf8)!, withName: field.second!.param_name!)
                                debuggingArrayKeys.append(field.second!.param_name!)
                                debuggingArrayValues.append(field.second!.value)
                            }
                        }
                    }
                }
                
                multipartFormData.append(String(limit).data(using: String.Encoding.utf8)!, withName: "limit")
                debuggingArrayKeys.append("limit")
                debuggingArrayValues.append(String(limit))

                multipartFormData.append(String(page).data(using: String.Encoding.utf8)!, withName: "page")
                debuggingArrayKeys.append("page")
                debuggingArrayValues.append(String(page))

                for i in 0..<debuggingArrayKeys.count {
                    print("FILTER VALUE \(debuggingArrayKeys[i]) - \(debuggingArrayValues[i])")
                }
        },
            to:url,
            method: .post,
            headers:headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    //print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                        if (error == nil) {
                            let json = APIResponse as! JSON
                            
                            if (!only_count) {
                                // Move to a background thread to do some long running work
                                DispatchQueue.global(qos: .userInitiated).async {
                                    var spaces:[Space]
                                    
                                    if (polygonString != nil) {
                                        spaces = Space.parseSpacesArray(json: json["spaces"].arrayValue, forMap: true)
                                    } else {
                                        spaces = Space.parseSpacesArray(json: json["spaces"].arrayValue, forMap: false)
                                    }
                                    
                                    let num_pages = json["num_pages"].intValue
                                    
                                    // Bounce back to the main thread to update the UI
                                    DispatchQueue.main.async {
                                        completion([spaces, num_pages] as AnyObject, nil)
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
            
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
        
    static func markSpace(space:Space, asFavorite favorite:Bool, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = [
            "space_id":space.space_id.stringValue,
            "value":favorite.description,
            ]
        
        Alamofire.request(Constants.baseAPIURL + "client/mark_favourite/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let space = Space(json: json["space"])
                    
                    completion(space as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
}
