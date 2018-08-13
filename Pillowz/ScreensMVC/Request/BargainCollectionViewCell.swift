//
//  BargainCollectionViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 16.03.18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class BargainCollectionViewCell: UICollectionViewCell {
    
    let otherUserImageView = UIImageView()
    let myImageView = UIImageView()
    
    let otherUserPriceValueLabel = UILabel()
    let myUserPriceValueLabel = UILabel()
    let newPricePickerView = IntValuePickerView(initialValue: 500, step: 500, additionalText: "₸")
    
    let agreeButton = UIButton()
    let offerNewPriceButton = UIButton()
    
    let youLabel = UILabel()
    let otherUserNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        otherUserImageView.backgroundColor = UIColor.init(hexString: "#C4C4C4")
        otherUserImageView.layer.cornerRadius = 15
        otherUserImageView.clipsToBounds = true
        otherUserImageView.layer.masksToBounds = true
        contentView.addSubview(otherUserImageView)
        otherUserImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.height.equalTo(30)
//            make.height.equalToSuperview().multipliedBy(0.3)
//            make.width.equalTo(otherUserImageView.snp.height)
        }
        otherUserImageView.layer.borderWidth = 1
        otherUserImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
        
        myImageView.backgroundColor = UIColor.init(hexString: "#C4C4C4")
        myImageView.layer.cornerRadius = 15
        myImageView.clipsToBounds = true
        myImageView.layer.masksToBounds = true
        contentView.addSubview(myImageView)
        myImageView.snp.makeConstraints { (make) in
            make.top.equalTo(otherUserImageView.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.height.equalTo(30)
            //make.height.equalToSuperview().multipliedBy(0.3)
//            make.width.equalTo(myImageView.snp.height)
//            make.bottom.equalToSuperview().offset(-4)
        }
        myImageView.layer.borderWidth = 1
        myImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor

        let leftSpace = (UIScreen.main.bounds.width - 77) * 0.426
        otherUserPriceValueLabel.textAlignment = .center
        otherUserPriceValueLabel.font = UIFont.init(name: "OpenSans-Regular", size: 17)
        otherUserPriceValueLabel.textColor = Constants.paletteBlackColor
        contentView.addSubview(otherUserPriceValueLabel)
        otherUserPriceValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(otherUserImageView)
            make.left.equalToSuperview().offset(leftSpace)
            make.width.equalTo(77)
            make.height.equalTo(18)
        }
        
        myUserPriceValueLabel.textAlignment = .center
        myUserPriceValueLabel.font = UIFont.init(name: "OpenSans-Regular", size: 17)
        myUserPriceValueLabel.textColor = Constants.paletteBlackColor
        contentView.addSubview(myUserPriceValueLabel)
        myUserPriceValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(myImageView)
            make.left.equalToSuperview().offset(leftSpace)
            make.width.equalTo(77)
            make.height.equalTo(18)
        }
        
        agreeButton.setTitle("согласиться", for: .normal)
        agreeButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.clipsToBounds = true
        agreeButton.backgroundColor = UIColor.init(hexString: "#5263FF")
        agreeButton.layer.cornerRadius = 5
        contentView.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(otherUserPriceValueLabel)
            make.width.equalTo(87)
            make.height.equalTo(27)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        offerNewPriceButton.setTitle("предложить", for: .normal)
        offerNewPriceButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)
        offerNewPriceButton.clipsToBounds = true
        offerNewPriceButton.backgroundColor = UIColor.init(hexString: "#EBEFF2")
        
        offerNewPriceButton.layer.cornerRadius = 5
        contentView.addSubview(offerNewPriceButton)
        offerNewPriceButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(myImageView)
            make.width.equalTo(87)
            make.height.equalTo(27)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        newPricePickerView.valueTextField.font = UIFont.init(name: "OpenSans-Regular", size: 17)!
        newPricePickerView.valueTextField.textColor = Constants.paletteBlackColor
        contentView.addSubview(newPricePickerView)
        newPricePickerView.snp.makeConstraints { (make) in
            make.centerY.equalTo(myImageView.snp.centerY)
            make.left.equalTo(otherUserImageView.snp.right).offset(12)
            make.right.equalTo(offerNewPriceButton.snp.left).offset(-12)
            make.width.equalTo(118)
            make.height.equalTo(20)
        }
        
        youLabel.font = UIFont(name: "OpenSans-Regular", size: 10)!
        youLabel.textColor = Constants.paletteBlackColor
        youLabel.textAlignment = .center
        contentView.addSubview(youLabel)
        youLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(myImageView.snp.centerX)
            make.top.equalTo(myImageView.snp.bottom)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
        youLabel.text = "Вы"
        
        otherUserNameLabel.font = UIFont(name: "OpenSans-Regular", size: 10)!
        otherUserNameLabel.textColor = Constants.paletteBlackColor
        otherUserNameLabel.textAlignment = .center
        contentView.addSubview(otherUserNameLabel)
        otherUserNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(otherUserImageView.snp.centerX)
            make.top.equalTo(otherUserImageView.snp.bottom)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
