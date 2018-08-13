//
//  EmptyTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 21.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {
    let emptyView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
