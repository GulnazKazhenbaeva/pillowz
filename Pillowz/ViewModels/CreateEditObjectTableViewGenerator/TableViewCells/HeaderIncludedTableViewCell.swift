//
//  HeaderIncludedTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 24.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class HeaderIncludedTableViewCell: UITableViewCell, FillableCellDelegate {
    let requiredFieldLabel = UILabel()
    
    var headerLabel = UILabel()
    var header:String {
        get {
            return headerLabel.text!
        }
        set {
            if (newValue=="") {
                headerLabel.snp.updateConstraints({ (make) in
                    make.height.equalTo(0)
                    make.top.equalToSuperview().offset(0)
                })
            } else {
                if !isSmallHeader {
                    headerLabel.textColor = Constants.paletteBlackColor
                    headerLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
                } else {
                    headerLabel.textColor = Constants.paletteLightGrayColor
                    headerLabel.font = UIFont(name: "OpenSans-Regular", size: 13)
                }
                
                headerLabel.snp.remakeConstraints({ (make) in
                    make.width.equalTo(newValue.width(withConstraintedHeight: 40, font: headerLabel.font))
                    make.left.equalToSuperview().offset(Constants.basicOffset)

                    if !isSmallHeader {
                        make.height.equalTo(20)
                        make.top.equalToSuperview().offset(20)
                    } else {
                        make.height.equalTo(14)
                        make.top.equalToSuperview().offset(12)
                    }
                })
            }
            
            headerLabel.text = newValue
        }
    }
    
    var isSmallHeader = false
    
    func fillWithObject(object: AnyObject) {
        let headerString = object as! String
        header = headerString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.contentView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(29)
        }
        headerLabel.textColor = Constants.paletteBlackColor
        headerLabel.font = UIFont(name: "OpenSans-Bold", size: 17)
        
        self.contentView.addSubview(requiredFieldLabel)
        requiredFieldLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerLabel.snp.right)
            make.width.height.equalTo(12)
            make.top.equalTo(headerLabel.snp.top)
        }
        requiredFieldLabel.text = "*"
        requiredFieldLabel.textColor = Constants.paletteBlackColor
        requiredFieldLabel.font = UIFont(name: "OpenSans-Regular", size: 15)
        requiredFieldLabel.isHidden = true
        
        self.contentView.clipsToBounds = false
    }
        
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
