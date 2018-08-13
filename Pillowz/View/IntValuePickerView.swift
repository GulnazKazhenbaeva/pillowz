//
//  IntValuePickerView.swift
//  Pillowz
//
//  Created by Samat on 19.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class IntValuePickerView: UIView, UITextFieldDelegate {
    let plusButton = UIButton()
    let minusButton = UIButton()
    
    let plusLabel = UILabel()
    let minusLabel = UILabel()
    let valueTextField = UITextField()
    
    var maxValue:Int?
    var minValue:Int?
    
    var callPickValueClosure = true
    
    var isEnabled = true {
        didSet {
            setEnabled(isEnabled)
        }
    }
    
    var value:Int = 0 {
        didSet {
            setValueText()
            
            if (callPickValueClosure) {
                didPickValueClosure?(value)
            }
            
            if let maxValue = maxValue {
                if value > maxValue {
                    value = maxValue
                    setValueText()

                    return
                }
            }
            
            
            if let minValue = minValue {
                if value < minValue {
                    value = minValue
                    setValueText()

                    return
                }
            }
            
        }
    }
    var additionalText = ""
    var step = 1
    
    var didPickValueClosure:DidPickFieldValueClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(initialValue:Int, step:Int, additionalText:String) {
        super.init(frame: CGRect.zero)
        
        self.addSubview(minusButton)
        minusButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(-15)
            make.width.height.equalTo(56)
        }
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        
        minusButton.addSubview(minusLabel)
        minusLabel.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
            make.width.height.equalTo(27)
        }
        minusLabel.layer.cornerRadius = 13
        minusLabel.layer.borderColor = Constants.paletteVioletColor.cgColor
        minusLabel.layer.borderWidth = 1
        minusLabel.text = "-"
        minusLabel.font = UIFont(name: "OpenSans-Regular", size: 17)
        minusLabel.textColor = Constants.paletteVioletColor
        minusLabel.textAlignment = .center
        minusLabel.contentMode = .center

        self.addSubview(plusButton)
        plusButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(15)
            make.width.height.equalTo(56)
        }
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        
        plusButton.addSubview(plusLabel)
        plusLabel.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
            make.width.height.equalTo(27)
        }
        plusLabel.layer.cornerRadius = 13
        plusLabel.layer.borderColor = Constants.paletteVioletColor.cgColor
        plusLabel.layer.borderWidth = 1
        plusLabel.text = "+"
        plusLabel.font = UIFont(name: "OpenSans-Regular", size: 17)
        plusLabel.textColor = Constants.paletteVioletColor
        plusLabel.textAlignment = .center
        plusLabel.contentMode = .center

        self.addSubview(valueTextField)
        valueTextField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(26)
            make.left.equalTo(minusLabel.snp.right).offset(5)
            make.right.equalTo(plusLabel.snp.left).offset(-5)
        }
        valueTextField.textAlignment = .center
        valueTextField.keyboardType = .numberPad
        valueTextField.delegate = self
        valueTextField.adjustsFontSizeToFitWidth = true
        valueTextField.minimumFontSize = 10
        
        self.minValue = 0
        
        self.value = initialValue
        self.step = step
        self.additionalText = additionalText
        
        self.clipsToBounds = false
        
        setValueText()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if clipsToBounds || isHidden || alpha == 0 {
            return nil
        }
        
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        
        return nil
    }

    func setValueText() {
        valueTextField.text = String(value)+additionalText

        if !isEnabled {
            return
        }
        
        if (value==0) {
            minusButton.isEnabled = false
        } else {
            minusButton.isEnabled = true
        }
        
        minusLabel.textColor = Constants.paletteVioletColor
        minusLabel.layer.borderColor = Constants.paletteVioletColor.cgColor
        plusLabel.textColor = Constants.paletteVioletColor
        plusLabel.layer.borderColor = Constants.paletteVioletColor.cgColor
        
        if value == minValue {
            minusLabel.textColor = Constants.paletteLightGrayColor
            minusLabel.layer.borderColor = Constants.paletteLightGrayColor.cgColor
        }
        
        if value == maxValue {
            plusLabel.textColor = Constants.paletteLightGrayColor
            plusLabel.layer.borderColor = Constants.paletteLightGrayColor.cgColor
        }
    }
    
    @objc func minusTapped() {
        value = value - step
    }
    
    @objc func plusTapped() {
        value = value + step
        
        minusButton.isEnabled = true
    }
    
    
    func setEnabled(_ enabled:Bool) {
        minusButton.isEnabled = enabled
        plusButton.isEnabled = enabled
        valueTextField.isEnabled = enabled
        
        if !enabled {
            minusLabel.textColor = Constants.paletteLightGrayColor
            minusLabel.layer.borderColor = Constants.paletteLightGrayColor.cgColor
            plusLabel.textColor = Constants.paletteLightGrayColor
            plusLabel.layer.borderColor = Constants.paletteLightGrayColor.cgColor
        } else {
            minusLabel.textColor = Constants.paletteVioletColor
            minusLabel.layer.borderColor = Constants.paletteVioletColor.cgColor
            plusLabel.textColor = Constants.paletteVioletColor
            plusLabel.layer.borderColor = Constants.paletteVioletColor.cgColor
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text == "0") {
            textField.text = ""
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text == "") {
            value = 0
        } else {
            let intValue = Int(textField.text!)
            
            if (intValue != nil) {
                value = intValue!
            } else {
                value = 0
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
