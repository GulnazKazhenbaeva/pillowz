//
//  TutorialView.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 09.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class TutorialView: UIView {
    let imageView = UIImageView()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 20)!
        label.textAlignment = .center
        label.textColor = UIColor.init(hexString: "#333333").withAlphaComponent(0.87)
        return label
    }()
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
        label.textColor = UIColor.black.withAlphaComponent(0.54)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(75)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(15)
        }
    
        addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.bottom.equalToSuperview().offset(-80)
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
