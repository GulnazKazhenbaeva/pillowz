//
//  ArrivalAndCheckoutViewController.swift
//  Pillowz
//
//  Created by Samat on 02.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

public typealias SaveArrivalAndCheckoutClosure = (_ arrival_time: Int, _ checkout_time: Int) -> Void


class ArrivalAndCheckoutViewController: ValidationViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    var saveArrivalAndCheckoutClosure:SaveArrivalAndCheckoutClosure?

    var arrival_time:Int = 0 {
        didSet {
            startTimeTextField.text = "после " + String(arrival_time) + ":00"
        }
    }
    var checkout_time:Int = 0 {
        didSet {
            endTimeTextField.text = "до " + String(checkout_time) + ":00"
        }
    }
    
    let startTimeTextField = UITextField()
    let endTimeTextField = UITextField()
    
    let startLabel = UILabel()
    let endLabel = UILabel()

    let pickerView = UIPickerView()
    
    var hours:[Int] = []

    var pickingStartTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(startTimeTextField)
        startTimeTextField.isEnabled = true
        startTimeTextField.inputView = pickerView
        startTimeTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width/2-Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        startTimeTextField.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        startTimeTextField.textColor = Constants.paletteVioletColor
        startTimeTextField.textAlignment = .right
        startTimeTextField.delegate = self
        
        self.view.addSubview(startLabel)
        startLabel.text = "Заезд"
        startLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(startTimeTextField)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(19)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        startLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        startLabel.textColor = Constants.paletteBlackColor
        
        self.view.addSubview(endTimeTextField)
        endTimeTextField.inputView = pickerView
        endTimeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(startTimeTextField.snp.bottom).offset(20)
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(Constants.screenFrame.size.width/2-Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        endTimeTextField.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        endTimeTextField.textColor = Constants.paletteVioletColor
        endTimeTextField.textAlignment = .right
        endTimeTextField.delegate = self
        
        self.view.addSubview(endLabel)
        endLabel.text = "Выезд"
        endLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(endTimeTextField)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(19)
            make.width.equalTo(Constants.screenFrame.size.width/2)
        }
        endLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        endLabel.textColor = Constants.paletteBlackColor

        if arrival_time == 0 && checkout_time == 0 {
            startTimeTextField.text = "не выбрано"
            endTimeTextField.text = "не выбрано"
        }
        
        pickerView.dataSource = self
        pickerView.delegate = self

        for i in 0..<24 {
            hours.append(i)
        }
    }
    
    override func saveWithAPI() {
        saveArrivalAndCheckoutClosure?(arrival_time, checkout_time)
    }
    
    override func isValid() -> Bool {
        if (arrival_time == 0 && checkout_time == 0) {
            return false
        }
                
        return true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hours.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(hours[row])+":00"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickingStartTime) {
            arrival_time = hours[pickerView.selectedRow(inComponent: 0)]
        } else {
            checkout_time = hours[pickerView.selectedRow(inComponent: 0)]
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField === startTimeTextField) {
            pickingStartTime = true
            arrival_time = 12
        } else {
            pickingStartTime = false
            checkout_time = 12
        }
        
        pickerView.selectRow(12, inComponent: 0, animated: false)
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
