
//
//  RequestInfoTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 10.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class RequestInfoTableViewCell: UITableViewCell {
    
    var guestIcon = UIImageView()
    var numberOfGuestsLabel = UILabel()
    
    var clockIcon = UIImageView()
    var numberOfDaysLabel = UILabel()
    var periodLabel = UILabel()
    
    var priceIcon = UIImageView()
    var priceLabel = UILabel()
    
    var timeLabel = UILabel()
    
    let ownerPriceLabel = UILabel()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteLightGrayColor
        label.font = UIFont.init(name: "OpenSans-Light", size: 12)!
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let labelArray = [numberOfGuestsLabel, priceLabel, numberOfDaysLabel]
        for label in labelArray {
            label.font = UIFont.init(name: "OpenSans-Regular", size: 17)
            label.textColor = UIColor.init(hexString: "333333")
        }
        
        guestIcon.image = #imageLiteral(resourceName: "guestBlack")
        guestIcon.contentMode = .scaleAspectFill
        contentView.addSubview(guestIcon)
        guestIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(31)
            make.height.equalTo(20)
        }
        
        contentView.addSubview(numberOfGuestsLabel)
        numberOfGuestsLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(guestIcon)
            make.left.equalTo(guestIcon.snp.right).offset(10)
            make.height.equalTo(18)
        }
        
        let leftSpace = (UIScreen.main.bounds.width - 20) * 0.51
        clockIcon.image = #imageLiteral(resourceName: "clockBlack")
        clockIcon.contentMode = .scaleAspectFill
        contentView.addSubview(clockIcon)
        clockIcon.snp.makeConstraints { (make) in
            //make.left.equalTo(numberOfGuestsLabel.snp.right).offset(60)
            make.left.equalToSuperview().offset(leftSpace)
            make.centerY.equalTo(guestIcon)
            make.width.height.equalTo(20)
        }
        
        contentView.addSubview(numberOfDaysLabel)
        numberOfDaysLabel.snp.makeConstraints { (make) in
            make.left.equalTo(clockIcon.snp.right).offset(10)
            make.centerY.equalTo(clockIcon)
            make.height.equalTo(18)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        numberOfDaysLabel.adjustsFontSizeToFitWidth = true
        numberOfDaysLabel.minimumScaleFactor = 0.5
        
        periodLabel.textColor = UIColor.init(hexString: "5263FF")
        periodLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)
        contentView.addSubview(periodLabel)
        periodLabel.snp.makeConstraints { (make) in
            make.top.equalTo(numberOfDaysLabel.snp.bottom).offset(5)
            make.left.right.equalTo(numberOfDaysLabel)
        }
        periodLabel.numberOfLines = 0
        
        priceIcon.image = #imageLiteral(resourceName: "tenge")
        priceIcon.contentMode = .scaleAspectFill
        contentView.addSubview(priceIcon)
        priceIcon.snp.makeConstraints { (make) in
            make.top.equalTo(guestIcon.snp.bottom).offset(20)
            make.centerX.equalTo(guestIcon)
            make.width.equalTo(14)
            make.height.equalTo(16)
        }
        
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceIcon)
            make.left.equalTo(numberOfGuestsLabel)
            make.height.equalTo(18)
        }
        
        contentView.addSubview(ownerPriceLabel)
        ownerPriceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceIcon.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(18)
        }
        ownerPriceLabel.textColor = UIColor.init(hexString: "#FA533C")
        ownerPriceLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)
        ownerPriceLabel.clipsToBounds = false
        
        timeLabel.setLightGrayStyle()
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(ownerPriceLabel.snp.bottom).offset(25)
            make.bottom.equalToSuperview().offset(-15)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(18)
        }
        
        self.contentView.addSubview(idLabel)
        idLabel.snp.makeConstraints { (make) in
            make.top.equalTo(ownerPriceLabel.snp.bottom).offset(25)
            make.bottom.equalToSuperview().offset(-15)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(18)
        }
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
