//
//  RequestUpdateFirebaseListener.swift
//  Pillowz
//
//  Created by Samat on 20.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MBProgressHUD

class RequestUpdateFirebaseListener: NSObject {
    static let shared = RequestUpdateFirebaseListener()
    var ref: DatabaseReference!
    
    var request:Request! {
        didSet {
            if !isConfiguredFirebase {
                configureFirebaseReference()
            }
        }
    }
    var requestId:Int? {
        didSet {
            if !isConfiguredFirebase {
                configureFirebaseReference()
            }
        }
    }

    var isConfiguredFirebase = false

    var isLoading = false

    var requestVC:RequestOrOfferViewController? {
        didSet {
            if requestVC == nil {
                isConfiguredFirebase = false
            }
        }
    }
    var offerVC:RequestOrOfferViewController?
    
    func configureFirebaseReference() {
        var currentRequestId:Int?
        
        if let nonNilRequestId = requestId {
            currentRequestId = nonNilRequestId
        } else if let nonNilRequestId = request?.request_id {
            currentRequestId = nonNilRequestId
        }
        
        if let currentRequestId = currentRequestId {
            isConfiguredFirebase = true
            
            ref = Database.database().reference().child("request_updates").child(String(currentRequestId))
        }
    }
    
    func getRequest() {
        if isLoading {
            return
        }
        
        var requestId = request?.request_id
        
        if (requestId == nil) {
            requestId = self.requestId
        }
        
        if (requestId == nil) {
            return
        }
        
        MBProgressHUD.showAdded(to: self.requestVC!.view, animated: true)
        
        isLoading = true
        
        RequestAPIManager.getSingleRequest(request_id: requestId!) { (requestObject, error) in
            self.isLoading = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                MBProgressHUD.hide(for: self.requestVC!.view, animated: true)
            }
            
            if (error == nil) {
                self.request = requestObject as? Request
                self.requestVC?.request = requestObject as? Request
                self.offerVC?.request = requestObject as? Request

                self.requestVC?.setupTopUI()
                self.offerVC?.setupTopUI()

                if (self.request!.offers != nil) {
                    var realtorOffers:[Offer] = []
                    
                    var completedOffer:Offer?
                    
                    for requestOffer in self.request!.offers! {
                        realtorOffers.append(requestOffer)
                        
                        if (requestOffer.status == .COMPLETED) {
                            completedOffer = requestOffer
                        }
                    }
                    
                    if (realtorOffers.count == 1 || completedOffer != nil) && self.offerVC
                     == nil {
                        let vc = RequestOrOfferViewController()
                        vc.request = self.request
                        
                        if (completedOffer != nil) {
                            vc.offer = completedOffer!
                        } else {
                            vc.offer = realtorOffers[0]
                        }
                        
                        vc.setupTopUI()
                        
                        self.requestVC?.navigationController?.pushViewController(vc, animated: false)
                    } 
                }
            } else {
                self.requestVC?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
