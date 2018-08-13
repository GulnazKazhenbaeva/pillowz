//
//  RegistrationForm.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 06.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class RegistrationForm: UIView {
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.scrollsToTop = true
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        return scrollView
    }()
    let dataView = UIView()
    let guideLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.authorizationSignUpGuideText
        label.font = label.font.withSize(18)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let nextButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 14)!
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    let privacyPolicyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-Light", size: 12)!
        label.numberOfLines = 5
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    init(dataViewHeight: CGFloat, windowColor: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(guideLabel)
        guideLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(48)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        scrollView.addSubview(dataView)
        dataView.backgroundColor = .white
        dataView.snp.makeConstraints { (make) in
            make.top.equalTo(guideLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(dataViewHeight)
        }
        
        let reminderLabel = UILabel()
        scrollView.addSubview(reminderLabel)
        reminderLabel.text = "*Обязательные поля"
        reminderLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        reminderLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(30)
            make.top.equalTo(dataView.snp.bottom).offset(20)
        }
        
        scrollView.addSubview(nextButton)
        nextButton.setTitle("НАЧНЕМ!", for: .normal)
        nextButton.backgroundColor = windowColor
        nextButton.snp.makeConstraints { (make) in
            make.top.equalTo(dataView.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        
        scrollView.addSubview(privacyPolicyLabel)
        let text = Constants.authorizationSignUpPrivacyPolicyText
        let firstTextWithColor = "Публичной оферты"
        let secondTextWithColor = "Политики конфиденциальности"
        let firstRange = (text as NSString).range(of: firstTextWithColor)
        let secondRange = (text as NSString).range(of: secondTextWithColor)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: windowColor, range: firstRange)
        attributedString.addAttribute(.foregroundColor, value: windowColor, range: secondRange)
        privacyPolicyLabel.attributedText = attributedString
        privacyPolicyLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nextButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(78)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
