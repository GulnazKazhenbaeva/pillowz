//
//  PickerTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 25.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

public typealias DidSelectClosure = () -> Void

class ListPickerTableViewCell: HeaderIncludedTableViewCell, ListPickerViewControllerDelegate, EditableCellDelegate {
    
    var nameLabel = UILabel()
    var didPickListValueClosure:DidPickFieldValueClosure!
    var value:AnyObject? {
        didSet {
            if (value != nil) {
                if (value is Choice) {
                    let choiceValue = value as! Choice
                    nameLabel.text = choiceValue.name
                    recalculateHeightForNameLabel()
                } else {
                    nameLabel.text = value?.description
                    recalculateHeightForNameLabel()
                }
            }
        }
    }
    var didSelectClosure:DidSelectClosure!
    
    var values:[Any]? = []
    var viewController:UIViewController!
    
    var placeholder:String {
        set {
            nameLabel.text = newValue
            recalculateHeightForNameLabel()
        }
        get {
            return nameLabel.text!
        }
    }
    
    var field:Field?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator
        
        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(19)
            make.bottom.equalToSuperview().offset(-17)
        }
        nameLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        nameLabel.clipsToBounds = false
        nameLabel.textColor = Constants.paletteBlackColor
        nameLabel.numberOfLines = 0
    }
    
    func recalculateHeightForNameLabel() {
        let height = nameLabel.text!.height(withConstrainedWidth: nameLabel.frame.size.width, font: nameLabel.font)
        nameLabel.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
    }

    func didPickValue(_ value: AnyObject) {
        self.value = value
        
        if (value is Choice) {
            field?.selectedChoice = value as? Choice
        }
        
        didPickListValueClosure(value)
    }
    
    func didSetValue(value: String) {
        self.value = value as AnyObject
    }
    
    func didSetCustomText(text: String) {
        self.nameLabel.text = text
        recalculateHeightForNameLabel()
    }
    
    func didPickMultipleValues(_ values: [AnyObject]) {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
