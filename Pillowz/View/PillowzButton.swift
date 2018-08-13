//
//  PillowzButton.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/24/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class PillowzButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Constants.paletteVioletColor
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        self.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 13)!
        
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    class func makeBasicButtonConstraints(button:PillowzButton, pinToTop:Bool) {
        button.snp.makeConstraints { (make) in
            if (pinToTop) {
                make.top.equalToSuperview().offset(Constants.basicOffset)
            } else {
                let offset = -Constants.basicOffset
                
                make.bottom.equalToSuperview().offset(offset)
            }
            
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(50)
        }
        
        button.setTitle("Сохранить", for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
