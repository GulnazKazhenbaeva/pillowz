//
//  NewRequestViewController.swift
//  Pillowz
//
//  Created by Samat on 09.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD


class NewRequestViewController: PillowzViewController, SaveActionDelegate, ExpandActionTableViewCellDelegate, AddressPickerDelegate, GuestsCountViewControllerDelegate {
    let crudVM = CreateEditObjectTableViewGenerator()
    var isShowingFullList = false
    
    var fields:[AnyObject] = []
    var headers:[String] = []

    let placeField = Field()
    let periodField = Field()
    let guestsField = Field()
    let categoryField = Field()
    let priceField = Field()
    let ownerField = Field()
    let urgentField = Field()
    
    var comfortsUpdated:Bool = false
    var rulesUpdated:Bool = false
    
    
    var startTime:Int?
    var endTime:Int?
    var rentType:RENT_TYPES!
    var lat:Double?
    var lon:Double?
    var address:String!
    var placeID:String?
    var price:Int!
    var bargain:Bool!
    let rules = Rule()
    var chosenCategory:String!
    var chosenCategoryFields:[Field]!
    var comforts:[ComfortItem] = []
    var urgent:Bool = false
    var owner:Bool = false
    var guests_count:[String:Int] = ["adult_guest":0, "child_guest":0, "baby_guest":0]

    var openSpaceTypeVCLoadingCategories = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = ""
        
        crudVM.viewController = self
        crudVM.options = ["other":"longText", "additional_rule":"longText"]
        crudVM.hasSaveAction = true
        crudVM.hasExpandAction = true
        generateFields()
        
        crudVM.tableView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(0)
        }
        
//        let rightButton: UIButton = UIButton(type: .custom)
//        rightButton.setTitle("Сбросить все", for: .normal)
//        rightButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
//        rightButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
//        rightButton.addTarget(self, action: #selector(clearRequestTapped), for: .touchUpInside)
//        rightButton.frame = CGRect(x:0, y:0, width:50, height:30)
//        let rightBarButton = UIBarButtonItem(customView: rightButton)
        
