//
//  PillowTextField.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/24/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class PillowTextField: UITextField {
    private let lineView = UIView()
    
    init(keyboardType: UIKeyboardType, placeholder: String) {
        super.init(frame: CGRect.zero)
        
        addSubview(lineView)
        lineView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.sizeToFit()
        self.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        self.textColor = Constants.paletteBlackColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
