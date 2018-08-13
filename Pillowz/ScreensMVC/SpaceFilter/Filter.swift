//
//  Filter.swift
//  Pillowz
//
//  Created by Samat on 06.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SwiftyJSON

class Filter: NSObject, AddressPickerDelegate, DateAndTimePickerViewControllerDelegate {
    static let shared = Filter()
    
    var chosenSpaceCategories:[String] = []

    let ruleObject = Rule()
    var rules:[Field] = []
    var comforts:[ComfortItem] = []
    var fields:[AnyObject] = []
    var allCategoryFields:[Field] = []
    var crudVM:CreateEditObjectTableViewGenerator? {
        didSet {
            reloadCRUDVMData()
        }
    }
    var sort_by:SPACE_SORT_TYPES = .SORT_DATE_DESC
    
    var startTime:Int? {
        didSet {
            UserLastUsedValuesForFieldAutofillingHandler.shared.startTime = startTime
        }
    }
    var endTime:Int? {
        didSet {
            UserLastUsedValuesForFieldAutofillingHandler.shared.endTime = endTime
        }
    }
    
    var isShowingFullList = false {
        didSet {
            getFields()
        }
    }
    
    var headers:[String] = []
    
    var fieldsForChoosingCategories = CategoriesHandler.getFieldsForChoosingCategories()
    //var addressField:Field!
    var rentTypeField:Field!
    var priceInlineField:Field!
    let periodField = Field()
    
    let includeField = Field()
    let excludeField = Field()

    var include:String = ""
    var exclude:String = ""
    var only_owner:Bool = false
    
    override init() {
        super.init()
        
        initFields()

        self.rules = CategoriesHandler.getFieldsOfObject(object: ruleObject, shouldControlObject: true).0
        self.rules.removeLast() //removed additional rules field because it's string
        self.comforts = []
        
        self.startTime = UserLastUsedValuesForFieldAutofillingHandler.shared.startTime
        self.endTime = UserLastUsedValuesForFieldAutofillingHandler.shared.endTime
        
        if (fields.count == 0 && CategoriesHandler.sharedInstance.categories.count != 0) {
            fieldsForChoosingCategories = CategoriesHandler.getFieldsForChoosingCategories()
            setupCategoryFields()

            getFields()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadedCategories), name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
    }
    
    func initFields() {
        if (priceInlineField == nil) {
            let minPriceField = Field()
            minPriceField.param_name = "price_min"
            minPriceField.type = "IntegerField"
            let maxPriceField = Field()
            maxPriceField.param_name = "price_max"
            maxPriceField.type = "IntegerField"
            
            priceInlineField = Field()
            priceInlineField.param_name = "price"
            priceInlineField.multiLanguageName = ["ru":"Цена", "en":"Price"]
            priceInlineField.type = "InlineField"
            priceInlineField.first = minPriceField
            priceInlineField.second = maxPriceField
            
            priceInlineField.didPickRangeValueClosure = { (value1, value2) in
                if (value1 != nil) {
                    self.priceInlineField.first!.value = String(describing:value1!)
                } else {
                    self.priceInlineField.first!.value = ""
                }
                if (value2 != nil) {
                    self.priceInlineField.second!.value = String(describing:value2!)
                } else {
                    self.priceInlineField.second!.value = ""
                }
                NotificationCenter.default.post(name: NSNotification.Name(Constants.changedFilterValueNotification), object: nil)
            }
        }
                
        includeField.param_name = "include"
        includeField.multiLanguageName = ["ru": "например, школа, детский сад", "en":"например, школа, детский сад"]
        includeField.value = self.include
        includeField.didPickFieldValueClosure = { (newValue) in
            self.include = newValue as! String
            self.includeField.value = newValue as! String
            NotificationCenter.default.post(name: NSNotification.Name(Constants.changedFilterValueNotification), object: nil)
        }
        includeField.type = "CharField"
        
        excludeField.param_name = "exclude"
        excludeField.multiLanguageName = ["ru": "например, вокзал, рынок", "en":"например, вокзал, рынок"]
        excludeField.value = self.exclude
        excludeField.didPickFieldValueClosure = { (newValue) in
            self.exclude = newValue as! String
            self.excludeField.value = newValue as! String
            NotificationCenter.default.post(name: NSNotification.Name(Constants.changedFilterValueNotification), object: nil)
        }
        excludeField.type = "CharField"
    }
    
    @objc func loadedCategories() {
        fieldsForChoosingCategories = CategoriesHandler.getFieldsForChoosingCategories()
        setupCategoryFields()
        
        getFields()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
    }
    
    func clearFilter() {
        NotificationCenter.default.post(name: NSNotification.Name(Constants.changedFilterValueNotification), object: nil)

        for object in fields {
            if (object is Field) {
                let field = object as! Field
                
                if (field.type == "BooleanField") {
                    field.value = false.description
                } else if (field.type == "IntegerField") {
                    field.value = "0"
                } else {
                    field.value = ""
                }
            } else if (object is ComfortItem) {
                let comfortItem = object as! ComfortItem
                comfortItem.checked = false
            }
        }
    }
    
