//
//  APIErrorHandler.swift
//  Pillowz
//
//  Created by Samat on 10.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import MBProgressHUD


public typealias APIClosure = (_ response:AnyObject?, _ error: Error?) -> Void

extension NSObject {
    // new functionality to add to SomeType goes here
    class func checkForErrors(response:DataResponse<Any>, APIClosure:APIClosure) {
        print("URL - \(String(describing: response.response?.url?.absoluteString))")
        
        switch response.result {
        case .success(let value):
            let json = JSON(value)
            
            if (json["code"]==0) || response.response?.statusCode.description.first == "2" {//временный костыль для проверки статускода если в json не будет приходить поле code, в v2 все будет проверяться по статускоду, надо будет переписать логику запросов
                APIClosure(json as AnyObject, nil)
            } else if (json["code"]==100) {
                if (User.isLoggedIn()) {
                    User.logout()
                    
                    let infoView = ModalInfoView(titleText: "На Ваш аккаунт вошли с другого устройства", descriptionText: "Если это не Вы, срочно свяжитесь с нашей тех. поддержкой")
                    
                    infoView.addButtonWithTitle("ОК", action: {
                        
                    })
                    
                    infoView.show()
                }
                
                let error = NSError(domain: "", code: json["code"].intValue, userInfo: ["message":json["message"]])

                APIClosure(nil, error)
            } else {
                let error = NSError(domain: "", code: json["code"].intValue, userInfo: ["message":json["message"]])

                showErrorWithMessage(message: json["message"])
                
                APIClosure(nil, error)
            }
        case .failure(let error):
            print(error)
            
            if error.localizedDescription != "" {
                showErrorWithMessage(message: ["ru":error.localizedDescription, "en":error.localizedDescription])
            } else {
                showErrorWithMessage(message: ["ru":"Проверьте соединение с интернетом", "en":"Проверьте соединение с интернетом"])
            }
            
            APIClosure(nil, error)
        }
    }
    
    class func showErrorWithMessage(message:JSON) {
        let window = UIApplication.shared.delegate!.window!!

        let currentVC = UIApplication.topViewController()
        
        if (currentVC != nil) {
            MBProgressHUD.hide(for: currentVC!.view, animated: true)
            
            MBProgressHUD.hide(for: window, animated: true)
        }

        var alertMessage:String
        
        let stringMessage = message.string
        var dictMessage = message.dictionaryObject as? [String:String]

        if (dictMessage == nil) {
            dictMessage = ["ru":"Нет интернета или сервер не отвечает", "en":"Нет интернета или сервер не отвечает"]
        }
        
        if (stringMessage != nil) {
            alertMessage = stringMessage!
        } else {
            alertMessage = MultiLanguageResponseHandler.getStringFromDict(dict: dictMessage!)
        }

        DesignHelpers.makeToastWithText(alertMessage)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
