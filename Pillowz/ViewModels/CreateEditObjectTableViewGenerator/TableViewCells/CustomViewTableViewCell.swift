//
//  CustomViewTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 08.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class CustomViewTableViewCell: UITableViewCell {
    var customView:UIView? 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
