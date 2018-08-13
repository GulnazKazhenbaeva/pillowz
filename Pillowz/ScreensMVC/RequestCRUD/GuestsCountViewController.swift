//
//  GuestsCountViewController.swift
//  Pillowz
//
//  Created by Samat on 19.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol GuestsCountViewControllerDelegate {
    func didPickNumberOf(adults:Int, childs:Int, babies:Int)
}

class GuestsCountViewController: PillowzViewController {
    let crudVM = CreateEditObjectTableViewGenerator()
    var fields:[AnyObject] = []
    var headers:[String] = []
    
    var adults:Int = 1
    var childs:Int = 0
    var babies:Int = 0

    let adultsField = Field()
    let childsField = Field()
    let babiesField = Field()

    var delegate:GuestsCountViewControllerDelegate?
    
    var space:Space!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        crudVM.viewController = self
        crudVM.options = [:]
        generateFields()
        crudVM.headers = headers
        crudVM.object = fields as AnyObject
    }
    
    func generateFields() {
        adultsField.param_name = "adultsField"
        adultsField.multiLanguageName = ["ru": "Взрослые", "en":"Взрослые"]
        
        adultsField.value = String(adults)
        
        adultsField.didPickFieldValueClosure = { (newValue) in
            let number = newValue as! Int
            self.adults = number
            self.adultsField.value = String(number)
        }
        adultsField.type = "IntegerField"
        fields.append(adultsField)
        headers.append("Сколько гостей?")

        if (space != nil) {
            if (space.rule!.child) {
                addChildField()
            }

            if (space.rule!.baby) {
                addBabyField()
            }
        } else {
            addChildField()
            addBabyField()
        }
    }
    
    func addChildField() {
        childsField.param_name = "childsField"
        childsField.multiLanguageName = ["ru": "Дети", "en":"Дети"]
        
        childsField.value = String(childs)

        childsField.didPickFieldValueClosure = { (newValue) in
            let number = newValue as! Int
            self.childs = number
            self.childsField.value = String(number)
        }
        childsField.type = "IntegerField"
        fields.append(childsField)
        headers.append("")
    }
    
    func addBabyField() {
        babiesField.param_name = "babiesField"
        babiesField.multiLanguageName = ["ru": "Младенцы", "en":"Младенцы"]
        
        babiesField.value = String(babies)

        babiesField.didPickFieldValueClosure = { (newValue) in
            let number = newValue as! Int
            self.babies = number
            self.babiesField.value = String(number)
        }
        babiesField.type = "IntegerField"
        fields.append(babiesField)
        headers.append("")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.didPickNumberOf(adults: self.adults, childs: self.childs, babies: self.babies)
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
