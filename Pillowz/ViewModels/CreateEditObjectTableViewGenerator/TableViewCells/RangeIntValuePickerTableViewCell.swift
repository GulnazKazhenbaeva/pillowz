//
//  RangeIntValueTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 27.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

public typealias DidPickRangeValueClosure = (_ minValue: Int?, _ maxValue:Int?) -> Void

class RangeIntValuePickerTableViewCell: HeaderIncludedTableViewCell {
    let minValuePickerTextField = UITextField()
    let maxValuePickerTextField = UITextField()

    var didPickRangeValueClosure:DidPickRangeValueClosure!

    var minInitialValue:Int {
        set {
            minValuePickerTextField.text = String(newValue)
        }
        get {
            if let text = minValuePickerTextField.text, let value = Int(text) {
                return value
            } else {
                return 0
            }
        }
    }
    var maxInitialValue:Int {
        set {
            maxValuePickerTextField.text = String(newValue)
        }
        get {
            if let text = maxValuePickerTextField.text, let value = Int(text) {
                return value
            } else {
                return 0
            }
        }
    }
    
    var minPlaceholder:String {
        set {
            minValuePickerTextField.placeholder = newValue
        }
        get {
            return minValuePickerTextField.placeholder!
        }
    }
    var maxPlaceholder:String {
        set {
            maxValuePickerTextField.placeholder = newValue
        }
        get {
            return maxValuePickerTextField.placeholder!
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(minValuePickerTextField)
        self.contentView.addSubview(maxValuePickerTextField)
        minValuePickerTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(Constants.screenFrame.width/2-Constants.basicOffset*2)
            make.height.equalTo(40)
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        minValuePickerTextField.placeholder = "От"
        minValuePickerTextField.keyboardType = .phonePad
        minValuePickerTextField.font = UIFont.init(name: "OpenSans-Light", size: 16)!

        minValuePickerTextField.addTarget(self, action: #selector(didSelectValue(_:)), for: UIControlEvents.editingChanged)

        maxValuePickerTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.screenFrame.width/2)
            make.width.equalTo(Constants.screenFrame.width/2-Constants.basicOffset*2)
            make.height.equalTo(40)
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        maxValuePickerTextField.placeholder = "До"
        maxValuePickerTextField.keyboardType = .phonePad
        maxValuePickerTextField.font = UIFont.init(name: "OpenSans-Light", size: 16)!

        maxValuePickerTextField.addTarget(self, action: #selector(didSelectValue(_:)), for: UIControlEvents.editingChanged)
    }
    
    @objc func didSelectValue(_ valuePickerTextField:UITextField) {
        let min = Int(minValuePickerTextField.text!)
        let max = Int(maxValuePickerTextField.text!)
        
        didPickRangeValueClosure(min, max)
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
