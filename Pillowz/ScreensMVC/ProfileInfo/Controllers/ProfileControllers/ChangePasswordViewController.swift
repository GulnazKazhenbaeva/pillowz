//
//  ChangePasswordViewController.swift
//  Pillowz
//
//  Created by Samat on 20.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit


class ChangePasswordViewController: PillowzViewController, SaveActionDelegate {
    var current_password = ""
    var new_password = ""
    
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
        crudVM.hasSaveAction = true
    }
    
    func generateFields() {
        let oldPasswordField = Field()
        oldPasswordField.param_name = "current_password"
        oldPasswordField.multiLanguageName = ["ru": "Старый пароль", "en":"Старый пароль"]
        oldPasswordField.didPickFieldValueClosure = { (newValue) in
            let current_password = newValue as! String
            self.current_password = current_password
            oldPasswordField.value = newValue as! String
        }
        oldPasswordField.type = "CharField"
        fields.append(oldPasswordField)
        headers.append("Старый пароль")

        let newPasswordField = Field()
        newPasswordField.param_name = "new_password"
        newPasswordField.multiLanguageName = ["ru": "Новый пароль", "en":"Новый пароль"]
        newPasswordField.didPickFieldValueClosure = { (newValue) in
            let new_password = newValue as! String
            self.new_password = new_password
            newPasswordField.value = newValue as! String
        }
        newPasswordField.type = "CharField"
        fields.append(newPasswordField)
        headers.append("Новый пароль")
    }
    
    func actionButtonTapped() {
        AuthorizationAPIManager.changePassword(current_password: current_password, new_password: new_password) { (responseObject, error) in
            if (error == nil) {
                DesignHelpers.makeToastWithText("Пароль успешно изменен")

                self.navigationController?.popViewController(animated: true)
            }
        }
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
