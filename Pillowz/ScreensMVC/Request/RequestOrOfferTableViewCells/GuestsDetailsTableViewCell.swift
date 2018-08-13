//
//  GuestsDetailsTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 20.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class GuestsDetailsTableViewCell: HeaderIncludedTableViewCell {
    let adultsLabel = UILabel()
    let childsLabel = UILabel()
    let babiesLabel = UILabel()

    var guests_count:[String:Int]! {
        didSet {
            adultsLabel.text = String(guests_count["adult_guest"] as! Int) + " взрослых"
            childsLabel.text = String(guests_count["child_guest"] as! Int) + " детей"
            babiesLabel.text = String(guests_count["baby_guest"] as! Int) + " младенцев"
            
            if (guests_count["child_guest"] == 0) {
                childsLabel.isHidden = true
            }
            
            if (guests_count["baby_guest"] == 0) {
                babiesLabel.isHidden = true
            }
        }
    }
    
    override func fillWithObject(object: AnyObject) {
        guests_count = object as! [String:Int]
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let width = (Constants.screenFrame.size.width - 2*Constants.basicOffset)/3
        
        self.contentView.addSubview(adultsLabel)
        adultsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(width)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-5)
        }
        adultsLabel.font = UIFont.init(name: "OpenSans-Regular", size: 15)
        adultsLabel.textColor = Constants.paletteBlackColor

        self.contentView.addSubview(childsLabel)
        childsLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(adultsLabel.snp.centerY)
            make.left.equalTo(adultsLabel.snp.right)
            make.width.equalTo(width)
            make.height.equalTo(20)
        }
        childsLabel.font = UIFont.init(name: "OpenSans-Regular", size: 15)
        childsLabel.textColor = Constants.paletteBlackColor

        self.contentView.addSubview(babiesLabel)
        babiesLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(adultsLabel.snp.centerY)
            make.left.equalTo(childsLabel.snp.right)
            make.width.equalTo(width)
            make.height.equalTo(20)
        }
        babiesLabel.font = UIFont.init(name: "OpenSans-Regular", size: 15)
        babiesLabel.textColor = Constants.paletteBlackColor
    }
    
    required init(coder aDecoder: NSCoder) {
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
