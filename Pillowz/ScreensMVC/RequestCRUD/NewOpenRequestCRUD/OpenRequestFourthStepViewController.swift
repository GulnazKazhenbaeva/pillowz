//
//  OpenRequestThirdStepViewController.swift
//  Pillowz
//
//  Created by Samat on 17.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class OpenRequestFourthStepViewController: StepViewController, UITextFieldDelegate {
    static let shared = OpenRequestFourthStepViewController()
    
    let priceTextField = PillowTextField(keyboardType: .numberPad, placeholder: "Укажите цену")
    
    let priceHeaderLabel = UILabel()
    
    let tengeSignLabel = UILabel()
    
    let bargainLabel = UILabel()
    let bargainPickerSwitch = UISwitch()
    
    var price:Int = CurrentNewOpenRequestValues.shared.price {
        didSet {
            CurrentNewOpenRequestValues.shared.price = price
            let _ = checkIfAllFieldsAreFilled()
        }
    }
    
    let dateFormatter = DateFormatter()
    
    let infoBackgroundView = UIView()
    
    let categoryLabel = UILabel()
    
    var clockIcon = UIImageView()
    var numberOfDaysLabel = UILabel()
    var periodLabel = UILabel()
    
    let addressIcon = UIImageView()
    let addressLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initViews()
    }

    override func checkIfAllFieldsAreFilled() -> Bool {
        let filled = (price != 0)
        
        OpenRequestStepsViewController.shared.nextButton.isEnabled = filled

        if filled {
            OpenRequestStepsViewController.shared.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
        } else {
            OpenRequestStepsViewController.shared.nextButton.backgroundColor = Constants.paletteLightGrayColor
        }
        
        return filled
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OpenRequestStepsViewController.shared.nextButton.setTitle("создать", for: .normal)
        
        let _ = checkIfAllFieldsAreFilled()
        
        var categoryName:String?
        
        for category in CategoriesHandler.sharedInstance.categories {
            if category.value == UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory {
                categoryName = category.name
            }
        }
        
        self.categoryLabel.text = categoryName
        
        self.addressLabel.text = UserLastUsedValuesForFieldAutofillingHandler.shared.address
        
        self.numberOfDaysLabel.text = Request.getPeriodString(start_time: CurrentNewOpenRequestValues.shared.startTime, end_time: CurrentNewOpenRequestValues.shared.endTime, rent_type: CurrentNewOpenRequestValues.shared.rentType)
        
        let periodText = Request.getStringForRentType(CurrentNewOpenRequestValues.shared.rentType, startTime: CurrentNewOpenRequestValues.shared.startTime!, endTime: CurrentNewOpenRequestValues.shared.endTime!, shouldGoToNextLine: false, includeRentTypeText: false)
        self.periodLabel.text = periodText
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        OpenRequestStepsViewController.shared.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
        OpenRequestStepsViewController.shared.nextButton.setTitle("продолжить", for: .normal)
        
        OpenRequestStepsViewController.shared.nextButton.isEnabled = true
    }
    
    func initViews() {
        self.view.addSubview(infoBackgroundView)
        infoBackgroundView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(170)
        }
        infoBackgroundView.backgroundColor = UIColor(hexString: "#F3F3F3")
        
        infoBackgroundView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalToSuperview().offset(18)
            make.height.equalTo(28)
        }
        categoryLabel.textColor = Constants.paletteBlackColor
        categoryLabel.font = UIFont(name: "OpenSans-Regular", size: 17)
        
        
        clockIcon.image = #imageLiteral(resourceName: "clockBlack")
        clockIcon.contentMode = .scaleAspectFill
        infoBackgroundView.addSubview(clockIcon)
        clockIcon.snp.makeConstraints { (make) in
            make.top.equalTo(categoryLabel.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.height.equalTo(20)
        }
        
        infoBackgroundView.addSubview(numberOfDaysLabel)
        numberOfDaysLabel.snp.makeConstraints { (make) in
            make.left.equalTo(clockIcon.snp.right).offset(10)
            make.centerY.equalTo(clockIcon)
            make.height.equalTo(18)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        periodLabel.textColor = Constants.paletteVioletColor
        periodLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)
        infoBackgroundView.addSubview(periodLabel)
        periodLabel.snp.makeConstraints { (make) in
            make.top.equalTo(numberOfDaysLabel.snp.bottom).offset(5)
            make.left.right.equalTo(numberOfDaysLabel)
        }
        periodLabel.numberOfLines = 0

        
        addressIcon.image = #imageLiteral(resourceName: "locationBlackSmall")
        addressIcon.contentMode = .center
        infoBackgroundView.addSubview(addressIcon)
        addressIcon.snp.makeConstraints { (make) in
            make.top.equalTo(periodLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(20)
            make.height.equalTo(24)
        }
        
        infoBackgroundView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(addressIcon.snp.right).offset(10)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalTo(addressIcon.snp.centerY)
            make.height.equalTo(28)
        }
        addressLabel.textColor = Constants.paletteBlackColor
        addressLabel.font = UIFont(name: "OpenSans-Regular", size: 17)
        
        
        self.view.addSubview(priceHeaderLabel)
        priceHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(48)
            make.top.equalTo(infoBackgroundView.snp.bottom).offset(15)
        }
        priceHeaderLabel.textColor = Constants.paletteBlackColor
        priceHeaderLabel.font = UIFont.init(name: "OpenSans-Bold", size: 17)!
        priceHeaderLabel.text = "Укажите цену, которую вы готовы оплатить"
        priceHeaderLabel.numberOfLines = 0
        
        self.view.addSubview(priceTextField)
        priceTextField.snp.makeConstraints { (make) in
            make.top.equalTo(priceHeaderLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(50)
        }
        priceTextField.delegate = self
        if (price != 0) {
            priceTextField.text = price.description
        }
        priceTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        self.view.addSubview(tengeSignLabel)
        tengeSignLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceTextField.snp.top)
            make.bottom.equalTo(priceTextField.snp.bottom)
            make.right.equalTo(priceTextField.snp.right)
        }
        tengeSignLabel.text = "₸"
        tengeSignLabel.font = UIFont(name: "OpenSans-SemiBold", size: 16)
        tengeSignLabel.textColor = Constants.paletteBlackColor
        
        self.view.addSubview(bargainLabel)
        bargainLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-90)
            make.top.equalTo(priceTextField.snp.bottom).offset(24)
            make.height.equalTo(26)
        }
        bargainLabel.clipsToBounds = false
        bargainLabel.font = UIFont(name: "OpenSans-Regular", size: 17)
        bargainLabel.textColor = Constants.paletteBlackColor
        bargainLabel.text = "Торг"
        
        self.view.addSubview(bargainPickerSwitch)
        bargainPickerSwitch.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.width.equalTo(51)
            make.height.equalTo(31)
            make.centerY.equalTo(bargainLabel.snp.centerY)
        }
        bargainPickerSwitch.onTintColor = Constants.paletteVioletColor
        bargainPickerSwitch.setOn(true, animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, let intPrice = Int(text) {
            price = intPrice
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