//        self.navigationItem.rightBarButtonItem = rightBarButton
        
        comforts = CategoriesHandler.sharedInstance.comforts
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadedCategories), name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
        
        crudVM.saveButton?.setTitle("Создать заявку", for: .normal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
    }
    
    @objc func loadedCategories() {
        let window = UIApplication.shared.delegate!.window!!
        
        MBProgressHUD.hide(for: window, animated: true)
        
        if (openSpaceTypeVCLoadingCategories) {
            openSpaceTypeVC()
            
            openSpaceTypeVCLoadingCategories = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        displayCurrentStateOfRequest()
    }
    
    func openSpaceTypeVC() {
        let spaceTypeVC = SpaceTypePickerViewController()
        
        if (self.chosenCategoryFields != nil) {
            spaceTypeVC.fieldsForUpdating = self.chosenCategoryFields
            spaceTypeVC.chosenCategory = self.chosenCategory
        }
        
        spaceTypeVC.saveSpaceTypeAndFieldsWithAPIClosure = { (category, fields) in
            self.chosenCategory = category
            self.chosenCategoryFields = fields
        }
        self.navigationController?.pushViewController(spaceTypeVC, animated: true)
    }
    
    func displayCurrentStateOfRequest() {
        if (address != nil && address != "") {
            placeField.setCustomText(text: address)
            
            let cell = self.crudVM.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ListPickerTableViewCell
            cell?.nameLabel.textColor = Constants.paletteVioletColor
        }
        
        if (rentType != nil) {
            let fullText = Request.getStringForRentType(rentType, startTime: startTime, endTime: endTime)
            
            periodField.setCustomText(text: fullText)
            
            self.crudVM.tableView.reloadData()

            let cell = self.crudVM.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? ListPickerTableViewCell
            cell?.nameLabel.textColor = Constants.paletteVioletColor
        }
        
        if (guests_count["adult_guest"] != 0 || guests_count["child_guest"] != 0 || guests_count["baby_guest"] != 0) {
            var fullText = ""

            if (guests_count["adult_guest"] != 0) {
                fullText.append(String(guests_count["adult_guest"]!)+" взрослых, ")
            }
            
            if (guests_count["child_guest"] != 0) {
                fullText.append(String(guests_count["child_guest"]!)+" детей, ")
            }
            
            if (guests_count["baby_guest"] != 0) {
                fullText.append(String(guests_count["baby_guest"]!)+" младенцев, ")
            }
            
            fullText = String(fullText.dropLast(2))
            
            guestsField.setCustomText(text: fullText)
            
            let cell = self.crudVM.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? ListPickerTableViewCell
            cell?.nameLabel.textColor = Constants.paletteVioletColor
        }
        
        if (chosenCategory != nil) {
            var fullText = ""
            
            let categories = CategoriesHandler.sharedInstance.categories
            
            for category in categories {
                if (category.value == chosenCategory) {
                    fullText = fullText + category.name!
                    break
                }
            }
            
            categoryField.setCustomText(text: fullText)
            
            let cell = self.crudVM.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? ListPickerTableViewCell
            cell?.nameLabel.textColor = Constants.paletteVioletColor
        }
        
        if (price != nil) {
            var fullText = String(price)+"₸"
            
            if (bargain != nil && bargain) {
                fullText = fullText + " (торг)"
            }
            
            priceField.setCustomText(text: fullText)
            
            let cell = self.crudVM.tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? ListPickerTableViewCell
            cell?.nameLabel.textColor = Constants.paletteVioletColor
        }
    }
    
    @objc func clearRequestTapped() {
//        filter.clearFilter()
//        crudVM.object = filter.parameters as AnyObject
//        crudVM.tableView.reloadData()
    }
    
    func generateFields() {
        fields = []
        headers = []
        
        let headerField = Field()
        headerField.isCustomCellField = true
        headerField.param_name = "headerField"
        headerField.customCellObject = "Вам некогда искать жилье?\nЗаполните поля и получайте  выгодные предложения!" as AnyObject
        headerField.customCellClassString = "HeaderTextTableViewCell"
        fields.append(headerField)
        headers.append("")
        
        placeField.type = "ChoiceField"
        placeField.param_name = "Адрес"
        placeField.multiLanguageName = ["ru": "Адрес", "en":"Address"]
        placeField.didSelectClosure = { () in
            let vc = AddressPickerViewController()
            
            if (self.address != nil) {
                vc.address = self.address
                vc.lat = self.lat
                vc.lon = self.lon
            }
            
            vc.saveAddressWithAPIClosure = { (address, lat, lon, placeID) in
                self.address = address
                self.lat = lat
                self.lon = lon
                self.placeID = placeID
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        fields.append(placeField)
        headers.append("Где ищете жилье?")
        
        periodField.type = "ChoiceField"
        periodField.param_name = "Период"
        periodField.multiLanguageName = ["ru": "Период", "en":"Период"]
        periodField.didSelectClosure = { () in
            let periodPickerVC = PeriodPickerViewController()
            
            if (self.rentType != nil) {
                periodPickerVC.rent_type = self.rentType
                periodPickerVC.fromDate = Date(timeIntervalSince1970: TimeInterval(self.startTime!))
                periodPickerVC.tillDate = Date(timeIntervalSince1970: TimeInterval(self.endTime!))
            }
            
            periodPickerVC.savePeriodWithAPIClosure = { (timestampStart, timestampEnd, rentType) in
                self.startTime = timestampStart
                self.endTime = timestampEnd
                self.rentType = rentType
                periodPickerVC.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(periodPickerVC, animated: true)
        }
        fields.append(periodField)
        headers.append("На какой период?")

        guestsField.type = "ChoiceField"
        guestsField.param_name = "Количество гостей"
        guestsField.multiLanguageName = ["ru": "Количество гостей", "en":"Количество гостей"]
        
        guestsField.didSelectClosure = { () in
            let guestsPickerVC = GuestsCountViewController()
            guestsPickerVC.adults = self.guests_count["adult_guest"]!
            guestsPickerVC.childs = self.guests_count["child_guest"]!
            guestsPickerVC.babies = self.guests_count["baby_guest"]!
            guestsPickerVC.delegate = self
            self.navigationController?.pushViewController(guestsPickerVC, animated: true)
        }
        fields.append(guestsField)
        headers.append("Количество гостей?")

        categoryField.type = "ChoiceField"
        categoryField.param_name = "Тип жилья"
        categoryField.multiLanguageName = ["ru": "Тип жилья", "en":"Тип жилья"]
        categoryField.didSelectClosure = { () in
            if (CategoriesHandler.sharedInstance.categories.count == 0) {
                let window = UIApplication.shared.delegate!.window!!
                
                MBProgressHUD.showAdded(to: window, animated: true)
                
                self.openSpaceTypeVCLoadingCategories = true
                CategoriesHandler.sharedInstance.getCategories()
            } else {
                self.openSpaceTypeVC()
            }
        }
        fields.append(categoryField)
        headers.append("Какой тип жилья?")

        priceField.type = "ChoiceField"
        priceField.param_name = "Цена"
        priceField.multiLanguageName = ["ru": "Цена", "en":"Цена"]
        priceField.didSelectClosure = { () in
            let priceVC = PricePickerViewController()
            
            if (self.price != nil) {
                priceVC.priceTextField.text = self.price.formattedWithSeparator
                priceVC.bargainPickerSwitch.isOn = self.bargain
            }
            
            priceVC.savePriceWithAPIClosure = { (price, bargain) in
                self.bargain = bargain
                self.price = price
                self.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(priceVC, animated: true)
        }
        fields.append(priceField)
        headers.append("Предложите цену")

        ownerField.type = "BooleanField"
        ownerField.param_name = "owner"
        ownerField.multiLanguageName = ["ru": "Только объявление от хозяина", "en":"owner"]
        ownerField.didPickFieldValueClosure = { (newValue) in
            self.owner = newValue as! Bool
        }
        fields.append(ownerField)
        headers.append("")

        if (isShowingFullList) {
            headers.append("Удобства")
            
            fields.append(contentsOf: comforts as [AnyObject])
            for _ in 0..<comforts.count-1 {
                headers.append("")
            }
            
            headers.append("Правила")

            var rules = CategoriesHandler.getFieldsOfObject(object: self.rules, shouldControlObject: true).0 as [AnyObject]
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
        }
        
        crudVM.headers = headers
        crudVM.object = fields as AnyObject
    }
    
    func expandButtonTapped() {
        isShowingFullList = !isShowingFullList
        
        if (!isShowingFullList) {
            for comfort in self.comforts {
                comfort.checked = nil
            }
            
            self.rules.baby = false
            self.rules.child = false
            self.rules.smoking = false
            self.rules.pet = false
            self.rules.party = false
            self.rules.limited = false
        }
        
        generateFields()
        
        crudVM.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.displayCurrentStateOfRequest()
        }
    }
    
    func actionButtonTapped() {
        if (address == "" || lat == nil || lon == nil || startTime == nil || endTime == nil || rentType == nil || price == nil || bargain == nil || chosenCategoryFields == nil || chosenCategory == nil) {
            DesignHelpers.makeToastWithText("Заполните все поля")
            
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        RequestAPIManager.createRequest(address: address, lat: lat!, lon: lon!, start_time: startTime, end_time: endTime, rent_type: rentType, price: price, bargain: bargain, rules: rules, fields: chosenCategoryFields, category: chosenCategory, comforts: comforts, urgent: false, photo: false, owner: owner, guests_count: guests_count) { (requestObject, error) in
            if (error == nil) {
                RequestEditorManager.sharedInstance.currentEditingRequest = requestObject as? Request
                
                let mainTabBarController = self.navigationController!.tabBarController as! MainTabBarController
                mainTabBarController.selectedIndex = 2
                
                let vc = (mainTabBarController.viewControllers![2] as! UINavigationController).viewControllers.first as! RequestsListViewController
                vc.page = 1
                vc.loadNextPage()
                
                self.navigationController?.popToRootViewController(animated: true)

                let infoView = ModalInfoView(titleText: "Отлично! Ваша заявка успешно создана и будет активна в течение 24 часов.", descriptionText: "Теперь Вы можете просматривать предложения от арендодателей.\n\nВыберите наиболее подходящее вам предложение и согласуйте детали с арендодателем, написав ему сообщение, либо позвонив по номеру.")
                
                infoView.addButtonWithTitle("Посмотреть заявку", action: {
                    if let request = requestObject as? Request, let _ = request.request_id {
                        let requestVC = RequestOrOfferViewController()
                        
                        RequestUpdateFirebaseListener.shared.requestVC = requestVC
                        RequestUpdateFirebaseListener.shared.request = request

                        requestVC.request = request
                        UIApplication.topViewController()?.navigationController?.pushViewController(requestVC, animated: true)
                    }
                })
                
                infoView.show()
                
            } else {
                
            }
        }
    }
    
    func didPickAddress(address: String, lat: Double, lon: Double) {
        self.address = address
        self.lat = lat
        self.lon = lon
    }
    
    func didPickNumberOf(adults: Int, childs: Int, babies: Int) {
        if (adults != 0) {
            self.guests_count["adult_guest"] = adults
        }
        
        if (childs != 0) {
            self.guests_count["child_guest"] = childs
        }
        
        if (babies != 0) {
            self.guests_count["baby_guest"] = babies
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
