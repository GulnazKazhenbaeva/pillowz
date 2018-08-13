//
//  HeaderTextTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 24.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class HeaderTextTableViewCell: UITableViewCell, FillableCellDelegate {
    func fillWithObject(object: AnyObject) {
        headerText = object as? String
    }
    
    var headerText:String? {
        didSet {
            headerTextLabel.text = headerText
        }
    }
    let headerTextLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(headerTextLabel)
        headerTextLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        headerTextLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 18)!
        headerTextLabel.textColor = Constants.paletteBlackColor
        headerTextLabel.numberOfLines = 0
        headerTextLabel.lineBreakMode = .byWordWrapping
    }

    required init(coder aDecoder: NSCoder)
    {
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
