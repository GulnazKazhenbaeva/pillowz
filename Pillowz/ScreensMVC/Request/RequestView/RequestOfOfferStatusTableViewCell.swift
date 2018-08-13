//
//  RequestOfOfferStatusTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 30.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class RequestOfOfferStatusTableViewCell: UITableViewCell {
    let requestOfOfferStatusLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(requestOfOfferStatusLabel)
        requestOfOfferStatusLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(16)
            make.left.equalToSuperview().offset(Constants.basicOffset)
        }
        requestOfOfferStatusLabel.textAlignment = .left
        requestOfOfferStatusLabel.setLightGrayStyle()
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
