//
//  IntValuePickerTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 25.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class IntValuePickerTableViewCell: HeaderIncludedTableViewCell {
    let valuePickerView = IntValuePickerView(initialValue: 0, step: 1, additionalText: "")
    var nameLabel = UILabel()

    var didPickValueClosure:DidPickFieldValueClosure! {
        didSet {
            valuePickerView.didPickValueClosure = didPickValueClosure
        }
    }
    var initialValue:Int? {
        set {
            if (newValue == nil) {
                valuePickerView.value = 0
            } else {
                valuePickerView.value = newValue!
            }
        }
        get {
            return valuePickerView.value
        }
    }
    
    var placeholder:String {
        set {
            nameLabel.text = newValue
        }
        get {
            return nameLabel.text!
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-110)
            make.height.equalTo(19)
            make.bottom.equalToSuperview().offset(-16)
        }
        nameLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        nameLabel.clipsToBounds = false

        self.contentView.addSubview(valuePickerView)
        valuePickerView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(97)
            make.height.equalTo(40)
            make.centerY.equalTo(nameLabel.snp.centerY)
        }
        valuePickerView.didPickValueClosure = self.didPickValueClosure
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
