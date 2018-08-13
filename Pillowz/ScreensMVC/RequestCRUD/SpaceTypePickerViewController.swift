//
//  SpaceTypePickerViewController.swift
//  Pillowz
//
//  Created by Samat on 17.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

public typealias SaveSpaceTypeAndFieldsWithAPIClosure = (_ category: String, _ fields: [Field]) -> Void

class SpaceTypePickerViewController: ValidationViewController {
    let crudVM = CreateEditObjectTableViewGenerator()

    var chosenCategory:String!
    var fields:[Field] = []
    var headers:[String] = []
    let fieldsForChoosingCategories = CategoriesHandler.getFieldsForChoosingCategories()

    var saveSpaceTypeAndFieldsWithAPIClosure:SaveSpaceTypeAndFieldsWithAPIClosure?

    var fieldsForUpdating:[Field] = []
    
    let chosenCategoryField = Field()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        crudVM.viewController = self

        crudVM.tableView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(0)
        }
        
        
        
        
        
        var choices:[Choice] = []
        
        var selectedChoice:Choice
        
        for field in fieldsForChoosingCategories {
            let choice = Choice()
            choice.value = field.param_name
            choice.multiLanguageName = field.multiLanguageName
            
            if (choice.value == chosenCategory) {
                selectedChoice = choice
                chosenCategoryField.selectedChoice = selectedChoice
            }
            
            choices.append(choice)
        }
        
        chosenCategory = choices.first!.value!
        chosenCategoryField.selectedChoice = choices.first!
        chosenCategoryField.setCustomText(text: chosenCategoryField.selectedChoice!.name!)
        showFieldsOfChosenCategory()

        chosenCategoryField.type = "ChoiceField"
        chosenCategoryField.param_name = "Тип жилья"
        chosenCategoryField.multiLanguageName = ["ru": "Тип жилья", "en":"Тип жилья"]
        chosenCategoryField.choices = choices
        chosenCategoryField.didPickFieldValueClosure = { (newValue) in
            let choice = newValue as! Choice
            
            self.chosenCategory = choice.value!
            
            self.chosenCategoryField.setCustomText(text: self.chosenCategoryField.selectedChoice!.name!)
            
            self.showFieldsOfChosenCategory()
            
            self.dataChanged = true
        }
        
        fields.append(chosenCategoryField)
        headers.append("Какой тип жилья?")
        
        if (fieldsForUpdating.count != 0) {
            self.fields.append(contentsOf: fieldsForUpdating)
            
            for i in 0..<fieldsForUpdating.count {
                let field = fieldsForUpdating[i]
                
                if (!field.shouldAddHeader()) {
                    self.headers.append("")
                } else {
                    self.headers.append(field.name!)
                }
            }
        }
        
        self.crudVM.headers = self.headers
        self.crudVM.object = self.fields as AnyObject

        self.view.bringSubview(toFront: self.saveButton)
    }
    
    func showFieldsOfChosenCategory() {
        //removing fields for previous category
        while self.fields.count>1 {
            self.fields.removeLast()
            self.headers.removeLast()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            //adding fields for new category
            let categoryFields = CategoriesHandler.getFieldsForChosenCategories(chosenSpaceCategories: [self.chosenCategory], fieldType: .request)
            self.fields.append(contentsOf: categoryFields)
            for i in 0..<categoryFields.count {
                let field = categoryFields[i]
                
                if (!field.shouldAddHeader()) {
                    self.headers.append("")
                } else {
                    self.headers.append(field.name!)
                }
            }
            
            self.crudVM.headers = self.headers
            self.crudVM.object = self.fields as AnyObject
        }
    }
    
    override func saveWithAPI() {
        if (self.chosenCategory==nil) {
            return
        }
        
        fieldsForUpdating = getCategorySpecificFields()
        
        saveSpaceTypeAndFieldsWithAPIClosure?(self.chosenCategory, fieldsForUpdating)
        self.isSaved = true
        self.navigationController?.popViewController(animated: true)
    }
    
    override func isValid() -> Bool {
        fieldsForUpdating = getCategorySpecificFields()

        for field in fieldsForUpdating {
            if (field.type != "InlineField") {
                if (field.required_request! && field.value=="") {
                    return false
                }
            } else {
                if (field.first!.required_request! && field.first!.value=="") {
                    return false
                }
                
                if (field.second!.required_request! && field.second!.value=="") {
                    return false
                }
            }
        }
        
        return true
    }
    
    func getCategorySpecificFields() -> [Field] {
        var categorySpecificFields:[Field] = []
        
        //removing fields of categories
        for i in 1..<fields.count {
            categorySpecificFields.append(fields[i])
        }
        
        return categorySpecificFields
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