    func filterIsEmpty() -> Bool {
        for object in fields {
            if (object is Field) {
                let field = object as! Field
                
                if (field.type == "BooleanField") {
                    if field.value == true.description {
                        return false
                    }
                } else if (field.type == "IntegerField") {
                    if field.value != "0" {
                        return false
                    }
                } else {
                    if field.value != "" {
                        return false
                    }
                }
            } else if (object is ComfortItem) {
                let comfortItem = object as! ComfortItem
                
                if (comfortItem.checked == true) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func didPickAddress(address: String, lat: Double, lon: Double) {
        UserLastUsedValuesForFieldAutofillingHandler.shared.address = address
        UserLastUsedValuesForFieldAutofillingHandler.shared.lat = lat
        UserLastUsedValuesForFieldAutofillingHandler.shared.lon = lon
        NotificationCenter.default.post(name: NSNotification.Name(Constants.changedFilterValueNotification), object: nil)
    }
    
    func didPickStartDate(_ startDate: Date, endDate: Date?) {
        startTime = Int(startDate.timeIntervalSince1970)
        
        if (UserLastUsedValuesForFieldAutofillingHandler.shared.rentType == .HALFDAY) {
            endTime = Int(startDate.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0)).timeIntervalSince1970)
        } else if (UserLastUsedValuesForFieldAutofillingHandler.shared.rentType == .MONTHLY) {
            endTime = Int(startDate.add(.init(seconds: 0, minutes: 0, hours:0, days: 0, weeks: 0, months: 1, years: 0)).timeIntervalSince1970)
        }

        if let endDate = endDate {
            endTime = Int(endDate.timeIntervalSince1970)
        }
    }
    
    func setupCategoryFields() {
        for categoryField in fieldsForChoosingCategories {
            if let _ = self.chosenSpaceCategories.index(of: categoryField.param_name!) {
                categoryField.value = true.description
            }
            
            categoryField.didPickFieldValueClosure = { (newValue) in
                let value = newValue as! Bool
                
                categoryField.value = value.description
                
                if (value) {
                    self.chosenSpaceCategories.append(categoryField.param_name!)
                    UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory = categoryField.param_name!
                } else {
                    if let index = self.chosenSpaceCategories.index(of: categoryField.param_name!) {
                        self.chosenSpaceCategories.remove(at: index)
                    }
                }

                self.allCategoryFields = CategoriesHandler.getFieldsForChosenCategories(chosenSpaceCategories: self.chosenSpaceCategories, fieldType: .search)

                self.getFields()
                
                NotificationCenter.default.post(name: NSNotification.Name(Constants.changedFilterValueNotification), object: nil)
            }
        }
    }
    
    func getFields() {
        self.comforts = CategoriesHandler.getComfortsForCategories(categories: self.chosenSpaceCategories)

        fields = []
        headers = []
                
        fields.append(contentsOf: fieldsForChoosingCategories as [AnyObject])
        headers.append("Тип жилья")
        
        if (fieldsForChoosingCategories.count != 0) {
            for _ in 0..<fieldsForChoosingCategories.count - 1 {
                headers.append("")
            }
        }
        
        fields.append(priceInlineField)
        headers.append("Цена")
        
        for field in allCategoryFields {
            if field.first?.param_name == "rooms_count_min" {
                fields.append(field)
                headers.append("Количество комнат")
                
                break
            }
        }
        
        fields.append(includeField)
        headers.append("Наличие слов в описании")
        
//        fields.append(excludeField)
//        headers.append("Исключить слова в описании")
        
        if (isShowingFullList) {
            fields.append(contentsOf: self.allCategoryFields as [AnyObject])
            
            for i in 0..<allCategoryFields.count {
                let field = allCategoryFields[i]
                
                if (!field.shouldAddHeader()) {
                    headers.append("")
                } else {
                    headers.append(field.name!)
                }
            }

            headers.append("Удобства")
            for _ in 0..<comforts.count-1 {
                headers.append("")
            }
            
            for comfort in comforts {
                fields.append(comfort)
            }

            headers.append("Правила дома")
            for _ in 0..<rules.count-1 {
                headers.append("")
            }

            for rule in rules {
                fields.append(rule)
            }
        }
        
        reloadCRUDVMData()
    }
    
    func reloadCRUDVMData() {
        //FOR TESTING
//        for object in self.fields {
//            if let field = object as? Field {
//                if (field.name != nil) {
//                    print(field.name)
//                }
//
//                if (field.type != nil) {
//                    print(field.type)
//                }
//            }
//        }

        crudVM?.headers = self.headers
        crudVM?.hasSaveAction = true
        crudVM?.hasExpandAction = true
        crudVM?.object = self.fields as AnyObject
    }
}
