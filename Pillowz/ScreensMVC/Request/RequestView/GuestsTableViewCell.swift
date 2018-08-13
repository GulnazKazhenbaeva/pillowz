//
//  GuestsTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 18.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class GuestsTableViewCell: HeaderIncludedTableViewCell {
    var nameLabels:[UILabel] = []
    var valueLabels:[UILabel] = []
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    func setupLabels() {
        for icon in icons {
            icon.removeFromSuperview()
        }

    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
