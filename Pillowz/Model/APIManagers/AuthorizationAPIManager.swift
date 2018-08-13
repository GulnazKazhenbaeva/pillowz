//
//  AuthorizationAPIManager.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/25/17.
//  Copyright © 2017 Samat. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

enum SocialNetworkLinks: String {
    case facebook = "auth/facebook_login/"
    case google = "auth/google_login/"
    case instagram = "auth/insta_login/"
    case vkontakte = "auth/vk_login/"
}

class AuthorizationAPIManager:NSObject {
    private static let baseAuthURL: String = Constants.baseAPIURL + "auth/"
    
    private static let signInLink: String = baseAuthURL + "signin/"
    private static let signUpLink: String = baseAuthURL + "signup/"
    private static let signUpWithSocialNetworkLink: String = baseAuthURL + "signup/social/"
    private static let completeSignUpLink: String = baseAuthURL + "signup_complete/"
    private static let uploadCertificateLink: String = baseAuthURL + "signup_upload_certificate/"
    private static let resetPasswordLink: String = baseAuthURL + "reset_password/"
    private static let completeResetPasswordLink: String = baseAuthURL + "reset_password_complete/"
    
    private static let changePhoneLink: String = baseAuthURL + "change_phone/"
    private static let completeChangePhoneLink: String = baseAuthURL + "change_phone_complete/"
    
    static func signIn(username: String, password: String, completion: @escaping APIClosure){
        let params: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        Alamofire.request(signInLink, method: .post, parameters: params).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                        User.saveUserJsonString(jsonString: jsonString)
                    }
                    
