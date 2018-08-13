//
//  RequestOrOfferBottomView.swift
//  Pillowz
//
//  Created by Samat on 20.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

protocol RequestOrOfferBottomViewDelegate {
    func agreeTapped()
}

class RequestOrOfferBottomView: UIView {
    let priceHeaderLabel = UILabel()
    let periodHeaderLabel = UILabel()
    let priceLabel = UILabel()
    let periodLabel = UILabel()
    
    let agreeButton = UIButton()
    
    var delegate:RequestOrOfferBottomViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(priceHeaderLabel)
        priceHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(18)
            make.width.equalTo(50)
        }
        self.setHeaderStyleToLabel(priceHeaderLabel)
        priceHeaderLabel.text = "цена:"

        self.addSubview(periodHeaderLabel)
        periodHeaderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceHeaderLabel.snp.right).offset(8)
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(18)
            make.width.equalTo(112)
        }
        self.setHeaderStyleToLabel(periodHeaderLabel)
        periodHeaderLabel.text = "срок:"
        
        self.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceHeaderLabel.snp.bottom).offset(4)
            make.left.equalTo(priceHeaderLabel.snp.left)
            make.height.equalTo(18)
            make.width.equalTo(priceHeaderLabel.snp.width)
        }
        self.setBasicStyleToLabel(priceLabel)
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.5

        self.addSubview(periodLabel)
        periodLabel.snp.makeConstraints { (make) in
            make.top.equalTo(periodHeaderLabel.snp.bottom).offset(4)
            make.left.equalTo(periodHeaderLabel.snp.left)
            make.height.equalTo(18)
            make.width.equalTo(periodHeaderLabel.snp.width)
        }
        self.setBasicStyleToLabel(periodLabel)
        periodLabel.adjustsFontSizeToFitWidth = true
        periodLabel.minimumScaleFactor = 0.5

        self.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(33)
        }
        agreeButton.backgroundColor = Constants.paletteVioletColor
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 13)
        agreeButton.setTitle("Согласиться", for: .normal)
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        agreeButton.layer.cornerRadius = 3
        
        self.dropShadow()
    }
    
    @objc func agreeTapped() {
        delegate?.agreeTapped()
    }
    
    func setHeaderStyleToLabel(_ label:UILabel) {
        label.font = UIFont(name: "OpenSans-Regular", size: 10)
        label.textColor = Constants.paletteBlackColor
    }
    
    func setBasicStyleToLabel(_ label:UILabel) {
        label.font = UIFont(name: "OpenSans-SemiBold", size: 13)
        label.textColor = Constants.paletteBlackColor
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
