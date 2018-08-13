//
//  SpaceReportTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 02.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class SpaceReportTableViewCell: UITableViewCell {

    var space:Space! {
        didSet {
            
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


}
