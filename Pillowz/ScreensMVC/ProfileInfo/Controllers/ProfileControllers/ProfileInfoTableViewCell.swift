//
//  ProfileInfoTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 23.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class ProfileInfoTableViewCell: UITableViewCell, FillableCellDelegate {
    var user:User! {
        didSet {
            var placeholderImage:UIImage
            
            let shouldShowUserProfile = (user.realtor == nil || user.realtor?.rtype == .agent || user.realtor?.rtype == .owner)
            
            if (shouldShowUserProfile) {
                placeholderImage = #imageLiteral(resourceName: "emptyPhoto")
            } else {
                placeholderImage = #imageLiteral(resourceName: "emptyOrganization")
            }
            
            profileImageView.sd_setImage(with: URL(string: user.avatar!), placeholderImage: placeholderImage)
            
            profileImageView.sd_setImage(with: URL(string: user.avatar!)) { (image, error, _, _) in
                if (error == nil) {
                    self.profileImageView.contentMode = .scaleAspectFill
                }
            }
            
            if (shouldShowUserProfile) {
                nameLabel.text = user.name
            } else {
                nameLabel.text = user.realtor?.business_name
            }
            
            if (user.isRealtor()) {
                rtypeLabel.text = User.getRtypeNameFor(user.realtor!.rtype!)
            } else {
                rtypeLabel.text = "Клиент"
            }
            
            if (shouldShowUserProfile) {
                addressLabel.text = user.address
            } else {
                addressLabel.text = user.realtor?.address
            }
            
            if (addressLabel.text == "" || addressLabel.text == nil) {
                addressLabel.text = "Адрес не указан"
            }
            
            if (user.review == nil) {
                rateView.setStars(stars: 0)
            } else {
                rateView.setStars(stars: user.review!)
            }
            
            
            idLabel.text = "ID: " + String(user.user_id!)
        }
    }
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let rtypeLabel = UILabel()
    let addressLabel = UILabel()
    let rateView = RateView()
    let idLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteLightGrayColor
        label.font = UIFont.init(name: "OpenSans-Light", size: 12)!
        label.textAlignment = .right
        return label
    }()
    
    func fillWithObject(object: AnyObject) {
        user = object as! User
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.screenFrame.size.width*208/360)
        }
        profileImageView.backgroundColor = Constants.paletteVioletColor
        profileImageView.contentMode = .center
        profileImageView.clipsToBounds = true

        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(20)
        }
        nameLabel.font = UIFont.init(name: "OpenSans-Regular", size: 20)!
        nameLabel.textColor = Constants.paletteBlackColor
        
        self.contentView.addSubview(idLabel)
        idLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(20)
        }
        
        self.contentView.addSubview(rtypeLabel)
        rtypeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(13)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset - 60 - 8)
            make.height.equalTo(22)
        }
        rtypeLabel.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        rtypeLabel.textColor = Constants.paletteBlackColor
        
        self.contentView.addSubview(rateView)
        rateView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(13)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(60)
            make.height.equalTo(22)
        }
        
        self.contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(rtypeLabel.snp.bottom).offset(13)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-10)
        }
        addressLabel.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
        addressLabel.textColor = Constants.paletteBlackColor
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
