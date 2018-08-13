//
//  RegistrationCompletedView.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 11.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class RegistrationCompletedView: UIView {
    let imageView = UIImageView(image: UIImage.init(named: "registrationFinalBackground"))
    let coverView = UIView()
    let logoView = UIImageView(image: UIImage.init(named: "logo"))
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Начните поиски\nпрямо сейчас!"
        label.numberOfLines = 2
        label.font = UIFont.init(name: "OpenSans-Bold", size: 16)!
        label.textAlignment = .center
        return label
    }()
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создайте заявку на поиск жилья\nи получайте выгодные\nпредложения от риелторов и хозяев."
        label.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    let nextButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(coverView)
        coverView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        coverView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        coverView.addSubview(logoView)
        logoView.contentMode = .scaleAspectFit
        logoView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        coverView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }

        coverView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        coverView.addSubview(nextButton)
        nextButton.setTitle("Создать заявку", for: .normal)
        nextButton.backgroundColor = Constants.paletteVioletColor
        nextButton.snp.makeConstraints { (make) in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
