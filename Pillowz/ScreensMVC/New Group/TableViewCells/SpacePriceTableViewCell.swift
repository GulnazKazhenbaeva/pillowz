//
//  SpacePriceTableViewCell.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/24/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class SpacePricesTableViewCell: UITableViewCell {
    
    var space: Space! {
        didSet {
            if (priceTitleLabels.count==0) {
                setupLabels()
            }
        }
    }
     
    var priceTitleLabels = [UILabel]()
    var priceLabels = [UILabel]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(hexString: "#F2F2F2")
        
    }
    
    func setupLabels() {
        let nonNilPrices:[Price] = space.getNonNilPrices()
        
        let numberOfRows = (nonNilPrices.count+1)/2

        for i in 0..<numberOfRows {
            let separatorView = UIView()
            self.contentView.addSubview(separatorView)
            separatorView.snp.makeConstraints({ (make) in
                make.top.equalToSuperview().offset(9 + i*71)
                make.height.equalTo(62)
                make.centerX.equalToSuperview()
                make.width.equalTo(1)
            })
            separatorView.backgroundColor = UIColor(red: 0.77, green: 0.77, blue: 0.77, alpha: 0.5)
        }
        
        for price in nonNilPrices {
            let currentIndex = nonNilPrices.index(of: price)!
            let shouldBeOnLeft = currentIndex%2==0
            
            let currentRow = Int(currentIndex)/2
            
            let priceTitleLabel = UILabel()
            self.contentView.addSubview(priceTitleLabel)
            priceTitleLabel.text = Price.getDisplayNameForRentType(rent_type: price.rent_type!, isForPrice: true)["ru"]!
            priceTitleLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
            priceTitleLabel.textColor = UIColor(white: 0, alpha: 0.5)
            priceTitleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(15 + 62*currentRow)
                
                if (shouldBeOnLeft) {
                    make.centerX.equalToSuperview().offset(-Constants.screenFrame.size.width/4)
                } else {
                    make.centerX.equalToSuperview().offset(Constants.screenFrame.size.width/4)
                }
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalTo(17)
            }
            priceTitleLabel.textAlignment = .center
            priceTitleLabels.append(priceTitleLabel)
            
            let priceLabel = UILabel()
            self.contentView.addSubview(priceLabel)
            priceLabel.font = UIFont.init(name: "OpenSans-Bold", size: 18)!
            priceLabel.textColor = Constants.paletteBlackColor
            priceLabel.text = price.price!.formattedWithSeparator + "₸"
            priceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(priceTitleLabel.snp.bottom).offset(12)
                make.centerX.equalTo(priceTitleLabel.snp.centerX)
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalTo(17)
            }
            priceLabel.textAlignment = .center
            priceLabels.append(priceLabel)
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
