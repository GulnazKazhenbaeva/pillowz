//
//  PillowzTextField.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/24/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class PillowzTextField: UITextField {
    let lineView = UIView()
    
    init(keyboardType: UIKeyboardType, placeholder: String) {
        super.init(frame: CGRect.zero)

        self.keyboardType = keyboardType
        self.placeholder = placeholder
        
        addSubview(lineView)
        lineView.backgroundColor = .lightGray
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
