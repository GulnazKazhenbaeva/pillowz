//
//  ProfileTabViewController.swift
//  Pillowz
//
//  Created by Samat on 29.11.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class ProfileTabViewController: PillowzViewController {
    static let shared = ProfileTabViewController()
    
    let loginVC = LoginViewController()
    let profileVC = ProfileViewController()
    
    var loginView:UIView!
    var profileView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func loadView() {
        super.loadView()
        
        loginView = loginVC.view
        profileView = profileVC.view        
        
        view.addSubview(loginView)
        loginView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(profileView)
        profileView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupDisplayingView() {
        if (User.isLoggedIn()) {
            profileView?.isHidden = false
            loginView?.isHidden = true
            
            profileVC.updateProfileUI()
            
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            appDelegate.configureBadges()
            
            if (AppDelegate.getPushPlayerId() != "") {
                AuthorizationAPIManager.updatePushPlayerId(AppDelegate.getPushPlayerId(), completion: { (object, error) in
                    
                })
            }
        } else {
            profileView.isHidden = true
            loginView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupDisplayingView()
    }
}
