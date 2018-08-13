//
//  OpenRequestSecondStepViewController.swift
//  Pillowz
//
//  Created by Samat on 17.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class OpenRequestSecondStepViewController: StepViewController {
    static let shared = OpenRequestSecondStepViewController()

    let crudVM = CreateEditObjectTableViewGenerator()

    var fields:[AnyObject] = []
    var headers:[String] = []

    var chosenCategory:String! = UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        crudVM.viewController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fields = []
        self.headers = []

        CurrentNewOpenRequestValues.shared.chosenCategoryFields = CategoriesHandler.getFieldsForChosenCategories(chosenSpaceCategories: [UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory], fieldType: .request)
        
        self.fields.append(contentsOf: CurrentNewOpenRequestValues.shared.chosenCategoryFields as [AnyObject])
        for i in 0..<CurrentNewOpenRequestValues.shared.chosenCategoryFields.count {
            let field = CurrentNewOpenRequestValues.shared.chosenCategoryFields[i]
            
            if (!field.shouldAddHeader()) {
                self.headers.append("")
            } else {
                self.headers.append(field.name!)
            }
            
            if field.type == "IntegerField" && field.isInput == false {
                field.value = "1"
            }
        }
        
        headers.append("Удобства")
        
        CurrentNewOpenRequestValues.shared.comforts = CategoriesHandler.sharedInstance.comforts
        
        fields.append(contentsOf: CurrentNewOpenRequestValues.shared.comforts as [AnyObject])
        for _ in 0..<CurrentNewOpenRequestValues.shared.comforts.count-1 {
            headers.append("")
        }
        
        headers.append("Правила")
        
        var rules = CategoriesHandler.getFieldsOfObject(object: CurrentNewOpenRequestValues.shared.rules, shouldControlObject: true).0 as [AnyObject]
        var rulesFields:[Field] = []
        
        for i in 0..<rules.count {
            let rule = rules[i] as! Field
            if rule.type != "CharField" {
                rulesFields.append(rule)
            }
        }
        
        fields.append(contentsOf: rulesFields as [AnyObject])
        for _ in 0..<rulesFields.count-1 {
            headers.append("")
        }
        
        self.crudVM.headers = self.headers
        self.crudVM.object = self.fields as AnyObject
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
