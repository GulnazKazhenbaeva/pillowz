//
//  BargainSwipeView.swift
//  Pillowz
//
//  Created by Samat on 30.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class BargainSwipeView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var delegate:BargainViewDelegate?
    
    var offer:Offer?
    var request:Request?
    
    let agreeButton = UIButton()
    let agreePriceLabel = UILabel()
    let agreeLabel = UILabel()
    
    let offerView = UIView()
    let newPricePickerView = IntValuePickerView(initialValue: 500, step: 500, additionalText: "₸")
    let offerNewPriceButton = UIButton()
    
    func fillWithOffer(_ fillingOffer:Offer?, fillingRequest:Request?) {
        self.addSubview(offerView)
        offerView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(154)
        }
        offerView.backgroundColor = UIColor(hexString: "#F6F6F6")
        
        
        offerNewPriceButton.setTitle("предложить", for: .normal)
        offerNewPriceButton.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        offerNewPriceButton.clipsToBounds = true
        offerNewPriceButton.backgroundColor = Constants.paletteVioletColor
        offerNewPriceButton.addTarget(self, action: #selector(offerNewPriceTapped), for: .touchUpInside)

        offerNewPriceButton.layer.cornerRadius = 5
        offerView.addSubview(offerNewPriceButton)
        offerNewPriceButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
        
        newPricePickerView.valueTextField.font = UIFont.init(name: "OpenSans-SemiBold", size: 17)!
        newPricePickerView.valueTextField.textColor = Constants.paletteBlackColor
        offerView.addSubview(newPricePickerView)
        newPricePickerView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.height.equalTo(20)
        }
        
        
        self.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(104)
            make.left.equalTo(offerView.snp.right)
        }
        agreeButton.backgroundColor = Constants.paletteVioletColor
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        
        
        agreeButton.addSubview(agreeLabel)
        agreeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        agreeLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        agreeLabel.text = "согласиться"
        agreeLabel.textAlignment = .center
        agreeLabel.textColor = .white
        agreeLabel.numberOfLines = 0

        
        agreeButton.addSubview(agreePriceLabel)
        agreePriceLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.height.equalTo(20)
        }
        agreePriceLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 17)!
        agreePriceLabel.textAlignment = .center
        agreePriceLabel.textColor = .white
        agreePriceLabel.adjustsFontSizeToFitWidth = true
        
        
        self.offer = fillingOffer
        self.request = fillingRequest
        
        var space:Space?
        
        var isWaitingForAnswer:Bool
        var justSentAnOffer:Bool
        
        var myPrice:Int?
        var otherUserPrice:Int?
        
        var otherUserRole:UserRole
        if User.currentRole == .client {
            otherUserRole = .realtor
        } else {
            otherUserRole = .client
        }
        
        if (offer != nil) {
            space = offer!.space
            isWaitingForAnswer = offer!.isWaitingForAnswer()
            justSentAnOffer = offer!.justSentAnOffer()
            myPrice = offer!.getLastPrice(role: User.currentRole)
            otherUserPrice = offer!.getLastPrice(role: otherUserRole)
        } else {
            space = request!.space
            isWaitingForAnswer = request!.isWaitingForAnswer()
            justSentAnOffer = request!.justSentAnOffer()
            myPrice = request!.getLastPrice(role: User.currentRole)
            otherUserPrice = request!.getLastPrice(role: otherUserRole)
        }
        
        
        if myPrice == nil {
            if User.currentRole == .client {
                myPrice = request!.price!
            } else {
                if let space = space {
                    myPrice = space.calculateTotalPriceFor(request!.rent_type!, startTimestamp: request!.start_time!, endTimestamp: request!.end_time!)
                }
            }
        }
        
        if otherUserPrice == nil {
            if User.currentRole == .client {
                if let space = space {
                    otherUserPrice = space.calculateTotalPriceFor(request!.rent_type!, startTimestamp: request!.start_time!, endTimestamp: request!.end_time!)
                }
            } else {
                otherUserPrice = request!.price!
            }
        }
        
        offerNewPriceButton.isEnabled = true
        agreeButton.isEnabled = true
        self.newPricePickerView.isEnabled = true

        if User.currentRole == .realtor {
//            self.newPricePickerView.maxValue = myPrice
        } else {
//            self.newPricePickerView.minValue = myPrice
        }
        
        newPricePickerView.value = myPrice!
        agreePriceLabel.text = String(otherUserPrice!) + "₸"
        
        if isWaitingForAnswer {
            offerNewPriceButton.backgroundColor = Constants.paletteLightGrayColor
            offerNewPriceButton.isEnabled = false
            offerNewPriceButton.setTitle("предложено", for: .normal)
            self.newPricePickerView.isEnabled = false
        }
        
        if justSentAnOffer {
            agreeButton.isEnabled = false
            agreeButton.backgroundColor = Constants.paletteLightGrayColor
            
            if User.currentRole == .client {
                agreeLabel.text = "по тарифу владельца"
            } else {
                agreeLabel.text = "цена клиента"
            }
        }
    }
    
    @objc func offerNewPriceTapped() {
        self.delegate?.offerNewPriceTapped(newPrice: self.newPricePickerView.value)
    }
    
    @objc func agreeTapped() {
        self.delegate?.agreeTapped()
    }
}
