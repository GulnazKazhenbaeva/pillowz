//
//  AttachedSocialNetworksTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 02.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class AttachedSocialNetworksTableViewCell: HeaderIncludedTableViewCell {
    
//    let socialNetworksPickerView = SocialNetworksPickerView()
    var superViewController:UIViewController! {
        didSet {
//            socialNetworksPickerView.superViewController = superViewController
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func fillWithObject(object: AnyObject) {
        superViewController = object as! UIViewController
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        self.contentView.addSubview(socialNetworksPickerView)
//        socialNetworksPickerView.superViewController = superViewController
//        socialNetworksPickerView.snp.makeConstraints { (make) in
//            make.top.equalTo(headerLabel.snp.bottom).offset(10)
//            make.height.equalTo(36 + 2*10)
//            make.left.right.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-10)
//        }

    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
