//
//  AuthorizationGuideView.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/18/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class AuthorizationGuideView: UIView { 
    private let titleLabel = UILabel()
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    
    init(title: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.backgroundColor = .lightGray
        
        addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.font = titleLabel.font.withSize(24)
        titleLabel.numberOfLines = 3
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
