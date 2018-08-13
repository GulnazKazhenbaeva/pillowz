//
//  ProfileTableViewCell.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/8/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class ProfileTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let iconImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(Constants.basicOffset)
        }
        titleLabel.textColor = Constants.paletteBlackColor
        titleLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Constants.basicOffset)
            make.height.width.equalTo(18)
        }
        iconImageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
