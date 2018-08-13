//
//  PriceTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 05.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

public typealias DidPickIntValueClosure = (_ value: Int) -> Void

class IntInputTableViewCell: HeaderIncludedTableViewCell {
    let valuePickerTextField = UITextField()
    let unitLabel = UILabel()
    
    var didPickValueClosure:DidPickIntValueClosure!
    var initialValue:Int? {
        set {
            if (newValue != nil) {
                valuePickerTextField.text = String(describing: newValue!)
            } else {
                valuePickerTextField.text = ""
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
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(70)
            make.height.equalTo(40)
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
        }
        unitLabel.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
        unitLabel.textColor = Constants.paletteBlackColor
        unitLabel.textAlignment = .right

        self.contentView.addSubview(valuePickerTextField)
        valuePickerTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalTo(unitLabel.snp.left).offset(-8)
            make.height.equalTo(40)
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        valuePickerTextField.keyboardType = .numberPad
        valuePickerTextField.addTarget(self, action: #selector(didSelectValue(_:)), for: UIControlEvents.editingChanged)
    }
    
    @objc func didSelectValue(_ valuePickerTextField:UITextField) {
        if (valuePickerTextField.text=="") {
            didPickValueClosure(0)
        } else {
            didPickValueClosure(Int(valuePickerTextField.text!)!)
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
