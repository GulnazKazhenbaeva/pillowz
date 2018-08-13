//
//  CategoriesHandler.swift
//  Pillowz
//
//  Created by Samat on 13.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

enum FieldType: Int {
    case search = 0
    case create = 1
    case request = 2
}

class CategoriesHandler: NSObject {
    static let sharedInstance = CategoriesHandler()
    
    var categories:[SpaceCategory] = []
    var comforts:[ComfortItem] = []

    var countries:[Country] = []
    var languages:[Language] = []

    func getCategories() {
        HelpersAPIManager.getCategories { (categoriesAndComfortsArrayObject, error) in
            if (error == nil) {
                let responseArray = categoriesAndComfortsArrayObject as! [Any]
                self.categories = responseArray[0] as! [SpaceCategory]
                self.comforts = responseArray[1] as! [ComfortItem]
                
                NotificationCenter.default.post(name: NSNotification.Name(Constants.loadedCategoriesNotification), object: nil)
            }
        }
    }
    
    func getCountries() {
        HelpersAPIManager.getCountries(completion: { (countriesObject, error) in
            if (error == nil) {
                self.countries = countriesObject as! [Country]
                
                NotificationCenter.default.post(name: NSNotification.Name(Constants.loadedCountriesNotification), object: nil)
            }
        })
    }
    
    func getLanguages() {
        HelpersAPIManager.getLanguages(completion: { (languagesObject, error) in
            if (error == nil) {
                self.languages = languagesObject as! [Language]
                
                NotificationCenter.default.post(name: NSNotification.Name(Constants.loadedLanguagesNotification), object: nil)
            }
        })
    }
    
    class func getFieldsForChosenCategories(chosenSpaceCategories:[String], fieldType:FieldType) -> [Field] {
        //var fields:[Field] = []
        var chosenSpaceCategoryObjects:[SpaceCategory] = []
        
        for category in CategoriesHandler.sharedInstance.categories {
            var chosenSpaceCategoryObject:SpaceCategory?
            
            for categoryValue in chosenSpaceCategories {
                if category.value! == categoryValue {
                    chosenSpaceCategoryObject = category
                }
            }
            
            guard let chosenSpaceCategory = chosenSpaceCategoryObject else {
                continue
            }
            
            chosenSpaceCategoryObjects.append(chosenSpaceCategory)
        }
        
        guard let firstSpaceCategory = chosenSpaceCategoryObjects.first else {
            return []
        }
        
        var firstCategoryFieldsList:[Field] = []
        
        if fieldType == .create {
            firstCategoryFieldsList = firstSpaceCategory.fields!
        } else if fieldType == .search {
            firstCategoryFieldsList = firstSpaceCategory.search_fields!
        } else {
            firstCategoryFieldsList = firstSpaceCategory.request_fields!
        }
        
        var commonFieldsList:[Field] = []
        
        for firstCategoryField in firstCategoryFieldsList {
            var allCategoriesHaveThisField = true
            
            for chosenSpaceCategory in chosenSpaceCategoryObjects {
                var fieldsList:[Field] = []
                
                if fieldType == .create {
                    fieldsList = chosenSpaceCategory.fields!
                } else if fieldType == .search {
                    fieldsList = chosenSpaceCategory.search_fields!
                } else {
                    fieldsList = chosenSpaceCategory.request_fields!
                }
                
                var thisCategoryHaveThisField = false
                
                for field in fieldsList {
                    if firstCategoryField.type == "InlineField" {
                        if field.type == "InlineField" && firstCategoryField.first?.param_name == field.first?.param_name && firstCategoryField.second?.param_name == field.second?.param_name {
                            thisCategoryHaveThisField = true
                        }
                    } else {
                        if (firstCategoryField.type == "HeaderField" && field.type == "HeaderField" && firstCategoryField.name == field.name) {
                            thisCategoryHaveThisField = true
                        } else if firstCategoryField.param_name == field.param_name {
                            thisCategoryHaveThisField = true
                        }
                    }
                }
                
                if !thisCategoryHaveThisField {
                    allCategoriesHaveThisField = false
                    break
                }
            }
            
            if allCategoriesHaveThisField {
                commonFieldsList.append(firstCategoryField)
            }
        }
        
