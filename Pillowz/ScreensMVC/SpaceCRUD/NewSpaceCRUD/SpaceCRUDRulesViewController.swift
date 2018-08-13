//
//  SpaceCRUDRulesViewController.swift
//  Pillowz
//
//  Created by Samat on 04.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceCRUDRulesViewController: StepViewController {
    
    let crudVM = CreateEditObjectTableViewGenerator()
    var fields:[AnyObject] = []
    var headers:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        crudVM.viewController = self
        generateFields()
        crudVM.headers = headers
        crudVM.object = fields as AnyObject
        
        let options:[String:String] = ["Ruleadditional_rule":"longText"]

        crudVM.options = options
    }
    
    func generateFields() {
        SpaceEditorManager.sharedInstance.rules = SpaceEditorManager.sharedInstance.currentEditingSpace.rule!
        let rulesFields = CategoriesHandler.getFieldsOfObject(object: SpaceEditorManager.sharedInstance.rules, shouldControlObject: true).0 as [AnyObject]
        fields.append(contentsOf: rulesFields)
        
        for rulesField in rulesFields {
            if (rulesField as! Field).type != "CharField" {
                headers.append("")
            } else {
                headers.append((rulesField as! Field).name!)
            }
        }
        
        if let additionalRulesField = rulesFields.last as? Field {
            additionalRulesField.multiLanguageName = ["ru": "Пример: После 21:00 шуметь нельзя. Помните - чем больше правил, тем меньше желающих заселиться.", "en":"Пример: После 21:00 шуметь нельзя. Помните - чем больше правил, тем меньше желающих заселиться."]
        }
    }

    override func checkIfAllFieldsAreFilled() -> Bool {
        return true
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
