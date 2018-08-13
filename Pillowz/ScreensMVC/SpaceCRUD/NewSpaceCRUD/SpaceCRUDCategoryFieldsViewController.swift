//
//  SpaceCRUDCategoryFieldsViewController.swift
//  Pillowz
//
//  Created by Samat on 04.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceCRUDCategoryFieldsViewController: StepViewController {
    let crudVM = CreateEditObjectTableViewGenerator()
    var fields:[AnyObject] = []
    var headers:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        crudVM.viewController = self
        generateFields()
        crudVM.headers = headers
        crudVM.object = fields as AnyObject
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Your code with delay
//            SpaceEditorManager.sharedInstance.spaceCRUDVC!.pageViewController.dataSource = nil
//            SpaceEditorManager.sharedInstance.spaceCRUDVC!.pageViewController.dataSource = SpaceEditorManager.sharedInstance.spaceCRUDVC!
        }
    }
    
    func generateFields() {
        if (SpaceEditorManager.sharedInstance.currentEditingSpace!.fields != nil) {
            SpaceEditorManager.sharedInstance.spaceFields = SpaceEditorManager.sharedInstance.currentEditingSpace!.fields!
            fields.append(contentsOf: SpaceEditorManager.sharedInstance.spaceFields as [AnyObject])
            for spaceField in SpaceEditorManager.sharedInstance.spaceFields {
                if (!spaceField.shouldAddHeader()) {
                    headers.append("")
                } else {
                    headers.append(spaceField.name!)
                }
                
                if spaceField.type == "IntegerField" && spaceField.isInput == false && spaceField.value == "" {
                    spaceField.value = "1"
                }
                
                if spaceField.required_space == true {
                    spaceField.required = true
                }
            }
            
            addTrackingToFields()
        }
    }
    
    func addTrackingToFields() {
        for field in SpaceEditorManager.sharedInstance.spaceFields {
            if field.type == "InlineField" {
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
                    
                    let _ = self.checkIfAllFieldsAreFilled()
                }
            } else {
                field.didPickFieldValueClosure = { (newValue) in
                    field.value = String(describing: newValue)
                    let _ = self.checkIfAllFieldsAreFilled()
                }
            }
        }
    }
    
    override func checkIfAllFieldsAreFilled() -> Bool {
        var filled = true
        
        for field in SpaceEditorManager.sharedInstance.spaceFields {
            if field.type == "InlineField" {
                if field.first!.required_space! && field.first!.value == "" && field.second!.required_space! && field.second!.value == "" {
                    filled = false
                }
            } else {
                if field.value == "" && field.required_space! {
                    filled = false
                }
            }
        }
        
        SpaceEditorManager.sharedInstance.spaceCRUDVC!.nextButton.isEnabled = filled
        
        if filled {
            SpaceEditorManager.sharedInstance.spaceCRUDVC!.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Your code with delay
//                SpaceEditorManager.sharedInstance.spaceCRUDVC!.pageViewController.dataSource = nil
//                SpaceEditorManager.sharedInstance.spaceCRUDVC!.pageViewController.dataSource = SpaceEditorManager.sharedInstance.spaceCRUDVC!
            }
        }
        
        return filled
    }
}
