//
//  InputTableViewCell.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/31/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class InputTableViewCell: UITableViewCell {
    let textField: PillowTextField
    
    init(keyboardType: UIKeyboardType, placeholder: String) {
        textField = PillowTextField(keyboardType: keyboardType, placeholder: placeholder)
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
