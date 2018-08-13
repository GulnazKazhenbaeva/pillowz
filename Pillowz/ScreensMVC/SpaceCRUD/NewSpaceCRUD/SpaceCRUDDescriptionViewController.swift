//
//  SpaceCRUDDescriptionViewController.swift
//  Pillowz
//
//  Created by Samat on 04.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceCRUDDescriptionViewController: StepViewController {
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
        
        let options:[String:String] = ["spaceDescription":"longText", "name":"longText", "additional_features":"longText", "cancellation_policy":"longText", "additional_charges":"longText", "arrival_and_checkout_text":"longText", "deposit":"longText"]
        
        crudVM.options = options
    }
    
    func generateFields() {
        let nameField = Field()
        nameField.required = true
        nameField.param_name = "name"
        nameField.multiLanguageName = ["ru": "Пример: Квартира для молодой семьи в жилом комплексе", "en":"Пример: Квартира для молодой семьи в жилом комплексе"]
        nameField.value = SpaceEditorManager.sharedInstance.name
        nameField.didPickFieldValueClosure = { (newValue) in
            if let spaceCRUDVC = SpaceEditorManager.sharedInstance.spaceCRUDVC, spaceCRUDVC.isPublished && !spaceCRUDVC.shouldSendToModerationWhileEditing {
                let infoView = ModalInfoView(titleText: "Изменение этих данных отправит объект недвижимости на модерацию", descriptionText: "Вы уверены, что хотите изменить данные об объекте недвижимости?")
                
                infoView.addButtonWithTitle("Да", action: {
                    let name = newValue as! String
                    SpaceEditorManager.sharedInstance.name = name
                    nameField.value = newValue as! String
                    SpaceEditorManager.sharedInstance.spaceCRUDVC!.shouldSendToModerationWhileEditing = true
                })
                
                infoView.addButtonWithTitle("Отмена", action: {
                    nameField.value = SpaceEditorManager.sharedInstance.name
                })
                
                infoView.show()
            } else {
                let name = newValue as! String
                SpaceEditorManager.sharedInstance.name = name
                nameField.value = newValue as! String
            }
        }
        nameField.type = "CharField"
        fields.append(nameField)
        headers.append("Название")
        
        let spaceDescriptionField = Field()
        spaceDescriptionField.required = true
        spaceDescriptionField.param_name = "spaceDescription"
        spaceDescriptionField.multiLanguageName = ["ru": "Пример: Отлично подходит для небольшой семьи, есть детская мебель. В доме есть лифт на случай, если у вас коляска. Рядом находятся гипермаркет, аптека, терминалы, банкоматы. В том же квартале есть школа. ", "en":"Пример: Отлично подходит для небольшой семьи, есть детская мебель. В доме есть лифт на случай, если у вас коляска. Рядом находятся гипермаркет, аптека, терминалы, банкоматы. В том же квартале есть школа. "]
        spaceDescriptionField.value = SpaceEditorManager.sharedInstance.spaceDescription
        spaceDescriptionField.didPickFieldValueClosure = { (newValue) in
            if let spaceCRUDVC = SpaceEditorManager.sharedInstance.spaceCRUDVC, spaceCRUDVC.isPublished && !spaceCRUDVC.shouldSendToModerationWhileEditing {
                let infoView = ModalInfoView(titleText: "Изменение этих данных отправит объект недвижимости на модерацию", descriptionText: "Вы уверены, что хотите изменить данные об объекте недвижимости?")
                
                infoView.addButtonWithTitle("Да", action: {
                    let spaceDescription = newValue as! String
                    SpaceEditorManager.sharedInstance.spaceDescription = spaceDescription
                    spaceDescriptionField.value = newValue as! String
                    SpaceEditorManager.sharedInstance.spaceCRUDVC!.shouldSendToModerationWhileEditing = true
                })
                
                infoView.addButtonWithTitle("Отмена", action: {
                    spaceDescriptionField.value = SpaceEditorManager.sharedInstance.spaceDescription
                    self.view.endEditing(true)
                })
                
                infoView.show()
            } else {
                let spaceDescription = newValue as! String
                SpaceEditorManager.sharedInstance.spaceDescription = spaceDescription
                spaceDescriptionField.value = newValue as! String
            }
        }
        spaceDescriptionField.type = "CharField"
        fields.append(spaceDescriptionField)
        headers.append("Описание")
        
        let additional_featuresField = Field()
        additional_featuresField.param_name = "additional_features"
        additional_featuresField.multiLanguageName = ["ru": "Пример: Оформление временной регистрации, гостиничные принадлежности", "en":"Пример: Оформление временной регистрации, гостиничные принадлежности"]
        additional_featuresField.value = SpaceEditorManager.sharedInstance.additional_features
        additional_featuresField.didPickFieldValueClosure = { (newValue) in
            let additional_features = newValue as! String
            SpaceEditorManager.sharedInstance.additional_features = additional_features
            additional_featuresField.value = newValue as! String
        }
        additional_featuresField.type = "CharField"
        fields.append(additional_featuresField)
        headers.append("Особенности жилья")
        
//        let infrastructureField = Field()
//        infrastructureField.param_name = "infrastructure"
//        infrastructureField.multiLanguageName = ["ru": "Инфраструктура", "en":"Инфраструктура"]
//        infrastructureField.value = SpaceEditorManager.sharedInstance.infrastructure
//        infrastructureField.didPickFieldValueClosure = { (newValue) in
//            let infrastructure = newValue as! String
//            SpaceEditorManager.sharedInstance.infrastructure = infrastructure
//            infrastructureField.value = newValue as! String
//        }
//        infrastructureField.type = "CharField"
//        fields.append(infrastructureField)
//        headers.append("Инфраструктура")
        
        let cancellation_policyField = Field()
        cancellation_policyField.param_name = "cancellation_policy"
        cancellation_policyField.multiLanguageName = ["ru": "Не отмечая этот пункт, вы подтверждаете, что клиент может отменить заявку менее, чем за 24 часа до заезда.", "en":"Не отмечая этот пункт, вы подтверждаете, что клиент может отменить заявку менее, чем за 24 часа до заезда."]
        cancellation_policyField.value = SpaceEditorManager.sharedInstance.cancellation_policy
        cancellation_policyField.didPickFieldValueClosure = { (newValue) in
            let cancellation_policy = newValue as! String
            SpaceEditorManager.sharedInstance.cancellation_policy = cancellation_policy
            cancellation_policyField.value = newValue as! String
        }
        cancellation_policyField.type = "CharField"
        fields.append(cancellation_policyField)
        headers.append("Правила отмены бронирования")

        let additional_chargesField = Field()
        additional_chargesField.param_name = "additional_charges"
        additional_chargesField.multiLanguageName = ["ru": "Дополнительные услуги", "en":"Дополнительные услуги"]
        additional_chargesField.value = SpaceEditorManager.sharedInstance.additional_charges
        additional_chargesField.didPickFieldValueClosure = { (newValue) in
            let additional_charges = newValue as! String
            SpaceEditorManager.sharedInstance.additional_charges = additional_charges
            additional_chargesField.value = newValue as! String
        }
        additional_chargesField.type = "CharField"
        fields.append(additional_chargesField)
        headers.append("Дополнительные услуги")
        
        let arrival_and_checkoutField = Field()
        arrival_and_checkoutField.type = "ChoiceField"
        arrival_and_checkoutField.param_name = "arrival_and_checkout"
        arrival_and_checkoutField.multiLanguageName = ["ru": "Прибытие и выезд", "en":"Прибытие и выезд"]
        arrival_and_checkoutField.didSelectClosure = { () in
            let arrival_and_checkoutVC = ArrivalAndCheckoutViewController()
            
            if !(SpaceEditorManager.sharedInstance.arrival_time == 0 && SpaceEditorManager.sharedInstance.checkout_time == 0) {
                arrival_and_checkoutVC.arrival_time = SpaceEditorManager.sharedInstance.arrival_time
                arrival_and_checkoutVC.checkout_time = SpaceEditorManager.sharedInstance.checkout_time
            }
            
            arrival_and_checkoutVC.saveArrivalAndCheckoutClosure = { (arrival_time, checkout_time) in
                SpaceEditorManager.sharedInstance.arrival_time = arrival_time
                SpaceEditorManager.sharedInstance.checkout_time = checkout_time
                
                var arrival_and_checkoutFieldText = "Заезд " + "после " + String(SpaceEditorManager.sharedInstance.arrival_time) + ":00, "
                arrival_and_checkoutFieldText = arrival_and_checkoutFieldText + "выезд " + "до " + String(SpaceEditorManager.sharedInstance.checkout_time) + ":00"
                arrival_and_checkoutField.setCustomText(text: arrival_and_checkoutFieldText)
                arrival_and_checkoutVC.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(arrival_and_checkoutVC, animated: true)
        }
        
        if (SpaceEditorManager.sharedInstance.arrival_time == 0 && SpaceEditorManager.sharedInstance.checkout_time == 0) {
            arrival_and_checkoutField.setCustomText(text: "Не указано")
        } else {
            var arrival_and_checkoutFieldText = "Заезд " + "после " + String(SpaceEditorManager.sharedInstance.arrival_time) + ":00, "
            arrival_and_checkoutFieldText = arrival_and_checkoutFieldText + "выезд " + "до " + String(SpaceEditorManager.sharedInstance.checkout_time) + ":00"
            arrival_and_checkoutField.setCustomText(text: arrival_and_checkoutFieldText)
        }

        
        let arrival_and_checkoutTextField = Field()
        arrival_and_checkoutTextField.param_name = "arrival_and_checkout_text"
        arrival_and_checkoutTextField.multiLanguageName = ["ru": "Условия заезда и выезда", "en":"Условия заезда и выезда"]
        arrival_and_checkoutTextField.value = SpaceEditorManager.sharedInstance.arrival_and_checkout
        arrival_and_checkoutTextField.didPickFieldValueClosure = { (newValue) in
            let arrival_and_checkout = newValue as! String
            SpaceEditorManager.sharedInstance.arrival_and_checkout = arrival_and_checkout
            arrival_and_checkoutTextField.value = newValue as! String
        }
        arrival_and_checkoutTextField.type = "CharField"
        fields.append(arrival_and_checkoutTextField)
        headers.append("Условия заезда и выезда")

        
        fields.append(arrival_and_checkoutField)
        headers.append("Прибытие и выезд")
        
        let depositField = Field()
        depositField.param_name = "deposit"
        depositField.multiLanguageName = ["ru": "Страховой депозит", "en":"Страховой депозит"]
        depositField.value = SpaceEditorManager.sharedInstance.deposit
        depositField.didPickFieldValueClosure = { (newValue) in
            let deposit = newValue as! String
            SpaceEditorManager.sharedInstance.deposit = deposit
            depositField.value = newValue as! String
        }
        depositField.type = "CharField"
        fields.append(depositField)
        headers.append("Страховой депозит")
    }
    
    override func checkIfAllFieldsAreFilled() -> Bool {
        if SpaceEditorManager.sharedInstance.spaceDescription == "" || SpaceEditorManager.sharedInstance.name == "" {
            return false
        }
        
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let spaceCRUDVC = SpaceEditorManager.sharedInstance.spaceCRUDVC, spaceCRUDVC.isCreating {
            spaceCRUDVC.nextButton.setTitle("создать", for: .normal)
        } else {
            SpaceEditorManager.sharedInstance.spaceCRUDVC?.nextButton.setTitle("сохранить", for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SpaceEditorManager.sharedInstance.spaceCRUDVC?.nextButton.setTitle("продолжить", for: .normal)
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
