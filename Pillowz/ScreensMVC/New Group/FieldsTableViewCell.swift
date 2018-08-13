//
//  SpaceCharacteristicsTableViewCell.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/24/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class FieldsTableViewCell: HeaderIncludedTableViewCell {
    var fieldNameLabels = [UILabel]()
    var fieldValueLabels = [UILabel]()
    
    var fields: [Field]! {
        didSet {
            setupLabels()
        }
    }
    
    func setupLabels() {
        if (fieldNameLabels.count != 0) {
            return
        }
        
        for label in fieldNameLabels {
            label.removeFromSuperview()
        }
        for label in fieldValueLabels {
            label.removeFromSuperview()
        }
        
        for field in fields {
            //let indexIsFirst = fields.first! === field
            //let indexIsLast = fields.last! === field
            let currentIndex = fields.index(of: field)!
            
            let currentRow = currentIndex/2
            
            let isLeftSide = currentIndex % 2 == 0
            
            let fieldNameLabel = UILabel()
            fieldNameLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)
            fieldNameLabel.textColor = Constants.paletteLightGrayColor
            fieldNameLabel.text = field.name
            self.contentView.addSubview(fieldNameLabel)
            fieldNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(headerLabel.snp.bottom).offset(15 + 62*currentRow)
                make.height.equalTo(15)
                
                if (isLeftSide) {
                    make.left.equalToSuperview().offset(Constants.basicOffset)
                    make.right.equalToSuperview().offset(-Constants.screenFrame.size.width/2-4)
                } else {
                    make.left.equalToSuperview().offset(Constants.screenFrame.size.width/2)
                    make.right.equalToSuperview().offset(-Constants.basicOffset)
                }
            }
            fieldNameLabels.append(fieldNameLabel)
            
            let fieldValueLabel = UILabel()
            fieldValueLabel.font = UIFont.init(name: "OpenSans-Regular", size: 17)
            fieldValueLabel.textColor = Constants.paletteBlackColor

            if (field.type == "ChoiceField") {
                fieldValueLabel.text = field.selectedChoice?.name
            } else if (field.type == "BooleanField") {
                let bool = field.value.toBool()
                if (bool) {
                    fieldValueLabel.text = "да"
                } else {
                    fieldValueLabel.text = "нет"
                }
            } else if (field.type == "InlineField") {
                let firstValue = field.first!.value
                let secondValue = field.second!.value
                
                var totalString = ""
                if (firstValue != "") {
                    totalString = totalString + "от " + firstValue
                }
                
                if (firstValue != "" && secondValue != "") {
                    totalString = totalString + " "
                }
                
                if (secondValue != "") {
                    totalString = totalString + "до " + secondValue
                }
                
                fieldValueLabel.text = totalString
            } else {
                fieldValueLabel.text = field.value
            }
            
            self.contentView.addSubview(fieldValueLabel)
            fieldValueLabel.snp.makeConstraints { (make) in
                make.left.equalTo(fieldNameLabel.snp.left)
                make.right.equalTo(fieldNameLabel.snp.right)
                make.top.equalTo(fieldNameLabel.snp.bottom).offset(5)
                make.height.equalTo(22)
            }
            fieldValueLabels.append(fieldValueLabel)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        headerLabel.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(15)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
