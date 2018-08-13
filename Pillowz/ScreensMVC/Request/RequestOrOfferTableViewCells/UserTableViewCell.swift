//
//  UserTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 17.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func chatTapped()
    func callTapped()
}

class UserTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 13)
        if User.currentRole == .client {
            label.text = "О владельце:"
        } else {
            label.text = "О госте:"
        }
        return label
    }()
    let userImageView = UIImageView()
    let rateView = RateView()
    let userNameLabel = UILabel()
    let reviewDetailLabel = UILabel()
    let phoneLabel = UILabel()
    let callButton = UIButton()
    let chatButton = UIButton()
    
    var delegate: UserTableViewCellDelegate?

    var user:User! {
        didSet {
            if (user.review == nil) {
                self.rateView.setStars(stars: 0)
            } else {
                self.rateView.setStars(stars: user.review!)
            }
            
            if (user.name != nil) {
                self.userNameLabel.text = user.name
            }
            
            if (user.avatar != nil) {
                let urlString = user.avatar!
                let url = URL(string: urlString)
                
                self.userImageView.sd_setImage(with: url, placeholderImage: UIImage())
            }
            
            self.reviewDetailLabel.text = String(user.reviews!.count) + " отзывов"
        }
    }
    
    var realtor:Realtor! {
        didSet {
            if (realtor.review == nil) {
                self.rateView.setStars(stars: 0)
            } else {
                self.rateView.setStars(stars: realtor.review!)
            }
            
            if (realtor.person_name != nil) {
                self.userNameLabel.text = realtor.person_name
            }
            
            if (realtor.avatar != nil) {
                let urlString = realtor.avatar!
                let url = URL(string: urlString)
                
                self.userImageView.sd_setImage(with: url, placeholderImage: UIImage())
            }
            
            self.reviewDetailLabel.text = String(realtor.reviews!.count) + " отзывов"
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(146)
            make.height.equalTo(21)
        }
        
        userImageView.backgroundColor = UIColor.init(hexString: "#C4C4C4")
        userImageView.layer.cornerRadius = 20
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
        contentView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(7)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.height.equalTo(40)
        }
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
        
        callButton.setImage(#imageLiteral(resourceName: "callIcon"), for: .normal)
        callButton.imageView?.contentMode = .scaleAspectFit
        callButton.backgroundColor = UIColor.init(hexString: "#E0E0E0")
        callButton.layer.cornerRadius = 20
        callButton.clipsToBounds = true
        callButton.layer.masksToBounds = true
        contentView.addSubview(callButton)
        callButton.snp.makeConstraints { (make) in
            make.right.equalTo(userImageView.snp.left).offset(-10)
            make.width.height.equalTo(40)
            make.top.equalTo(userImageView)
        }
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        
        chatButton.setImage(#imageLiteral(resourceName: "chatIcon"), for: .normal)
        chatButton.imageView?.contentMode = .scaleAspectFit
        chatButton.backgroundColor = UIColor.init(hexString: "#E0E0E0")
        chatButton.layer.cornerRadius = 20
        chatButton.clipsToBounds = true
        chatButton.layer.masksToBounds = true
        contentView.addSubview(chatButton)
        chatButton.snp.makeConstraints { (make) in
            make.right.equalTo(callButton.snp.left).offset(-10)
            make.width.height.equalTo(40)
            make.top.equalTo(callButton)
        }
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        
        reviewDetailLabel.textColor = UIColor.init(hexString: "#5263FF")
        reviewDetailLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        contentView.addSubview(reviewDetailLabel)
        reviewDetailLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalTo(userImageView.snp.bottom).offset(14)
            make.height.equalTo(18)
            make.width.equalTo(64)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        contentView.addSubview(rateView)
        rateView.snp.makeConstraints { (make) in
            make.right.equalTo(reviewDetailLabel.snp.left).offset(-22)
            make.centerY.equalTo(reviewDetailLabel)
            make.height.equalTo(10)
            make.width.equalTo(58)
        }
                
        contentView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalTo(chatButton.snp.left).offset(-10)
            make.height.equalTo(21)
        }
    }
    
    @objc func callButtonTapped() {
        delegate?.callTapped()
    }
    
    @objc func chatButtonTapped() {
        delegate?.chatTapped()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
