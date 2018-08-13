//
//  PhoneNumberTextfield.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 05.03.18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class PhoneNumberTextfield: UITextField, UITextFieldDelegate {
    
    private let lineView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        addSubview(lineView)
        lineView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        placeholder = "Номер телефона"
        keyboardType = .phonePad
        sizeToFit()
        font = UIFont.init(name: "OpenSans-Light", size: 16)!
        textColor = Constants.paletteBlackColor
        delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.text = "+7"
        } else {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if str.count < 2 {
            textField.text = "+7"
            return false
        } else {
            return checkPhoneNumberFormat(string: string, str: str)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.selectedTextRange = nil
        if textField.text?.replacingOccurrences(of: " ", with: "") == "+7" {
            textField.text = ""
        }
    }
    
    func checkPhoneNumberFormat(string: String, str: String) -> Bool {
        if string == "" {
            return true
        } else if str.count == 3 {
            self.text = self.text! + " "
        } else if str.count == 7 {
            self.text = self.text! + " "
        } else if str.count == 11 || str.count == 14 {
            self.text = self.text! + " "
        } else if str.count > 16 {
            return false
        }
        return true
    }
}