        //FOR TESTING
        for field in commonFieldsList {
            if (field.name != nil) {
                print(field.name)
                print(field.first?.param_name)
            }
            
            if (field.type != nil) {
                print(field.type)
            }
        }
        
        for field in commonFieldsList {
            if (fieldType == .search) {
                if (field.type != "InlineField") {
                    field.didPickFieldValueClosure = { (newValue) in
                        field.value = String(describing: newValue)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(Constants.changedFilterValueNotification), object: nil)
                    }
                } else {
                    field.didPickRangeValueClosure = { (value1, value2) in
                        if (value1 != nil) {
                            field.first!.value = String(describing:value1!)
                        } else {
                            field.first!.value = ""
                        }
                        if (value2 != nil) {
                            field.second!.value = String(describing:value2!)
                        } else {
                            field.second!.value = ""
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(Constants.changedFilterValueNotification), object: nil)
                    }
                }
            }
        }
        
        return commonFieldsList
    }
    
    class func getFieldsOfObject(object:NSObject, shouldControlObject:Bool, shouldFillEmptyValues:Bool = false) -> ([Field], [String]) {
        var fields:[Field] = []
        var headers:[String] = []
        
        let multiLanguageNames = (object as! PropertyNames).getMultiLanguageNames()
        
        var keys = object.propertyNames()
        
        let editableKeys = (object as! PropertyNames).getEditableKeys?()
        
        if (editableKeys != nil) {
            keys = editableKeys!
        }
        
        let icons = (object as! PropertyNames).getIcons?()
        
        for property in keys {
            let field = Field()
            if (shouldControlObject) {
                field.param_name = String(describing: type(of: object)) + property
            } else {
                field.param_name = property
            }
            
            var value = object.value(forKeyPath: property)
            
            if (value is String) {
                if ((value as! String) == "") {
                    if (shouldFillEmptyValues) {
                        value = "Не указано"
                    } else {
                        value = ""
                    }
                }
            }
            
            if (value == nil) {
                if (shouldFillEmptyValues) {
                    value = "Не указано"
                } else {
                    value = ""
                }
            }
            
            field.value = String(describing: value!)
            
            field.multiLanguageName = multiLanguageNames[property] as? [String:String]
            
            if (shouldControlObject) {
                field.didPickFieldValueClosure = { (newValue) in
                    object.setValue(newValue, forKey: property)
                    field.value = String(describing: newValue)
                }
            }
            
            if value is Bool {
                field.type = "BooleanField"
            } else if value is String {
                field.type = "CharField"
            } else if value is Int {
                field.type = "IntegerField"
            }
            
            if (icons != nil) {
                let icon = icons?[property]
                
                if (icon != nil) {
                    field.icon = icon
                    
                    if (object is Rule && value is Bool && !shouldControlObject) {
                        field.notAllowed = value as? Bool
                        
                        if (!field.notAllowed!) {
                            for key in field.multiLanguageName!.keys {
                                field.multiLanguageName![key] = field.multiLanguageName![key]!.replacingOccurrences(of: "Разрешено", with: "Запрещено")
                                field.multiLanguageName![key] = field.multiLanguageName![key]!.replacingOccurrences(of: "Подходит", with: "Не подходит")
                            }
                        }
                    }
                }
            }
            
            fields.append(field)
            headers.append(field.multiLanguageName!["ru"]!)
        }
        
        return (fields, headers)
    }
    
    class func getFieldsForChoosingCategories() -> [Field] {
        var fields:[Field] = []
        
        for category in CategoriesHandler.sharedInstance.categories {
            let field = Field()
            field.param_name = category.value
            field.multiLanguageName = category.multiLanguageName
            field.type = "BooleanField"
            
            fields.append(field)
        }
        
        return fields
    }
    
    class func getComfortsForCategories(categories:[String]) -> [ComfortItem] {
        var comforts: [ComfortItem] = []
        
            for comfort in CategoriesHandler.sharedInstance.comforts {
                if (categories.count != 0) {
                    for category in categories {
                        let comfortIsInCategory = comfort.rawJSON![category].boolValue
                        
                        if (comfortIsInCategory) {
                            comforts.append(comfort)
                            break
                        }
                    }
                } else {
                    comforts.append(comfort)
                }
            }
        
        
        return comforts
    }
}
