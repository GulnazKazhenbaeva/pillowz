//
//  RequestFilter.swift
//  Pillowz
//
//  Created by Samat on 25.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

enum REQUEST_SORT_TYPES: Int {
    case FRESH = 0
    case PRICE = 1
    case SUITABLE = 2
    case FINISHING = 3
    case PRICE_DESC = 4
    
    static let allValues = [FRESH, PRICE, SUITABLE, FINISHING, PRICE_DESC]
}

class RequestFilter: NSObject, RequestSortingDelegate {
    static let shared = RequestFilter()
    
    var parameters:[Field] = []
    var headers:[String] = []
    
    var crudVM:CreateEditObjectTableViewGenerator?
    
    var sort_by:REQUEST_SORT_TYPES = .FRESH
    
    let sortField = Field()
    let suitableField = Field()
    let favouriteField = Field()
    let bargainField = Field()
    let priceInlineField = Field()
    
    //let fieldsForChoosingCategories = CategoriesHandler.getFieldsForChoosingCategories()
    var categoryField:Field!
    
    var chosenSpaceCategory:String?

    let roomsInlineField = Field()

    var needRoomsField = true
    
    override init() {
        super.init()
        
        sortField.type = "ChoiceField"
        sortField.param_name = "Сортировать по"
        sortField.multiLanguageName = ["ru": "Сначала новые", "en":"Сначала новые"]
        sortField.didSelectClosure = { () in
            let sortVC = SortingViewController()
            sortVC.requestSortingDelegate = self
            sortVC.isRequestSorting = true
            sortVC.chosenRequestSortType = self.sort_by
            self.crudVM?.viewController.navigationController?.pushViewController(sortVC, animated: true)
        }
        
        suitableField.param_name = "suitable"
        suitableField.multiLanguageName = ["ru":"Подходящие", "en":"Подходящие"]
        suitableField.type = "BooleanField"
        suitableField.didPickFieldValueClosure = { (newValue) in
            self.suitableField.value = String(describing: newValue)
            NotificationCenter.default.post(name: NSNotification.Name(Constants.changedRequestFilterValueNotification), object: nil)
        }

        favouriteField.param_name = "favourite"
        favouriteField.multiLanguageName = ["ru":"Избранные", "en":"Избранные"]
        favouriteField.type = "BooleanField"
        favouriteField.didPickFieldValueClosure = { (newValue) in
            self.favouriteField.value = String(describing: newValue)
            NotificationCenter.default.post(name: NSNotification.Name(Constants.changedRequestFilterValueNotification), object: nil)
        }

        bargainField.param_name = "bargain"
        bargainField.multiLanguageName = ["ru":"С торгом", "en":"С торгом"]
        bargainField.type = "BooleanField"
        bargainField.didPickFieldValueClosure = { (newValue) in
            self.bargainField.value = String(describing: newValue)
            NotificationCenter.default.post(name: NSNotification.Name(Constants.changedRequestFilterValueNotification), object: nil)
        }

        let minPriceField = Field()
        minPriceField.param_name = "price_start"
        minPriceField.type = "IntegerField"
        let maxPriceField = Field()
        maxPriceField.param_name = "price_end"
        maxPriceField.type = "IntegerField"
        
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
            NotificationCenter.default.post(name: NSNotification.Name(Constants.changedRequestFilterValueNotification), object: nil)
        }

        let minRoomsField = Field()
        minRoomsField.param_name = "rooms_min"
        minRoomsField.type = "IntegerField"
        let maxRoomsField = Field()
        maxRoomsField.param_name = "rooms_max"
        maxRoomsField.type = "IntegerField"
        
        roomsInlineField.param_name = "rooms"
        roomsInlineField.multiLanguageName = ["ru":"Количество комнат", "en":"Rooms"]
        roomsInlineField.type = "InlineField"
        roomsInlineField.first = minRoomsField
        roomsInlineField.second = maxRoomsField
        
        roomsInlineField.didPickRangeValueClosure = { (value1, value2) in
            if (value1 != nil) {
                self.roomsInlineField.first!.value = String(describing:value1!)
            } else {
                self.roomsInlineField.first!.value = ""
            }
            if (value2 != nil) {
                self.roomsInlineField.second!.value = String(describing:value2!)
            } else {
                self.roomsInlineField.second!.value = ""
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(Constants.changedRequestFilterValueNotification), object: nil)
        }

        //getParameters()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadedCategories), name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
        
        if (CategoriesHandler.sharedInstance.categories.count != 0) {
            getParameters()
        }
    }
    
    @objc func loadedCategories() {
        getParameters()
    }
    
    func checkIfNeedRoomsField() {
        if (chosenSpaceCategory == nil) {
            needRoomsField = false
            return
        }
        
        for category in CategoriesHandler.sharedInstance.categories {
            if (category.value! == chosenSpaceCategory!) {
                for field in category.search_fields! {
                    if (field.type == "InlineField") {
                        if (field.first!.param_name == "rooms_count_min") {
                            needRoomsField = true
                            return
                        }
                    }
                }
            }
        }
        
        needRoomsField = false
    }
    
    func getParameters() {
        parameters = []
        headers = []
        
        if (categoryField == nil) {
            var choices:[Choice] = []
            
            for category in CategoriesHandler.sharedInstance.categories {
                let choice = Choice()
                choice.value = String(category.value!)
                choice.multiLanguageName = category.multiLanguageName
                choices.append(choice)
            }
            
            categoryField = Field()
            categoryField.choices = choices
            categoryField.param_name = "category"
            categoryField.multiLanguageName = ["ru":"Тип жилья", "en":"Тип жилья"]
            categoryField.type = "ChoiceField"
            categoryField.didPickFieldValueClosure = { (newValue) in
                let choice = newValue as! Choice
                
                self.chosenSpaceCategory = choice.value!
                
                self.getParameters()
                
                NotificationCenter.default.post(name: NSNotification.Name(Constants.changedRequestFilterValueNotification), object: nil)
            }
        }
        
        parameters.append(sortField)
        headers.append("Сортировать по")
        
        parameters.append(categoryField)
        headers.append("Варианты размещения")
        
        parameters.append(suitableField)
        headers.append("Фильтровать")

        parameters.append(favouriteField)
        headers.append("")
        
        parameters.append(bargainField)
        headers.append("")
        
        parameters.append(priceInlineField)
        headers.append("Цена, тенге")
        
        checkIfNeedRoomsField()
        
        if (needRoomsField) {
            parameters.append(roomsInlineField)
            headers.append("Количество комнат")
        }
        
        reloadCRUDVMData()
    }
    
    func reloadCRUDVMData() {
        crudVM?.headers = self.headers
        crudVM?.object = self.parameters as AnyObject
    }
    
    func didFinishSorting(sortingType: REQUEST_SORT_TYPES) {
        NotificationCenter.default.post(name: NSNotification.Name(Constants.changedRequestFilterValueNotification), object: nil)

        self.sort_by = sortingType
        
        sortField.setCustomText(text: SortingViewController.getDisplayNameForRequestSortType(sort_type: self.sort_by)["ru"]!)
    }
}
