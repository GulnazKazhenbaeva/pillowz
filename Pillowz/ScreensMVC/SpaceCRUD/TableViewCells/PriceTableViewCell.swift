//
//  PriceTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 07.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import BEMCheckBox

class PriceTableViewCell: HeaderIncludedTableViewCell {
    let valuePickerTextField = UITextField()
    let unitLabel = UILabel()
    let valuePickerSwitch = BEMCheckBox()

    var didPickValueClosure:DidPickIntValueClosure!
    var initialValue:Int? {
        set {
            if (newValue != nil && newValue != 0) {
                valuePickerTextField.text = String(describing: newValue!)
                valuePickerSwitch.on = true
            } else {
                valuePickerTextField.text = ""
                valuePickerSwitch.on = false
            }
        }
        get {
            return Int(valuePickerTextField.text!)!
        }
    }
    
    var placeholder:String {
        set {
            valuePickerTextField.placeholder = newValue
        }
        get {
            return valuePickerTextField.placeholder!
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(unitLabel)
        unitLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset-50)
            make.width.equalTo(70)
            make.height.equalTo(40)
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
        }
        unitLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        unitLabel.textColor = Constants.paletteBlackColor
        unitLabel.textAlignment = .right
        unitLabel.text = "₸"
        
        self.contentView.addSubview(valuePickerTextField)
        valuePickerTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalTo(unitLabel.snp.left).offset(-8)
            make.height.equalTo(40)
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
        }
        valuePickerTextField.keyboardType = .numberPad
        valuePickerTextField.addTarget(self, action: #selector(didSelectValue(_:)), for: UIControlEvents.editingChanged)
        valuePickerTextField.placeholder = "не сдается"
        valuePickerTextField.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        valuePickerTextField.textColor = Constants.paletteBlackColor

        
        self.contentView.addSubview(valuePickerSwitch)
        valuePickerSwitch.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalTo(valuePickerTextField.snp.centerY)
        }
        valuePickerSwitch.tintColor = Constants.paletteVioletColor
        valuePickerSwitch.onTintColor = Constants.paletteVioletColor
        valuePickerSwitch.onCheckColor = .white
        valuePickerSwitch.onAnimationType = .fill
        valuePickerSwitch.offAnimationType = .fill
        valuePickerSwitch.boxType = .square
        valuePickerSwitch.onFillColor = Constants.paletteVioletColor
        valuePickerSwitch.addTarget(self, action: #selector(didSelectCheckboxValue(_:)), for: UIControlEvents.valueChanged)
    }
    
    @objc func didSelectCheckboxValue(_ valuePickerSwitch:BEMCheckBox) {
        if valuePickerSwitch.on {
            valuePickerTextField.isEnabled = true
            valuePickerTextField.becomeFirstResponder()
        } else {
            didPickValueClosure(0)
            valuePickerTextField.isEnabled = false
            valuePickerTextField.text = ""
        }
    }
    
    @objc func didSelectValue(_ valuePickerTextField:UITextField) {
        if (valuePickerTextField.text=="") {
            didPickValueClosure(0)
            valuePickerSwitch.on = false
        } else {
            didPickValueClosure(Int(valuePickerTextField.text!)!)
            valuePickerSwitch.on = true
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
