//
//  OpenRequestThirdStepViewController.swift
//  Pillowz
//
//  Created by Samat on 17.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class OpenRequestFourthStepViewController: StepViewController, DateAndTimePickerViewControllerDelegate, UITextFieldDelegate {
    static let shared = OpenRequestFourthStepViewController()

    let priceTextField = PillowTextField(keyboardType: .numberPad, placeholder: "Укажите цену")
    
    let priceHeaderLabel = UILabel()
    
    let tengeSignLabel = UILabel()
    
    let bargainLabel = UILabel()
    let bargainPickerSwitch = UISwitch()
    
    let fromLabel = UILabel()
    let fromField = UIButton()
    
    let tillLabel = UILabel()
    let tillField = UIButton()
    
    let fromTillDatesHeaderLabel = UILabel()
    
    var start_time:Int? = CurrentNewOpenRequestValues.shared.startTime {
        didSet {
            CurrentNewOpenRequestValues.shared.startTime = start_time
            let _ = checkIfAllFieldsAreFilled()
        }
    }
    var end_time:Int? = CurrentNewOpenRequestValues.shared.endTime {
        didSet {
            CurrentNewOpenRequestValues.shared.endTime = end_time
            
            let _ = checkIfAllFieldsAreFilled()
        }
    }
    
    var rent_type:RENT_TYPES = CurrentNewOpenRequestValues.shared.rentType

    var price:Int = CurrentNewOpenRequestValues.shared.price {
        didSet {
            CurrentNewOpenRequestValues.shared.price = price
            let _ = checkIfAllFieldsAreFilled()
        }
    }
    
    let dateFormatter = DateFormatter()

    var fromDate:Date? {
        didSet {
            if (fromDate != nil) {
                self.fromField.setTitle(dateFormatter.string(from: fromDate!), for: .normal)
                
                start_time = Int(fromDate!.timeIntervalSince1970)
                
                if (rent_type == .HALFDAY) {
                    tillDate = fromDate?.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
                } else if (rent_type == .MONTHLY) {
                    tillDate = fromDate?.add(.init(seconds: 0, minutes: 0, hours:0, days: 0, weeks: 0, months: 1, years: 0))
                }
            } else {
                self.fromField.setTitle("не выбрано", for: .normal)
            }
        }
    }
    var tillDate:Date? {
        didSet {
            if (tillDate != nil) {
                self.tillField.setTitle(dateFormatter.string(from: tillDate!), for: .normal)
                
                end_time = Int(tillDate!.timeIntervalSince1970)
            } else {
                self.tillField.setTitle("не выбрано", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        initViews()
    }

    override func checkIfAllFieldsAreFilled() -> Bool {
        let filled = (price != 0 && start_time != nil && end_time != nil)
        
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
        
        if let startTime = UserLastUsedValuesForFieldAutofillingHandler.shared.startTime {
            fromDate = Date(timeIntervalSince1970: TimeInterval(startTime))
        }
        
        if let endTime = UserLastUsedValuesForFieldAutofillingHandler.shared.endTime {
            tillDate = Date(timeIntervalSince1970: TimeInterval(endTime))
        }
        
        OpenRequestStepsViewController.shared.nextButton.setTitle("создать", for: .normal)
        
        let _ = checkIfAllFieldsAreFilled()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        OpenRequestStepsViewController.shared.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
        OpenRequestStepsViewController.shared.nextButton.setTitle("продолжить", for: .normal)
        
        OpenRequestStepsViewController.shared.nextButton.isEnabled = true
    }
    
    func initViews() {
        self.view.addSubview(fromTillDatesHeaderLabel)
        fromTillDatesHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(25)
        }
        fromTillDatesHeaderLabel.textColor = Constants.paletteBlackColor
        fromTillDatesHeaderLabel.font = UIFont(name: "OpenSans-Bold", size: 17)
        fromTillDatesHeaderLabel.text = "Даты"
        
        self.view.addSubview(fromField)
        fromField.isEnabled = true
        fromField.snp.makeConstraints { (make) in
            make.top.equalTo(fromTillDatesHeaderLabel.snp.bottom).offset(25)
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width/2-Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        fromField.titleLabel?.font = UIFont(name: "OpenSans-Light", size: 16)
        fromField.setTitleColor(Constants.paletteVioletColor, for: .normal)
        fromField.contentHorizontalAlignment = .right
        if (fromDate == nil) {
            fromField.setTitle("не выбрано", for: .normal)
        }
        fromField.addTarget(self, action: #selector(pickDateTapped), for: .touchUpInside)
        
        self.view.addSubview(fromLabel)
        fromLabel.text = "Дата заезда"
        fromLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(fromField)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(19)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        fromLabel.font = UIFont(name: "OpenSans-Light", size: 16)
        fromLabel.textColor = Constants.paletteBlackColor
        
        self.view.addSubview(tillField)
        tillField.snp.makeConstraints { (make) in
            make.top.equalTo(fromField.snp.bottom).offset(20)
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width/2-Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        tillField.titleLabel?.font = UIFont(name: "OpenSans-Light", size: 16)
        tillField.setTitleColor(Constants.paletteVioletColor, for: .normal)
        tillField.contentHorizontalAlignment = .right
        if (tillDate == nil) {
            tillField.setTitle("не выбрано", for: .normal)
        }
        tillField.isHidden = false
        tillField.addTarget(self, action: #selector(pickDateTapped), for: .touchUpInside)
        
        self.view.addSubview(tillLabel)
        tillLabel.text = "Дата выезда"
        tillLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tillField)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(19)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        tillLabel.font = UIFont(name: "OpenSans-Light", size: 16)
        tillLabel.textColor = Constants.paletteBlackColor
        tillLabel.isHidden = false
        
        self.view.addSubview(priceHeaderLabel)
        priceHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalTo(tillLabel.snp.bottom).offset(32)
        }
        priceHeaderLabel.textColor = Constants.paletteBlackColor
        priceHeaderLabel.font = UIFont(name: "OpenSans-Bold", size: 17)
        priceHeaderLabel.text = "Цена"
        
        self.view.addSubview(priceTextField)
        priceTextField.snp.makeConstraints { (make) in
            make.top.equalTo(priceHeaderLabel.snp.bottom).offset(4)
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
        bargainLabel.font = UIFont(name: "OpenSans-Light", size: 16)
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
        
    }
    
    func didPickStartDate(_ startDate: Date, endDate: Date?) {
        fromDate = startDate
        tillDate = endDate
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, let intPrice = Int(text) {
            price = intPrice
        }
    }
    
    @objc func pickDateTapped() {
        OpenRequestStepsViewController.shared.shouldSetFirstAsInitialController = false
        
        let vc = DateAndTimePickerViewController()
        vc.rentType = rent_type
        
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
