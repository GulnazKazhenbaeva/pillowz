//
//  SpaceEditorManager.swift
//  Pillowz
//
//  Created by Samat on 06.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class SpaceEditorManager: NSObject {
    static let sharedInstance = SpaceEditorManager()

    var spaceCRUDVC:NewSpaceCRUDViewController?
    var currentStepVC:StepViewController?
    
    var getCurrentPageInContinuing:Int {
        var allFieldsAreEmpty = true
        
        for field in spaceFields {
            print("\(field.type!) - \(field.value) - \(field.param_name!)")
            
            let isWrongFieldType = field.type == "HeaderField" || field.type == "ChoiceField" || field.type == "BooleanField"
            
            if  !isWrongFieldType && field.value != "" && field.value != "1" && field.value != "0" {
                allFieldsAreEmpty = false
            }
        }
        
        if allFieldsAreEmpty {
            return 0
        }
        
        var allComfortsAreEmpty = true
        
        for comfort in self.comforts {
            if comfort.checked! {
                allComfortsAreEmpty = false
            }
        }
        
        if allComfortsAreEmpty {
            return 1
        }
        
        var allRulesAreEmpty = true
        
        let rulesFields = CategoriesHandler.getFieldsOfObject(object: self.rules, shouldControlObject: true).0 as [Field]
        
        for rulesField in rulesFields {
            if rulesField.value != "" {
                allRulesAreEmpty = false
            }
        }
        
        if allRulesAreEmpty {
            return 2
        }
        
        
        
        if self.lat == 0 && self.lon == 0 {
            return 3
        }
        
        
        //////////
        var allPricesAreEmpty = true

        for price in SpaceEditorManager.sharedInstance.currentEditingSpace.prices! {
            if (price.price != nil) {
                allPricesAreEmpty = false
            }
        }
        
        if allPricesAreEmpty {
            return 4
        }

        //////////
        var photosAreEmpty = false
        
        if SpaceEditorManager.sharedInstance.currentEditingSpace.images!.count < 4 {
            photosAreEmpty = true
        }
        
        if photosAreEmpty {
            return 5
        }
        //////
        
        var descriptionsAreEmpty = false
        
        if spaceDescription == "" || name == "" {
            descriptionsAreEmpty = true
        }
        
        if descriptionsAreEmpty {
            return 6
        }

        
        return 0
    }
    
    //needed because when passing link and updating from server - link gets overwritten, and one controller has new object, but previous controller has old object
    var currentEditingSpace:Space! {
        didSet {
            self.name = currentEditingSpace.name
            self.spaceDescription = currentEditingSpace.spaceDescription
            self.infrastructure = currentEditingSpace.infrastructure
            self.lat = currentEditingSpace.lat.doubleValue
            self.lon = currentEditingSpace.lon.doubleValue
            self.cancellation_policy = currentEditingSpace.cancellation_policy
            self.additional_charges = currentEditingSpace.additional_charges
            self.additional_features = currentEditingSpace.additional_features
            self.address = currentEditingSpace.address
            self.destination = currentEditingSpace.destination
            self.arrival_and_checkout = currentEditingSpace.arrival_and_checkout
            self.deposit = currentEditingSpace.deposit
            self.rules = currentEditingSpace.rule!
            self.comforts = currentEditingSpace.comforts!
            self.arrival_time = currentEditingSpace.arrival_time
            self.checkout_time = currentEditingSpace.checkout_time

            if self.arrival_time == 0 && self.checkout_time == 0 {
                self.arrival_time = 14
                self.checkout_time = 12
            }
        }
    }
    
    var name:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var cancellation_policy:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var arrival_and_checkout:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var deposit:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var additional_charges:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var additional_features:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var spaceDescription:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var destination:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var infrastructure:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var lat:Double = 0 {
        didSet {
            colorNextButton()
        }
    }
    var lon:Double = 0 {
        didSet {
            colorNextButton()
        }
    }
    var address:String = "" {
        didSet {
            colorNextButton()
        }
    }
    var arrival_time:Int = 14 {
        didSet {
            colorNextButton()
        }
    }
    var checkout_time:Int = 12 {
        didSet {
            colorNextButton()
        }
    }
    var spaceFields:[Field]! {
        didSet {
            colorNextButton()
        }
    }
    var comforts:[ComfortItem]! {
        didSet {
            colorNextButton()
        }
    }
    var rules:Rule! {
        didSet {
            colorNextButton()
        }
    }
    
    func colorNextButton() {
        if let filled = SpaceEditorManager.sharedInstance.currentStepVC?.checkIfAllFieldsAreFilled() {
            if filled {
                spaceCRUDVC?.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
            } else {
                spaceCRUDVC?.nextButton.backgroundColor = Constants.paletteLightGrayColor
            }
        } else {
            spaceCRUDVC?.nextButton.backgroundColor = Constants.paletteLightGrayColor
        }
    }
}
