//
//  SetRatingTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 15.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SetRatingTableViewCell: HeaderIncludedTableViewCell {
    let setRatingView = SetRatingView()
        
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(setRatingView)
        setRatingView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
            make.top.equalTo(headerLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(5 * 34)
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
