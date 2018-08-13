//
//  BookingPriceAndCommentView.swift
//  Pillowz
//
//  Created by Samat on 17.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

public typealias BookingPriceAndCommentViewActionClosure = (_ value:Int, _ comment:String) -> Void

class BookingPriceAndCommentView: UIView {
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let whiteAlertView = UIView()
    let pricePickerView = IntValuePickerView(initialValue: 500, step: 500, additionalText: "₸")
    let titleLabel = UILabel()
    let commentTextField = PillowTextField(keyboardType: .default, placeholder: "")
    let createBookingButton = UIButton()
    let cancelButton = UIButton()
    
    var action:BookingPriceAndCommentViewActionClosure!
    
    init(initialPrice:Int, newAction:@escaping BookingPriceAndCommentViewActionClosure) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        self.action = newAction
        
        whiteAlertView.backgroundColor = .white
        whiteAlertView.layer.cornerRadius = 3
        self.addSubview(whiteAlertView)
        whiteAlertView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(247)
        }
        
        whiteAlertView.addSubview(titleLabel)
        titleLabel.textColor = Constants.paletteBlackColor
        titleLabel.text = "Введите сумму и оставьте комментарий:"
        titleLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 17)!
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(47)
        }
        
        whiteAlertView.addSubview(pricePickerView)
        pricePickerView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(26)
            make.width.equalTo(138)
            make.height.equalTo(20)
        }
        
        whiteAlertView.addSubview(commentTextField)
        commentTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalTo(pricePickerView.snp.bottom).offset(28)
            make.height.equalTo(40)
        }
        commentTextField.font = UIFont.init(name: "OpenSans-Regular", size: 17)
        commentTextField.placeholder = "Комментарий"
        
        var currentOffset = Constants.basicOffset
        
        let font = UIFont.init(name: "OpenSans-Regular", size: 17)!
        whiteAlertView.addSubview(createBookingButton)
        createBookingButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(40)
            
            make.right.equalToSuperview().offset(-currentOffset)
            
            let labelWidth = "Создать бронь".width(withConstraintedHeight: 20, font: font) + 10
            
            currentOffset = currentOffset + labelWidth + 16
            
            make.width.equalTo(labelWidth)
        }
        createBookingButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        createBookingButton.titleLabel?.font = font
        createBookingButton.setTitle("Создать бронь", for: .normal)
        createBookingButton.addTarget(self, action: #selector(createBookingTapped), for: .touchUpInside)
        
        
        whiteAlertView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(40)
            
            make.right.equalToSuperview().offset(-currentOffset)
            
            let labelWidth = "Отменить".width(withConstraintedHeight: 20, font: font) + 10
            
            currentOffset = currentOffset + labelWidth + 16
            
            make.width.equalTo(labelWidth)
        }
        cancelButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        cancelButton.titleLabel?.font = font
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow!
        
        window.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func dismissView() {
        self.removeFromSuperview()
    }
    
    @objc func createBookingTapped() {
        action?(pricePickerView.value, commentTextField.text!)
        dismissView()
    }
    
    @objc func cancelTapped() {
        dismissView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
