//
//  OpenRequestFirstStepViewController.swift
//  Pillowz
//
//  Created by Samat on 17.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class OpenRequestFirstStepViewController: StepViewController, AddressPickerDelegate {
    static let shared = OpenRequestFirstStepViewController()
    
    var lat:Double? = CurrentNewOpenRequestValues.shared.lat {
        didSet {
            UserLastUsedValuesForFieldAutofillingHandler.shared.lat = lat!
            
            let _ = checkIfAllFieldsAreFilled()
        }
    }
    var lon:Double? = CurrentNewOpenRequestValues.shared.lon {
        didSet {
            UserLastUsedValuesForFieldAutofillingHandler.shared.lon = lon!
            
            let _ = checkIfAllFieldsAreFilled()
        }
    }
    var placeID:String? = CurrentNewOpenRequestValues.shared.placeID
    var address:String = UserLastUsedValuesForFieldAutofillingHandler.shared.address {
        didSet {
            UserLastUsedValuesForFieldAutofillingHandler.shared.address = address
            
            let filled = checkIfAllFieldsAreFilled()
            
            if filled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Your code with delay
//                    OpenRequestStepsViewController.shared.pageViewController.dataSource = nil
//                    OpenRequestStepsViewController.shared.pageViewController.dataSource = OpenRequestStepsViewController.shared
                }
            }
        }
    }
    var addressField:Field!
    let crudVM = CreateEditObjectTableViewGenerator()
    var fields:[AnyObject] = []
    var headers:[String] = []

    let chosenCategoryField = Field()
    var chosenCategory:String? = UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory {
        didSet {
            UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory = chosenCategory!
                        
            let filled = checkIfAllFieldsAreFilled()
            
            if filled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Your code with delay
//                    OpenRequestStepsViewController.shared.pageViewController.dataSource = nil
//                    OpenRequestStepsViewController.shared.pageViewController.dataSource = OpenRequestStepsViewController.shared
                }
            }
        }
    }
    
    let rentTypeField = Field()
    var rent_type:RENT_TYPES = UserLastUsedValuesForFieldAutofillingHandler.shared.rentType {
        didSet {
            UserLastUsedValuesForFieldAutofillingHandler.shared.rentType = rent_type
            CurrentNewOpenRequestValues.shared.rentType = rent_type
            rentTypeField.setCustomText(text: Price.getDisplayNameForRentType(rent_type: rent_type, isForPrice: false)["ru"]!)

            CurrentNewOpenRequestValues.shared.startTime = nil
            CurrentNewOpenRequestValues.shared.endTime = nil

            let _ = checkIfAllFieldsAreFilled()
        }
    }

    var adults:Int = CurrentNewOpenRequestValues.shared.guests_count["adult_guest"]! {
        didSet {
            CurrentNewOpenRequestValues.shared.guests_count["adult_guest"] = adults
        }
    }
    var childs:Int = CurrentNewOpenRequestValues.shared.guests_count["child_guest"]! {
        didSet {
            CurrentNewOpenRequestValues.shared.guests_count["child_guest"] = childs
        }
    }
    var babies:Int = CurrentNewOpenRequestValues.shared.guests_count["baby_guest"]! {
        didSet {
            CurrentNewOpenRequestValues.shared.guests_count["baby_guest"] = babies
        }
    }
    let adultsField = Field()
    let childsField = Field()
    let babiesField = Field()
    var delegate:GuestsCountViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        crudVM.viewController = self
        
        initAddressViews()
        initSpaceCategoryInfo()
        initRentTypeInfo()
        initGuestsInfo()
        
        self.crudVM.headers = self.headers
        self.crudVM.object = self.fields as AnyObject
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rent_type = UserLastUsedValuesForFieldAutofillingHandler.shared.rentType
        chosenCategory = UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory
        
        for choice in chosenCategoryField.choices! {
            if (choice.value == chosenCategory) {
                chosenCategoryField.selectedChoice = choice
                chosenCategoryField.setCustomText(text: chosenCategoryField.selectedChoice!.name!)
            }
        }
        
        let _ = checkIfAllFieldsAreFilled()

        self.crudVM.tableView?.reloadData()
    }
    
    override func checkIfAllFieldsAreFilled() -> Bool {
        let filled = (UserLastUsedValuesForFieldAutofillingHandler.shared.address != "" && UserLastUsedValuesForFieldAutofillingHandler.shared.lat != 0 && UserLastUsedValuesForFieldAutofillingHandler.shared.lon != 0 && UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory != "")
        
        OpenRequestStepsViewController.shared.nextButton.isEnabled = filled
        
        if filled {
            OpenRequestStepsViewController.shared.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
        }
        
        return filled
    }
    
    func initAddressViews() {
        addressField = Field()
        addressField.isCustomCellField = true
        let dict = ["delegate":self, "address":self.address] as [String : Any]
        addressField.customCellObject = dict as AnyObject
        addressField.customCellClassString = "AddressPickerTableViewCell"
        
        fields.append(addressField)
        headers.append("Адрес")
    }
    
    func initSpaceCategoryInfo() {
        var choices:[Choice] = []
        
        var selectedChoice:Choice
        
        let fieldsForChoosingCategories = CategoriesHandler.getFieldsForChoosingCategories()

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
        
        //chosenCategory = choices.first!.value!
        //chosenCategoryField.selectedChoice = choices.first!
        if let name = chosenCategoryField.selectedChoice?.name {
            chosenCategoryField.setCustomText(text: name)
        }
        
        
        chosenCategoryField.type = "ChoiceField"
        chosenCategoryField.param_name = "Тип жилья"
        chosenCategoryField.multiLanguageName = ["ru": "Тип жилья", "en":"Тип жилья"]
        chosenCategoryField.choices = choices
        chosenCategoryField.didPickFieldValueClosure = { (newValue) in
            let choice = newValue as! Choice
            
            self.chosenCategory = choice.value!
            
            if (self.chosenCategory == "hotel" || self.chosenCategory == "hostel") && self.rent_type == .MONTHLY {
                self.rent_type = .DAILY
            }
            
            self.chosenCategoryField.setCustomText(text: self.chosenCategoryField.selectedChoice!.name!)
        }
        
        fields.append(chosenCategoryField)
        headers.append("Какой тип жилья?")
    }
    
    func initRentTypeInfo() {
        rentTypeField.param_name = "rent_type"
        rentTypeField.multiLanguageName = ["ru":"Тип периода", "en":"Тип периода"]
        rentTypeField.type = "ChoiceField"
        rentTypeField.didSelectClosure = { () in
            let view = RentTypePickerView()
            
            if self.chosenCategory == "hotel" || self.chosenCategory == "hostel" {
                var rentTypesWithoutMonthly = RENT_TYPES.allValues
                rentTypesWithoutMonthly.removeLast()
                view.rentTypes = rentTypesWithoutMonthly
            }
            
            view.didPickRentTypeClosure = { (rentType) in
                self.rent_type = rentType
            }
            view.show()
        }
        
        fields.append(rentTypeField)
        headers.append("На какой период?")
    }
    
    func initGuestsInfo() {
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
    
    @objc func openMapTapped() {
        let vc = MapAddressPickerViewController()
        
        if (self.lat != nil) {
            let coordinate = CLLocationCoordinate2DMake(self.lat!, self.lon!)
            vc.centerPosition = coordinate
        }
        
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPickAddress(address: String, lat: Double, lon: Double) {
        self.address = address
        
        let dict = ["delegate":self, "address":self.address] as [String : Any]
        addressField.customCellObject = dict as AnyObject
        
        self.lat = lat
        self.lon = lon
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
