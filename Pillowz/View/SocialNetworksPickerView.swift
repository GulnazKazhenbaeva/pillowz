//
//  SocialNetworksPickerView.swift
//  Pillowz
//
//  Created by Samat on 02.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol SocialNetworksPickerViewDelegate {
    func socialNetworkTapped(socialNetwork:SocialNetworkLinks)
}

class SocialNetworksPickerView: UIView {
    let googleButton = UIButton()
    let facebookButton = UIButton()
    let vkButton = UIButton()
    
    var superViewController:UIViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(googleButton)
        googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        googleButton.setImage(UIImage(named: "google"), for: .normal)
        googleButton.backgroundColor = UIColor(hexString: "#EA4335")
        googleButton.layer.cornerRadius = 18
        googleButton.dropShadow()
        googleButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(Constants.screenFrame.size.width/4-39)
            make.height.equalTo(36)
            make.width.equalTo(68)
        }
        
        self.addSubview(facebookButton)
        facebookButton.addTarget(self, action: #selector(facebookTapped), for: .touchUpInside)
        facebookButton.setImage(UIImage(named: "facebook"), for: .normal)
        facebookButton.backgroundColor = UIColor(hexString: "#3B5998")
        facebookButton.layer.cornerRadius = 18
        facebookButton.dropShadow()
        facebookButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(Constants.screenFrame.size.width*2/4-39)
            make.height.equalTo(35)
            make.width.equalTo(68)
        }
        
        self.addSubview(vkButton)
        vkButton.addTarget(self, action: #selector(vkTapped), for: .touchUpInside)
        vkButton.setImage(UIImage(named: "vk"), for: .normal)
        vkButton.backgroundColor = UIColor(hexString: "#4C75A3")
        vkButton.layer.cornerRadius = 18
        vkButton.dropShadow()
        vkButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(Constants.screenFrame.size.width*3/4-39)
            make.height.equalTo(35)
            make.width.equalTo(68)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    @objc func googleTapped() {
        (superViewController as? SocialNetworksPickerViewDelegate)?.socialNetworkTapped(socialNetwork: .google)
    }
    
    @objc func facebookTapped() {
        (superViewController as? SocialNetworksPickerViewDelegate)?.socialNetworkTapped(socialNetwork: .facebook)
    }

    @objc func instagramTapped() {
        (superViewController as? SocialNetworksPickerViewDelegate)?.socialNetworkTapped(socialNetwork: .instagram)
    }

    @objc func vkTapped() {
        (superViewController as? SocialNetworksPickerViewDelegate)?.socialNetworkTapped(socialNetwork: .vkontakte)
    }

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
