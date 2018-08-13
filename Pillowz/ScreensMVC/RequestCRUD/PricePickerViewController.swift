//
//  PricePickerViewController.swift
//  Pillowz
//
//  Created by Samat on 17.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

public typealias SavePriceWithAPIClosure = (_ price: Int, _ bargain: Bool) -> Void

class PricePickerViewController: ValidationViewController, UITextFieldDelegate {
    let priceTextField = PillowTextField(keyboardType: .numberPad, placeholder: "Укажите цену")
    
    let priceHeaderLabel = UILabel()
    
    var savePriceWithAPIClosure:SavePriceWithAPIClosure?

    let tengeSignLabel = UILabel()
    
    let bargainLabel = UILabel()
    let bargainPickerSwitch = UISwitch()
    
    let newPricePickerView = IntValuePickerView(initialValue: 500, step: 500, additionalText: "₸")
    let newPriceLabel = UILabel()
    
    var isPersonalRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(priceHeaderLabel)
        priceHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(64 + 10)
        }
        priceHeaderLabel.textColor = Constants.paletteBlackColor
        priceHeaderLabel.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        if (isPersonalRequest) {
            priceHeaderLabel.text = "Предложить свою цену"
        } else {
            priceHeaderLabel.text = "Цена"
        }
        
        self.view.addSubview(priceTextField)
        priceTextField.snp.makeConstraints { (make) in
            make.top.equalTo(priceHeaderLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(50)
        }
        priceTextField.delegate = self
        
        self.view.addSubview(tengeSignLabel)
        tengeSignLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceTextField.snp.top)
            make.bottom.equalTo(priceTextField.snp.bottom)
            make.right.equalTo(priceTextField.snp.right)
        }
        tengeSignLabel.text = "₸"
        tengeSignLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 16)!
        tengeSignLabel.textColor = Constants.paletteBlackColor
        
        self.view.addSubview(newPriceLabel)
        newPriceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-90)
            make.centerY.equalTo(tengeSignLabel.snp.centerY)
            make.height.equalTo(26)
        }
        newPriceLabel.clipsToBounds = false
        newPriceLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        newPriceLabel.textColor = Constants.paletteBlackColor
        newPriceLabel.text = "Моя цена"
        
        self.view.addSubview(newPricePickerView)
        newPricePickerView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalTo(tengeSignLabel.snp.centerY)
            make.width.equalTo(138)
            make.height.equalTo(20)
        }
        
        newPriceLabel.isHidden = !isPersonalRequest
        newPricePickerView.isHidden = !isPersonalRequest
        priceTextField.isHidden = isPersonalRequest
        tengeSignLabel.isHidden = isPersonalRequest

        self.view.addSubview(bargainLabel)
        bargainLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-90)
            make.top.equalTo(priceTextField.snp.bottom).offset(24)
            make.height.equalTo(26)
        }
        bargainLabel.clipsToBounds = false
        bargainLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
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
    
    override func saveWithAPI() {
        if (!isPersonalRequest) {
            savePriceWithAPIClosure?(Int(priceTextField.text!)!, bargainPickerSwitch.isOn)
        } else {
            savePriceWithAPIClosure?(newPricePickerView.value, bargainPickerSwitch.isOn)
        }
    }
    
    override func isValid() -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        dataChanged = true
                
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
