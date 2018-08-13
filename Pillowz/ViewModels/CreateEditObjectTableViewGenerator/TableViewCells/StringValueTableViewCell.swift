//
//  StringValueTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 27.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class StringValueTableViewCell: HeaderIncludedTableViewCell, EditableCellDelegate {
    let valuePickerTextField = UITextField()
    var didPickValueClosure:DidPickFieldValueClosure!
    var initialValue:String {
        set {
            valuePickerTextField.text = newValue
            
            var topSpace:CGFloat
            
            if isSmallHeader {
                topSpace = 0
            } else {
                topSpace = 10
            }
            
            valuePickerTextField.snp.updateConstraints { (make) in
                make.top.equalTo(headerLabel.snp.bottom).offset(topSpace)
            }
        }
        get {
            return valuePickerTextField.text!
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
    
    func didSetValue(value: String) {
        initialValue = value
    }
    
    func didSetCustomText(text: String) {
        initialValue = text
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(valuePickerTextField)
        valuePickerTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.width-Constants.basicOffset*2)
            make.height.equalTo(40)
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        valuePickerTextField.keyboardType = .default
        valuePickerTextField.addTarget(self, action: #selector(didSelectValue(_:)), for: UIControlEvents.editingChanged)
        valuePickerTextField.font = UIFont.init(name: "OpenSans-Light", size: 16)!
    }
    
    @objc func didSelectValue(_ valuePickerTextField:UITextField) {
        didPickValueClosure(valuePickerTextField.text!)
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