                    completion(User.shared as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    static func signUp(as realtor:Realtor?, username:String, name:String, password:String, country:String, withSocialNetwork: Bool, completion:@escaping APIClosure) {
        var link:String = signUpLink
        
        if (RegistrationViewController.shared.socialNetworkInfo != nil && withSocialNetwork) {
            link = signUpWithSocialNetworkLink
        }
        
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                if (realtor != nil) {
                    multipartFormData.append(String(realtor!.rtype!.rawValue).data(using: String.Encoding.utf8)!, withName: "rtype")
                    multipartFormData.append(realtor!.business_name!.data(using: String.Encoding.utf8)!, withName: "business_name")
                    multipartFormData.append(realtor!.contact_number!.data(using: String.Encoding.utf8)!, withName: "contact_number")
                    multipartFormData.append(realtor!.address!.data(using: String.Encoding.utf8)!, withName: "address")
                    multipartFormData.append(realtor!.business_id!.data(using: String.Encoding.utf8)!, withName: "business_id")
                    multipartFormData.append(realtor!.person_id!.data(using: String.Encoding.utf8)!, withName: "person_id")
//                    multipartFormData.append(realtor!.certificate!.data(using: String.Encoding.utf8)!, withName: "certificate_id")
                }
                
                if withSocialNetwork {
                    multipartFormData.append(username.data(using: String.Encoding.utf8)!, withName: "phone")
                } 
                
                multipartFormData.append(username.data(using: String.Encoding.utf8)!, withName: "username")
                
                if !RegistrationViewController.shared.hasPhone && withSocialNetwork {
                    multipartFormData.append("phone".data(using: String.Encoding.utf8)!, withName: "verify")
                }
                
                multipartFormData.append(name.data(using: String.Encoding.utf8)!, withName: "name")
                multipartFormData.append(country.data(using: String.Encoding.utf8)!, withName: "country")
                multipartFormData.append(password.data(using: String.Encoding.utf8)!, withName: "password")
                
                if (RegistrationViewController.shared.socialNetworkInfo != nil && withSocialNetwork) {
                    let accessToken = RegistrationViewController.shared.accessToken!
                    
                    multipartFormData.append(accessToken.data(using: String.Encoding.utf8)!, withName: "access_token")
                    
                    let socialNetwork = SocialNetworksHandler.getSocialNetworkName(RegistrationViewController.shared.socialType!)
                    
                    multipartFormData.append(socialNetwork.data(using: String.Encoding.utf8)!, withName: "social_type")
                }
        },
            to:link,
            method: .post,
            headers:nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in

                })
                
                upload.responseJSON { response in
                    checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                        if (error == nil) {
                            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                                User.saveUserJsonString(jsonString: jsonString)
                            }
                            
                            completion(User.shared as AnyObject, nil)
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
    
    static func codeConfirmation(mode: CodeConfirmationMode, phone: String, code: String, completion: @escaping APIClosure) {
        let link = (mode == .signUp) ? completeSignUpLink : completeResetPasswordLink
        //(mode == .signUp) ? print("Sign up code confirmation") : print("Reset password code confirmation")
        
        let params = [
            "username": phone,
            "phone": phone,
            "code": code
        ]
        
        Alamofire.request(link, method: .post, parameters: params).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                        User.saveUserJsonString(jsonString: jsonString)
                    }
                    
                    completion(User.shared as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getCertificateId(certificates: [UIImage], completion: @escaping APIClosure) {
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                for certificate in certificates {
                    multipartFormData.append(UIImageJPEGRepresentation(certificate, 1)!, withName: "certificate", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
        },
            to: uploadCertificateLink,
            method: .post,
            headers: nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    
                })
                upload.responseJSON { response in
                    self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                        if (error == nil) {
                            let json = APIResponse as! JSON
                            
                            let certificateObjects = Certificate.parseCertificatesArray(json: json["certificates"].array)
                            
                            completion(certificateObjects as AnyObject, error)
                        } else {
                            completion(nil, error)
                        }
                    })
                }
            case .failure(let encodingError):
                print(encodingError)
                completion(nil, encodingError)
                return
            }
        }
    }

    static func resetPassword(phone: String, newPassword: String, completion: @escaping APIClosure){
        let params: [String: Any] = [
            "phone": phone,
            "new_password": newPassword
        ]
        
        Alamofire.request(resetPasswordLink, method: .post, parameters: params).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                completion(APIResponse, error)
            })
        }
    }
    
    static func completeResetPassword(phone: String, code: String, completion: @escaping(Bool) -> Void) {
        let params: [String: Any] = [
            "phone": phone,
            "code": code
        ]
        
        Alamofire.request(completeResetPasswordLink, method: .post, parameters: params).validate().responseJSON { (response) in
            var isValid: Bool = false
            
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                isValid = true
            })
            
            completion(isValid)
        }
    }

    static func signUpViaSocialNetwork(_ socialNetwork: SocialNetworkLinks, token: String, completion: @escaping APIClosure){
        
        let params: [String: Any] = [
            "access_token": token
        ]
        
        Alamofire.request(Constants.baseAPIURL + socialNetwork.rawValue, method: .post, parameters: params).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let exists = json["exists"].boolValue
                    
                    if (exists) {
                        if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                            User.saveUserJsonString(jsonString: jsonString)
                        }
                        
                        completion(User.shared as AnyObject, nil)//exists)
                    } else {
                        let email = json["email"].stringValue
                        let phone = json["phone"].stringValue
                        let fullName = json["full_name"].stringValue
                        
                        let socialNetworkInfo = ["email":email, "phone":phone, "fullName":fullName]
                        
                        completion(socialNetworkInfo as AnyObject, error)
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func updateClientProfile(profileFields: [Field], completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]

        var params: [String: Any] = [:]
        
        for field in profileFields {
            params[field.param_name!] = field.value
        }
        
        Alamofire.request(Constants.baseAPIURL + "client/update_profile/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                        User.saveUserJsonString(jsonString: jsonString)
                    }
                    
                    completion(User.shared as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    static func updateRealtorProfile(profileFields: [Field], completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]

        var params: [String: Any] = [:]
        
        for field in profileFields {
            params[field.param_name!] = field.value
        }
        
        Alamofire.request(Constants.baseAPIURL + "realtor/update_profile/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                        User.saveUserJsonString(jsonString: jsonString)
                    }
                    
                    completion(User.shared as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    
    static func updateLanguages(languages:[Language], completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let url = Constants.baseAPIURL + "client/update_languages/"
        
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                for language in languages {
                    let id = String(describing: language.language_id!)
                    
                    multipartFormData.append(id.data(using: String.Encoding.utf8)!, withName: "language_ids")
                }
        },
            to:url,
            method: .post,
            headers:headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                        if (error == nil) {
                            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                                User.saveUserJsonString(jsonString: jsonString)
                            }
                            
                            completion(User.shared as AnyObject, error)
                        } else {
                            completion(nil, error)
                        }
                    })
                }
            case .failure(let encodingError):
                print(encodingError)
                completion(nil, encodingError)
            }
        }
    }

    
    static func uploadAvatar(image:UIImage, completion:@escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let url = Constants.baseAPIURL + "client/upload_avatar/"
        
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                multipartFormData.append(UIImageJPEGRepresentation(image.rotateImage(), 0.5)!, withName: "avatar", fileName: "image.jpeg", mimeType: "image/jpeg")
        },
            to:url,
            method: .post,
            headers:headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                        if (error == nil) {
                            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                                User.saveUserJsonString(jsonString: jsonString)
                            }
                            
                            completion(User.shared as AnyObject, error)
                        } else {
                            completion(nil, error)
                        }
                    })
                }
            case .failure(let encodingError):
                print(encodingError)
                completion(nil, encodingError)
            }
        }
    }
    
    static func createFeedback(header:Int, message:String, contact_number:String, space_id:Int?, request_id:Int?, offer_id:Int?, user_id:Int?, completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        var params: [String: Any] = ["header":header, "message":message, "contact_number":contact_number]
        
        if let space_id = space_id {
            params["space_id"] = String(space_id)
        }
        
        if let request_id = request_id {
            params["request_id"] = String(request_id)
        }
        
        if let offer_id = offer_id {
            params["offer_id"] = String(offer_id)
        }
        
        if let user_id = user_id {
            params["user_id"] = String(user_id)
        }
        
        Alamofire.request(Constants.baseAPIURL + "client/feedback/create/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
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
    
    static func getFeedback(completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        Alamofire.request(Constants.baseAPIURL + "client/feedback/", method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let feedbackArray = Feedback.parseFeedbackArray(json: json["feedbacks"].arrayValue)

                    completion(feedbackArray as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    
    
    
    
    static func changePassword(current_password:String, new_password:String, completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let params: [String: Any] = ["current_password":current_password, "new_password":new_password]
        
        Alamofire.request(Constants.baseAPIURL + "auth/change_password/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON

                    let feedbackArray = Feedback.parseFeedbackArray
                    
                    completion(json as AnyObject, nil)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getUserInfo(user_id:Int, completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let params: [String: Any] = ["user_id":String(user_id)]
        
        Alamofire.request(Constants.baseAPIURL + "client/user_info/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let user = User(json: json["user"])
                    
                    completion(user, nil)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func setRealtorSilent(_ isFree:Bool, completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let params: [String: Any] = ["silent_mode":isFree.description]
        
        Alamofire.request(Constants.baseAPIURL + "realtor/silent_mode/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let user = User(json: json["user"])
                    
                    completion(user, nil)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    
    static func setRealtorIsFree(_ isFree:Bool, completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let busy = !isFree
        
        let params: [String: Any] = ["busy":busy.description]
        
        Alamofire.request(Constants.baseAPIURL + "realtor/set_busy/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let user = User(json: json["user"])
                    
                    completion(user, nil)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func updatePushPlayerId(_ playerId: String, completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        let params: [String: Any] = ["player_id":playerId]

        Alamofire.request(Constants.baseAPIURL + "client/update_player_id/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    
                    completion(nil, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    static func getNotifications(completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        Alamofire.request(Constants.baseAPIURL + "client/notifications/", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    let json = APIResponse as! JSON
                    
                    let notifications = PillowzNotification.parseNotificationsArray(json: json["notifications"].arrayValue)
                    
                    completion(notifications as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    
    static func getClientInfo(completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        Alamofire.request(Constants.baseAPIURL + "client/info/", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                        User.saveUserJsonString(jsonString: jsonString)
                    }
                    
                    completion(User.shared as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    
    static func logout(completion: @escaping APIClosure) {
        let headers: HTTPHeaders = [
            "auth-token": User.token,
            ]
        
        Alamofire.request(Constants.baseAPIURL + "auth/logout/", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            self.checkForErrors(response: response, APIClosure: { (APIResponse, error) in
                if (error == nil) {
                    completion(nil, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
}
