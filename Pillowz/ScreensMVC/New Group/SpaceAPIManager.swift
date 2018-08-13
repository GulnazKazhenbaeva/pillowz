//
//  SpaceAPIManager.swift
//  Pillowz
//
//  Created by Samat on 27.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class SpaceAPIManager:NSObject {
    static func getSpaces(completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["limit":"2", "page":"1"]

        Alamofire.request(Constants.baseAPIURL + "realtor/space/get_spaces/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        let spaces = Space.parseSpacesArray(json: json["spaces"].arrayValue, forMap: false)
                        
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion(spaces as AnyObject, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getSpacesForRequest(_ request_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["request_id":request_id.description]
        
        Alamofire.request(Constants.baseAPIURL + "realtor/requests/get_spaces_for_request/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        let spaces = Space.parseSpacesArray(json: json["spaces"].arrayValue, forMap: false)
                        
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion(spaces as AnyObject, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getSpaceCategories(completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        Alamofire.request(Constants.baseAPIURL + "realtor/space/get_categories/", method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        let categories:[SpaceCategory] = SpaceCategory.parseSpaceCategoriesArray(json: json["categories"].array!)

                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion(categories as AnyObject, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func createSpaceWithCategory(type: String, category:String, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]

        let parameters = ["category":category, "rent_type":type]
        
        Alamofire.request(Constants.baseAPIURL + "v2/spaces/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    //let space = Space(json: json["space"])
                    let space = Spaces(JSONString: json.rawString()!)
                    
                    completion(space as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    
    
//    static func createSpaceWithCategory(category:String, completion:@escaping APIClosure) {
//        let headers: HTTPHeaders = [
//            "auth-token": User.token,
//            ]
//
//        let parameters = ["category":category]
//
//        Alamofire.request(Constants.baseAPIURL + "realtor/space/create_space/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
//            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
//                if (error == nil) {
//                    let json = APIResponse as! JSON
//
//                    let space = Space(json: json["space"])
//
//                    completion(space as AnyObject, error)
//                } else {
//                    completion(nil, error)
//                }
//            })
//        }
//    }
    
    
    static func deleteSpace(space:Space, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = [
            "space_ids":space.space_id.stringValue,
            ]
        
        Alamofire.request(Constants.baseAPIURL + "realtor/space/delete_spaces/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    //let space = Space(json: json["space"])
                    
                    completion(json as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func createBooking(spaceId: Int, timestampStart: Int, timestampEnd: Int, rent_type:Int, price:Int, completion: @escaping APIClosure){
        let headers: HTTPHeaders = [
            "auth-token": User.token
        ]
        
        let params: [String: Any] = [
            "space_id": String(spaceId),
            "timestamp_start": String(timestampStart),
            "timestamp_end": String(timestampEnd),
            "rent_type": String(rent_type),
            "price": String(price),
        ]
        
        let url = Constants.baseAPIURL + "booking/create_book/"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let book = Book(json: json["booking"])

                    completion(book as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func deleteBooking(bookId: Int, completion: @escaping APIClosure){
        let headers: HTTPHeaders = [
            "auth-token": User.token
        ]
        
        let params: [String: Any] = [
            "book_id": bookId,
        ]
                
        let url = Constants.baseAPIURL + "booking/delete_book/"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    completion(json as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    static func uploadPhotos(images:[UIImage], toSpace space:Space, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["space_id":space.space_id.stringValue]

        let url = Constants.baseAPIURL + "realtor/space/upload_images/"
        
        Alamofire.upload(
        multipartFormData: { (multipartFormData) in
            for image in images {
                var editingImage = image
                
                if editingImage.cgImage == nil {
                    guard let ciImage = editingImage.ciImage, let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else { continue }
                    
                    editingImage = UIImage(cgImage: cgImage)
                }
                
                editingImage = editingImage.resizeImage(newWidth: 800)
                let imgData = NSData(data: UIImageJPEGRepresentation((editingImage), 1)!)
                let imageSize = Double(imgData.length) / 1024.0
                let compression: CGFloat = CGFloat(400.0/imageSize)
                print(imageSize, compression)
                multipartFormData.append(UIImageJPEGRepresentation(editingImage, compression)!, withName: "images", fileName: "image.jpeg", mimeType: "image/jpeg")
            }
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
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
                            
                            let images = Image.parseImagesArray(json: json["images"].array!)
                            space.images?.append(contentsOf: images)
                            completion(images as AnyObject, error)
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
    
    static func createSpace(space_id:Int, name:String, cancellation_policy:String, additional_charges:String, arrival_time:Int, checkout_time:Int, description:String, destination:String, infrastructure:String, lat:Double, lon:Double, address:String, prices:[Price], rules:Rule, fields:[Field], comforts:[ComfortItem], should_validate:Bool = false, additional_features:String, arrival_and_checkout:String, deposit:String, completion:@escaping APIClosure) {
        
        prices.forEach({$0.price = ($0.price == 0) ? nil : $0.price})
        
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let url = Constants.baseAPIURL + "realtor/space/save_full/"
        
        var debuggingArrayKeys:[String] = []
        var debuggingArrayValues:[String] = []
        
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                multipartFormData.append(String(space_id).data(using: String.Encoding.utf8)!, withName: "space_id")
                multipartFormData.append(name.data(using: String.Encoding.utf8)!, withName: "name")
                
                multipartFormData.append(cancellation_policy.data(using: String.Encoding.utf8)!, withName: "cancellation_policy")
                multipartFormData.append(additional_charges.data(using: String.Encoding.utf8)!, withName: "additional_charges")
                multipartFormData.append(String(arrival_time).data(using: String.Encoding.utf8)!, withName: "arrival_time")
                multipartFormData.append(String(checkout_time).data(using: String.Encoding.utf8)!, withName: "checkout_time")
                multipartFormData.append(description.data(using: String.Encoding.utf8)!, withName: "description")
                multipartFormData.append(destination.data(using: String.Encoding.utf8)!, withName: "destination")
                multipartFormData.append(infrastructure.data(using: String.Encoding.utf8)!, withName: "infrastructure")
                multipartFormData.append(additional_features.data(using: String.Encoding.utf8)!, withName: "additional_features")
                multipartFormData.append(arrival_and_checkout.data(using: String.Encoding.utf8)!, withName: "arrival_and_checkout")
                multipartFormData.append(deposit.data(using: String.Encoding.utf8)!, withName: "deposit")
                
                
                multipartFormData.append(address.data(using: String.Encoding.utf8)!, withName: "address")
                multipartFormData.append(String(lat).data(using: String.Encoding.utf8)!, withName: "lat")                
                multipartFormData.append(String(lon).data(using: String.Encoding.utf8)!, withName: "lon")
                
                multipartFormData.append(String(should_validate).data(using: String.Encoding.utf8)!, withName: "should_validate")

                debuggingArrayKeys.append("lat")
                debuggingArrayValues.append(String(describing: lat))
                debuggingArrayKeys.append("lon")
                debuggingArrayValues.append(String(describing: lon))
                
                
                for price in prices {
                    if (price.price != nil) {
                        multipartFormData.append(String(price.rent_type!.rawValue).data(using: String.Encoding.utf8)!, withName: "rent_types")
                        debuggingArrayKeys.append("rent_types")
                        debuggingArrayValues.append(String(describing: price.rent_type!.rawValue))
                        
                        multipartFormData.append(String(price.price!).data(using: String.Encoding.utf8)!, withName: "prices")
                        debuggingArrayKeys.append("prices")
                        debuggingArrayValues.append(String(describing: price))
                        
                        print("rent_types - \(price.price!)")
                        print("prices - \(price.rent_type!.rawValue)")
                    }
                }
                
                multipartFormData.append(rules.child.description.data(using: String.Encoding.utf8)!, withName: "child")
                multipartFormData.append(rules.additional_rule.data(using: String.Encoding.utf8)!, withName: "additional_rule")
                multipartFormData.append(rules.smoking.description.data(using: String.Encoding.utf8)!, withName: "smoking")
                multipartFormData.append(rules.pet.description.data(using: String.Encoding.utf8)!, withName: "pet")
                multipartFormData.append(rules.limited.description.data(using: String.Encoding.utf8)!, withName: "limited")
                multipartFormData.append(rules.party.description.data(using: String.Encoding.utf8)!, withName: "party")
                multipartFormData.append(rules.baby.description.data(using: String.Encoding.utf8)!, withName: "baby")
                
                
                for field in fields {
                    print("\(field.type!) - \(field.value) - \(field.param_name!)")

                    if (field.value != "" && field.type != "BooleanField") {
                        multipartFormData.append(String(describing: field.value).data(using: String.Encoding.utf8)!, withName: field.param_name!)
                    } else {
                        if (field.type! == "BooleanField" && field.value.toBool()) {
                            multipartFormData.append(true.description.data(using: String.Encoding.utf8)!, withName: field.param_name!)
                        } else {
                            multipartFormData.append(false.description.data(using: String.Encoding.utf8)!, withName: field.param_name!)
                        }
                    }
                    
                    if (field.type == "InlineField") {
                        if (field.first!.value != "") {
                            multipartFormData.append(field.first!.value.data(using: String.Encoding.utf8)!, withName: field.first!.param_name!)
                        }
                        if (field.second!.value != "") {
                            multipartFormData.append(field.second!.value.data(using: String.Encoding.utf8)!, withName: field.second!.param_name!)
                        }
                    }
                }
                
                for comfortItem in comforts {
                    let id = String(describing: comfortItem.comfort_item_id!)
                    let value = comfortItem.checked!.description
                    
                    multipartFormData.append(id.data(using: String.Encoding.utf8)!, withName: "comfort_item_ids")
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: "values")
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
                            let space = Space(json: json["space"])
                            
                            completion(space as AnyObject, error)
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
    
    static func getBookingForSpace(_ space_id:Int, timestamp_start:Int, timestamp_end:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = [
            "space_id":String(space_id),
            "timestamp_start":String(timestamp_start),
            "timestamp_end":String(timestamp_end),
            ]
        
        Alamofire.request(Constants.baseAPIURL + "booking/get_by_space/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let books = Book.parseBooksArray(json: json["bookings"].array!)
                    
                    completion(books as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getBookingForUser(_ user_id:Int, timestamp_start:Int, timestamp_end:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = [
            "user_id":String(user_id),
            "timestamp_start":String(timestamp_start),
            "timestamp_end":String(timestamp_end),
            ]
        
        Alamofire.request(Constants.baseAPIURL + "booking/get_by_user/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let books = Book.parseBooksArray(json: json["bookings"].array!)
                    
                    completion(books as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    
    static func getSpacesByIds(_ space_ids:[Int], completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let url = Constants.baseAPIURL + "client/space/get_by_ids/"
        
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                for space_id in space_ids {
                    multipartFormData.append(String(space_id).data(using: String.Encoding.utf8)!, withName: "space_ids")
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
                            let spaces = Space.parseSpacesArray(json: json["spaces"].arrayValue, forMap: false)
                            
                            completion(spaces as AnyObject, error)
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

    static func getRealtorSpaces(user_id:Int ,completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["user_id":String(user_id)]
        
        Alamofire.request(Constants.baseAPIURL + "client/space/get_realtor_spaces/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        let spaces = Space.parseSpacesArray(json: json["spaces"].arrayValue, forMap: false)
                        
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion(spaces as AnyObject, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    
    static func viewSpace(space_id:Int ,completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["space_id":String(space_id)]
        
        Alamofire.request(Constants.baseAPIURL + "client/space/view/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    //let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func saveImages(_ images:[Image], toSpace space:Space, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["space_id":space.space_id.stringValue]
        
        let url = Constants.baseAPIURL + "realtor/space/save_images/"
        
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                for image in images {
                    multipartFormData.append(String(image.image_id).data(using: String.Encoding.utf8)!, withName: "image_ids")
                }
                
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
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
                            
                            let images = Image.parseImagesArray(json: json["space"]["images"].array!)
                            space.images = images
                            completion(images as AnyObject, error)
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
    
    static func deleteSpaceImage(space_id:Int, image_id:Int, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let parameters = ["space_id":String(space_id), "image_ids":String(image_id)]
        
        Alamofire.request(Constants.baseAPIURL + "realtor/space/delete_images/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    //let json = APIResponse as! JSON
                    
                    // Move to a background thread to do some long running work
                    DispatchQueue.global(qos: .userInitiated).async {
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
}
