//
//  CompletedSwipeView.swift
//  Pillowz
//
//  Created by Samat on 31.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class CompletedSwipeView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let userInfoView = UIView()
    let priceTextLabel = UILabel()
    let priceLabel = UILabel()
    let userImageView = UIImageView()
    let userNameLabel = UILabel()
    
    let chatButton = UIButton()
    let chatIconImageView = UIImageView()
    let chatLabel = UILabel()
    
    let callButton = UIButton()
    let callIconImageView = UIImageView()
    let callLabel = UILabel()
    
    var delegate: UserTableViewCellDelegate?

    var user:User! {
        didSet {
            if (user.name != nil) {
                self.userNameLabel.text = user.name
            }
            
            if (user.avatar != nil) {
                let urlString = user.avatar!
                let url = URL(string: urlString)
                
                self.userImageView.sd_setImage(with: url, placeholderImage: UIImage())
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(userInfoView)
        userInfoView.snp.makeConstraints { (make) in
            make.top.bottom.left.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        userInfoView.backgroundColor = UIColor(hexString: "#A0DE61")
        
        userInfoView.addSubview(priceTextLabel)
        priceTextLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(7)
            make.width.equalToSuperview()
            make.height.equalTo(17)
        }
        priceTextLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        priceTextLabel.textColor = .white
        priceTextLabel.text = "Сумма:"
        priceTextLabel.textAlignment = .center
        
        
        userInfoView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(priceTextLabel.snp.bottom).offset(2)
            make.width.equalToSuperview()
            make.height.equalTo(17)
        }
        priceLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        priceLabel.textColor = .white
        priceLabel.text = "100 000т"
        priceLabel.textAlignment = .center

        
        userImageView.backgroundColor = UIColor.init(hexString: "#C4C4C4")
        userImageView.layer.cornerRadius = 20
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
        userInfoView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
        
        userInfoView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(40)
            make.width.equalToSuperview()
            make.height.equalTo(34)
        }
        userNameLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        userNameLabel.textColor = .white
        userNameLabel.text = "написать"
        userNameLabel.textAlignment = .center

        
        self.addSubview(chatButton)
        chatButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(userInfoView.snp.right)
            make.width.equalToSuperview().dividedBy(3)
        }
        chatButton.backgroundColor = UIColor(hexString: "#808DFF")
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)

        chatButton.addSubview(chatIconImageView)
        chatIconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }
        chatIconImageView.image = #imageLiteral(resourceName: "chatSwipeIcon")
        chatIconImageView.contentMode = .center
        
        chatButton.addSubview(chatLabel)
        chatLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(40)
            make.width.equalToSuperview()
            make.height.equalTo(34)
        }
        chatLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        chatLabel.textColor = .white
        chatLabel.text = "написать"
        chatLabel.textAlignment = .center
        
        
        self.addSubview(callButton)
        callButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(chatLabel.snp.right)
            make.width.equalToSuperview().dividedBy(3)
        }
        callButton.backgroundColor = Constants.paletteVioletColor
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        
        callButton.addSubview(callIconImageView)
        callIconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }
        callIconImageView.image = #imageLiteral(resourceName: "callSwipeIcon")
        callIconImageView.contentMode = .center
        
        callButton.addSubview(callLabel)
        callLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(40)
            make.width.equalToSuperview()
            make.height.equalTo(34)
        }
        callLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        callLabel.textColor = .white
        callLabel.text = "позвонить"
        callLabel.textAlignment = .center
    }
    
    @objc func callButtonTapped() {
        delegate?.callTapped()
    }
    
    @objc func chatButtonTapped() {
        delegate?.chatTapped()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
