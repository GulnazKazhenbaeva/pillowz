//
//  EditSpaceViewController.swift
//  Pillowz
//
//  Created by Samat on 07.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class EditSpaceViewController: ValidationViewController, SlidingContainerSliderViewDelegate, TopMostCellListenerDelegate, PhotoPickerDelegate, SaveActionDelegate, MapTableViewCellDelegate, AddressPickerDelegate {
    
    var photoPicker: PhotoPicker!
    
    var space:Space = SpaceEditorManager.sharedInstance.currentEditingSpace!
    var sliderView: SlidingContainerSliderView!

    let crudVM = CreateEditObjectTableViewGenerator()
    var fields:[AnyObject] = []
    var headers:[String] = []
    
    var descriptionIndexPath:IndexPath!
    var fieldsIndexPath:IndexPath!
    var comfortsIndexPath:IndexPath!
    var placeIndexPath:IndexPath!
    var rulesIndexPath:IndexPath!
    var priceIndexPath:IndexPath!
    var indexPaths:[IndexPath] = []
    
    var name:String = ""
    var cancellation_policy:String = ""
    var additional_charges:String = ""
    var spaceDescription:String = ""
    var destination:String = ""
    var infrastructure:String = ""
    var lat:Double = 0
    var lon:Double = 0
    var address:String = ""
    var arrival_time:Int = 0
    var checkout_time:Int = 0
    var spaceFields:[Field]!
    var comforts:[ComfortItem]!
    var rules:Rule!
    
    var ignoreWillDisplayCell:Bool = false
    
    let arrival_and_checkoutField = Field()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.name = space.name
        self.spaceDescription = space.spaceDescription
        self.infrastructure = space.infrastructure
        self.lat = space.lat.doubleValue
        self.lon = space.lon.doubleValue
        self.cancellation_policy = space.cancellation_policy
        self.additional_charges = space.additional_charges
        self.address = space.address
        self.destination = space.destination
        self.arrival_time = space.arrival_time
        self.checkout_time = space.checkout_time
        
        photoPicker = PhotoPicker(viewController: self, allowsMultiplePhotos: true)

        crudVM.viewController = self
        crudVM.options = ["other":"longText", "additional_rule":"longText"]
        generateFields()
        crudVM.headers = headers
        crudVM.object = fields as AnyObject
        //crudVM.hasSaveAction = true
        crudVM.topMostCellListenerDelegate = self
        
        let rightButton: UIButton = UIButton(type: .custom)
        rightButton.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        rightButton.addTarget(self, action: #selector(deleteSpaceTapped), for: .touchUpInside)
        rightButton.frame = CGRect(x:0, y:0, width:35, height:44)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        sliderView = SlidingContainerSliderView(width: Constants.screenFrame.size.width, titles: ["Описание", "Характеристики", "Удобства", "Расположение", "Правила", "Цена"])
        sliderView.sliderDelegate = self
        self.view.addSubview(sliderView)
        sliderView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(50)
        }
        
        crudVM.tableView.snp.removeConstraints()
        crudVM.tableView.snp.updateConstraints { (make) in
            make.top.equalTo(sliderView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        sliderView.selectItemAtIndex(0)
        
        self.view.bringSubview(toFront: self.saveButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (arrival_time != 0 && checkout_time != 0) {
            let fullText = "Заезд после " + String(arrival_time) + ":00, " + "выезд до " + String(checkout_time) + ":00"
            
            arrival_and_checkoutField.setCustomText(text: fullText)
            arrival_and_checkoutField.multiLanguageName = ["ru":fullText, "en":fullText, "kz":fullText]
            
            let cell = self.crudVM.tableView.cellForRow(at: IndexPath(row: fields.count-1, section: 0)) as? ListPickerTableViewCell
            cell?.nameLabel.textColor = Constants.paletteVioletColor
        }
    }
    
    func slidingContainerSliderViewDidPressed(_ slidingtContainerSliderView: SlidingContainerSliderView, atIndex: Int) {
        ignoreWillDisplayCell = true
        
        sliderView.selectItemAtIndex(atIndex)
        
        crudVM.tableView.scrollToRow(at: indexPaths[atIndex], at: .top, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // do stuff 42 seconds later
            self.ignoreWillDisplayCell = false
        }
    }
    
    @objc func deleteSpaceTapped() {
        MBProgressHUD.showAdded(to: self.view, animated: true)

        SpaceAPIManager.deleteSpace(space: SpaceEditorManager.sharedInstance.currentEditingSpace!) { (responseObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)

            if (error == nil) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func generateFields() {
        descriptionIndexPath = IndexPath(row: 0, section: 0)
        
        fields = []
        headers = []

        let uploadPhotosField = Field()
        uploadPhotosField.isCustomCellField = true
        uploadPhotosField.customCellObject = ["VC":self, "Space":self.space] as AnyObject
        uploadPhotosField.customCellClassString = "PhotosTableViewCell"
        fields.append(uploadPhotosField)
        headers.append("")

        let nameField = Field()
        nameField.param_name = "name"
        nameField.multiLanguageName = ["ru": "Название", "en":"Название"]
        nameField.value = self.name
        nameField.didPickFieldValueClosure = { (newValue) in
            let name = newValue as! String
            self.name = name
            nameField.value = newValue as! String
            self.dataChanged = true
        }
        nameField.type = "CharField"
        fields.append(nameField)
        headers.append("Название")

        let spaceDescriptionField = Field()
        spaceDescriptionField.param_name = "spaceDescription"
        spaceDescriptionField.multiLanguageName = ["ru": "Описание", "en":"Описание"]
        spaceDescriptionField.value = self.spaceDescription
        spaceDescriptionField.didPickFieldValueClosure = { (newValue) in
            let spaceDescription = newValue as! String
            self.spaceDescription = spaceDescription
            spaceDescriptionField.value = newValue as! String
            self.dataChanged = true
        }
        spaceDescriptionField.type = "CharField"
        fields.append(spaceDescriptionField)
        headers.append("Описание")

        let infrastructureField = Field()
        infrastructureField.param_name = "infrastructure"
        infrastructureField.multiLanguageName = ["ru": "Инфраструктура", "en":"Инфраструктура"]
        infrastructureField.value = self.infrastructure
        infrastructureField.didPickFieldValueClosure = { (newValue) in
            let infrastructure = newValue as! String
            self.infrastructure = infrastructure
            infrastructureField.value = newValue as! String
            self.dataChanged = true
        }
        infrastructureField.type = "CharField"
        fields.append(infrastructureField)
        headers.append("Инфраструктура")

        fieldsIndexPath = IndexPath(row: fields.count, section: 0)

        let fieldsHeaderField = Field()
        fieldsHeaderField.isCustomCellField = true
        fieldsHeaderField.param_name = "fieldsHeaderField"
        fieldsHeaderField.customCellObject = "Укажите характеристики Вашего жилья" as AnyObject
        fieldsHeaderField.customCellClassString = "HeaderTextTableViewCell"
        fields.append(fieldsHeaderField)
        headers.append("")

        if (SpaceEditorManager.sharedInstance.currentEditingSpace!.fields != nil) {
            spaceFields = SpaceEditorManager.sharedInstance.currentEditingSpace!.fields!
            fields.append(contentsOf: spaceFields as [AnyObject])
            for spaceField in spaceFields {
                if (!spaceField.shouldAddHeader()) {
                    headers.append("")
                } else {
                    headers.append(spaceField.name!)
                }
            }
        }
        
        comfortsIndexPath = IndexPath(row: fields.count, section: 0)

        comforts = SpaceEditorManager.sharedInstance.currentEditingSpace!.comforts!
        fields.append(contentsOf: comforts as [AnyObject])
        headers.append("Удобства")
        for _ in 0..<comforts.count-1 {
            headers.append("")
        }
        
        placeIndexPath = IndexPath(row: fields.count, section: 0)
        
        let mapField = Field()
        mapField.isCustomCellField = true
        mapField.customCellObject = ["VC":self, "lat":self.lat, "lon":self.lon] as AnyObject
        mapField.customCellClassString = "MapTableViewCell"
        fields.append(mapField)
        headers.append("На карте")
        
        let destinationField = Field()
        destinationField.param_name = "destination"
        destinationField.multiLanguageName = ["ru": "Расскажите как лучше добраться", "en":"Расскажите как лучше добраться"]
        destinationField.value = self.destination
        destinationField.didPickFieldValueClosure = { (newValue) in
            let destination = newValue as! String
            self.destination = destination
            destinationField.value = newValue as! String
            self.dataChanged = true
        }
        destinationField.type = "CharField"
        fields.append(destinationField)
        headers.append("Как добраться")
        
        rulesIndexPath = IndexPath(row: fields.count, section: 0)

        let rulesHeaderField = Field()
        rulesHeaderField.isCustomCellField = true
        rulesHeaderField.param_name = "rulesHeaderField"
        rulesHeaderField.customCellObject = "Вы устанаваливаетет правила Вашего жилья, которые гости должны будут принять, если хотят арендовать Ваше жилье." as AnyObject
        rulesHeaderField.customCellClassString = "HeaderTextTableViewCell"
        fields.append(rulesHeaderField)
        headers.append("")

        self.rules = self.space.rule!
        let rulesFields = CategoriesHandler.getFieldsOfObject(object: self.rules, shouldControlObject: true).0 as [AnyObject]
        fields.append(contentsOf: rulesFields)
        for rulesField in rulesFields {
            if (rulesField as! Field).type != "CharField" {
                headers.append("")
            } else {
                headers.append((rulesField as! Field).name!)
            }
        }
        for fieldAsAnyobject in rulesFields {
            let field = fieldAsAnyobject as! Field
//            field.didPickFieldValueClosure = { (newValue) in
//                self.rules.setValue(newValue, forKey: property)
//                field.value = String(describing: newValue)
//            }
        }
        
        priceIndexPath = IndexPath(row: fields.count, section: 0)

        let pricesHeaderField = Field()
        pricesHeaderField.isCustomCellField = true
        pricesHeaderField.param_name = "pricesHeaderField"
        pricesHeaderField.customCellObject = "Выберите наиболее подходящую Вам форму аренды и задайте цену" as AnyObject
        pricesHeaderField.customCellClassString = "HeaderTextTableViewCell"
        fields.append(pricesHeaderField)
        headers.append("")

        for price in space.prices! {
            let priceField = Field()
            priceField.type = "IntegerField"
            
            if (price.price != nil) {
                priceField.value = String(price.price!)
            } else {
                
            }
            priceField.param_name = String(describing: price.rent_type?.rawValue)
            priceField.multiLanguageName = ["ru":"не сдается", "en":"не сдается"]
            priceField.multiLanguageUnit = ["ru":"₸", "en":"₸"]
            priceField.isInput = true
            priceField.didPickFieldValueClosure = { (newValue) in
                price.price = newValue as? Int
                priceField.value = String(describing: newValue)
                self.dataChanged = true
            }
            fields.append(priceField)
            headers.append(price.rent_type_display!["ru"]!)
        }
        
        let cancellation_policyField = Field()
        cancellation_policyField.param_name = "cancellation_policy"
        cancellation_policyField.multiLanguageName = ["ru": "Правила отмены бронирования", "en":"Правила отмены бронирования"]
        cancellation_policyField.value = self.cancellation_policy
        cancellation_policyField.didPickFieldValueClosure = { (newValue) in
            let cancellation_policy = newValue as! String
            self.cancellation_policy = cancellation_policy
            cancellation_policyField.value = newValue as! String
            self.dataChanged = true
        }
        cancellation_policyField.type = "CharField"
        fields.append(cancellation_policyField)
        headers.append("Правила отмены бронирования")

        let additional_chargesField = Field()
        additional_chargesField.param_name = "additional_charges"
        additional_chargesField.multiLanguageName = ["ru": "Дополнительные сборы", "en":"Дополнительные сборы"]
        additional_chargesField.value = self.additional_charges
        additional_chargesField.didPickFieldValueClosure = { (newValue) in
            let additional_charges = newValue as! String
            self.additional_charges = additional_charges
            additional_chargesField.value = newValue as! String
            self.dataChanged = true
        }
        additional_chargesField.type = "CharField"
        fields.append(additional_chargesField)
        headers.append("Дополнительные сборы")

        
        arrival_and_checkoutField.type = "ChoiceField"
        arrival_and_checkoutField.param_name = "arrival_and_checkout"
        arrival_and_checkoutField.multiLanguageName = ["ru": "Прибытие и выезд", "en":"Период"]
        arrival_and_checkoutField.didSelectClosure = { () in
            let arrival_and_checkoutVC = ArrivalAndCheckoutViewController()
            arrival_and_checkoutVC.saveArrivalAndCheckoutClosure = { (arrival_time, checkout_time) in
                self.arrival_time = arrival_time
                self.checkout_time = checkout_time
                self.dataChanged = true
                //self.arrival_and_checkoutField.setCustomText(text: Price.getDisplayNameForRentType(rent_type: self.rent_type!, isForPrice: false)["ru"]!)
                arrival_and_checkoutVC.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(arrival_and_checkoutVC, animated: true)
        }
        fields.append(arrival_and_checkoutField)
        headers.append("Прибытие и выезд")

        
        indexPaths.append(descriptionIndexPath)
        indexPaths.append(fieldsIndexPath)
        indexPaths.append(comfortsIndexPath)
        indexPaths.append(placeIndexPath)
        indexPaths.append(rulesIndexPath)
        indexPaths.append(priceIndexPath)
    }
    
    func willDisplayCellAtIndex(_ index: Int) {
        if (!ignoreWillDisplayCell) {
            for indexPath in indexPaths {
                if indexPath.row==index {
                    sliderView.selectItemAtIndex(indexPaths.index(of: indexPath)!)
                }
            }
        }
    }
    
    func didPickPhoto(image: UIImage) {
        
    }
    
    override func saveWithAPI() {
        actionButtonTapped()
    }
    
    override func isValid() -> Bool {
        
        
        return true
    }
        
    func actionButtonTapped() {
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        
        /*SpaceAPIManager.createSpace(space_id: space.space_id.intValue, name: name, cancellation_policy: cancellation_policy, additional_charges: additional_charges, arrival_time:arrival_time, checkout_time:checkout_time, description: spaceDescription, destination: destination, infrastructure: infrastructure, lat: lat, lon: lon, address: address, prices: space.prices!, rules: rules, fields: spaceFields, comforts: comforts)  { (spaceObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }*/
    }
    
    func didPickMultiplePhotos(images: [UIImage]) {
        if (images.count == 0) {
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpaceAPIManager.uploadPhotos(images: images, toSpace: SpaceEditorManager.sharedInstance.currentEditingSpace!) { (imagesArray, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                let cell = self.crudVM.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PhotosTableViewCell
                cell?.space = SpaceEditorManager.sharedInstance.currentEditingSpace!
            }
        }
    }
    
    func didPickAddress(address: String, lat: Double, lon: Double) {
        self.dataChanged = true

        self.address = address
        self.lat = lat
        self.lon = lon
    }
    
    func openMapTapped() {
        let vc = MapAddressPickerViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
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
