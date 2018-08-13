//
//  SpacePricesListView.swift
//  Pillowz
//
//  Created by Samat on 12.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpacePricesListView: UIView {
    var space:Space!
    let pricesBackgroundView = UIView()
    
    init(space:Space, point:CGPoint) {
        super.init(frame: CGRect.zero)
        
        let prices = space.getNonNilPrices()
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        self.addSubview(pricesBackgroundView)
        
        var currentYCoordinate:CGFloat = 4
        var maxPriceWidth:CGFloat = 0
        var maxRentTypeWidth:CGFloat = 0

        var rentTypeLabels:[UILabel] = []
        
        let noPricesLabel = UILabel()
        
        for price in prices {
            if price.rent_type == UserLastUsedValuesForFieldAutofillingHandler.shared.rentType {
                continue
            }
            
            let priceLabel = UILabel()
            pricesBackgroundView.addSubview(priceLabel)
            priceLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)!
            priceLabel.textColor = .black
            priceLabel.textAlignment = .left
            priceLabel.text = price.price!.formattedWithSeparator + "₸"
            
            let priceLabelWidth = priceLabel.text!.width(withConstraintedHeight: 20, font: priceLabel.font)
            
            if priceLabelWidth > maxPriceWidth {
                maxPriceWidth = priceLabelWidth
            }
            
            priceLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(currentYCoordinate)
                make.left.equalToSuperview().offset(10)
                make.width.equalTo(priceLabelWidth)
                make.height.equalTo(22)
            }

            let rentTypeLabel = UILabel()
            pricesBackgroundView.addSubview(rentTypeLabel)
            rentTypeLabel.text = Price.getDisplayNameForRentType(rent_type: price.rent_type!, isForPrice: false, isForSpaceView: true)["ru"]!
            rentTypeLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 10)!
            rentTypeLabel.textColor = Constants.paletteLightGrayColor

            let rentTypeLabelWidth = rentTypeLabel.text!.width(withConstraintedHeight: 20, font: rentTypeLabel.font)
            
            if rentTypeLabelWidth > maxRentTypeWidth {
                maxRentTypeWidth = rentTypeLabelWidth
            }
            
            rentTypeLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(priceLabel.snp.bottom).offset(3)
                make.left.equalToSuperview().offset(40)
                make.width.equalTo(rentTypeLabelWidth)
                make.height.equalTo(22)
            }
            rentTypeLabels.append(rentTypeLabel)
            
            currentYCoordinate = currentYCoordinate + 22
        }
        
        var totalWidth = maxPriceWidth + maxRentTypeWidth + 20 + 6
        
        for rentTypeLabel in rentTypeLabels {
            rentTypeLabel.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(maxPriceWidth + 16)
            }
        }
        
        
        if currentYCoordinate == 4 {
            currentYCoordinate = 20
            totalWidth = 100
            
            pricesBackgroundView.addSubview(noPricesLabel)
            noPricesLabel.text = "Других цен нет"
            noPricesLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 10)!
            noPricesLabel.textColor = Constants.paletteLightGrayColor
            noPricesLabel.textAlignment = .center
            noPricesLabel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        
        pricesBackgroundView.dropShadow()
        pricesBackgroundView.backgroundColor = .white
        pricesBackgroundView.layer.cornerRadius = 5
        pricesBackgroundView.snp.makeConstraints { (make) in
            make.height.equalTo(currentYCoordinate + 4)
            make.width.equalTo(totalWidth + 12)
            make.left.equalToSuperview().offset(point.x)
            make.top.equalToSuperview().offset(point.y)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
}
