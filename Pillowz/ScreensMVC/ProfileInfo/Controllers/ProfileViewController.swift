//
//  ProfileViewController.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/24/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD
import SevenSwitch

class ProfileViewController: PillowzViewController {
    var tableViewItems: [String] = []
    var tableViewIcons: [String] = ["share", "changeRole", "settings", "help", "feedback"]
    
    let headerView = UIView()
    
    let fullNameLabel = UILabel()
    let avatarImageView = UIImageView()
    let emptyAvatarInitialsLabel = UILabel()
    
    let changeProfileButton = UIButton()
    let changeAvatarButton = UIButton()

    let roleLabel = UILabel()
    let roleSwitch = SevenSwitch()

    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileTabViewController.shared.navigationItem.title = "Профиль"
        
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorColor = .clear
        tableView.isScrollEnabled = false
        
        updateProfileUI()
    }
    
    func updateProfileUI() {
        let name = User.shared.name
        if (name==nil || name=="") {
            fullNameLabel.text = "Профиль не заполнен"
        } else {
            fullNameLabel.text = name
        }
        
        avatarImageView.sd_setImage(with: URL(string: User.shared.avatar!)) { (image, error, cacheType, url) in
            if (image != nil) {
                self.emptyAvatarInitialsLabel.isHidden = true
            }
        }
        
        avatarImageView.sd_setImage(with: URL(string: User.shared.avatar!), placeholderImage: UIImage())
        
        tableViewItems = ["Уведомления", "Настройки", "Помощь", "Обратная связь", "Поделиться с другом"]
        
        tableView.reloadData()
        
        let isClient = User.currentRole == .client
        
        roleSwitch.on = isClient
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(174)
        }
        
        headerView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(90)
        }
        avatarImageView.backgroundColor = Constants.paletteVioletColor
        avatarImageView.layer.cornerRadius = 45
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor

        avatarImageView.addSubview(changeAvatarButton)
        changeAvatarButton.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        changeAvatarButton.addTarget(self, action: #selector(changeAvatarTapped), for: .touchUpInside)
        
        headerView.addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.top.equalTo(avatarImageView.snp.bottom).offset(0)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(25)
        }
        fullNameLabel.textColor = Constants.paletteLightBlackColor
        fullNameLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 17)!
        fullNameLabel.textAlignment = .center

        headerView.addSubview(changeProfileButton)
        changeProfileButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.top.equalTo(fullNameLabel.snp.bottom).offset(-10)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(45)
        }
        changeProfileButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        changeProfileButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        changeProfileButton.setTitle("Редактировать профиль", for: .normal)
        changeProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)

        self.view.addSubview(self.roleSwitch)
        self.roleSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(changeProfileButton.snp.bottom).offset(31)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(37)
            make.width.equalTo(170)
        }
        roleSwitch.addTarget(self, action: #selector(changeRole(_ :)), for: .valueChanged)
        DesignHelpers.setStyleForRoleSwitch(roleSwitch: roleSwitch)
        
        self.view.addSubview(roleLabel)
        roleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(roleSwitch.snp.centerY)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(22)
            make.width.equalTo(170)
        }
        roleLabel.font = UIFont.init(name: "OpenSans-Regular", size: 17)
        roleLabel.textColor = Constants.paletteBlackColor
        roleLabel.text = "Режим"

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.height.equalTo(44*5)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }
    
    @objc func changeRole(_ sender:SevenSwitch) {
        if (sender.isOn()) {
            User.currentRole = .client
        } else {
            if !User.shared.isRealtor() {
                let viewController = OwnerRegistrationViewController()
                viewController.realtorModeCompletion = true

                ProfileTabViewController.shared.navigationController?.pushViewController(viewController, animated: true)
                
                sender.on = true
                
                return
            }
            
            User.currentRole = .realtor
        }
    }
    
    @objc func changeAvatarTapped() {
        
    }
    
    @objc func editProfileTapped() {
        let editProfileVC = UserProfileViewController()
        ProfileTabViewController.shared.navigationController?.pushViewController(editProfileVC, animated: true)
    }

    @objc func hideObjectsTapped() {
        
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProfileTableViewCell
        
        cell.titleLabel.text = tableViewItems[indexPath.row]
        //cell.iconImageView.image = UIImage(named: tableViewIcons[indexPath.row])
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = NotificationViewController()
            ProfileTabViewController.shared.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let settingsVC = SettingsViewController()
            ProfileTabViewController.shared.navigationController?.pushViewController(settingsVC, animated: true)
        } else if indexPath.row == 2 {
            let vc = WebViewPageViewController()
            
            vc.link = "https://pillowz.kz/help"
            
            ProfileTabViewController.shared.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 3 {
            let vc = FeedbackListViewController()
            
            ProfileTabViewController.shared.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 4 {
            let textToShare = "Когда я хочу снять жилье, то пользуюсь онлайн-сервисом Pillowz. Там нет посредников и фейков среди объявлений. К тому же, если меня не устраивает цена, я могу предложить свою и торговаться. Хочешь попробовать? Вот ссылка: https://pillowz.kz/dl"
            
            let objectsToShare = [textToShare] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = nil
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @objc func changeRoleToClient(){
        if (User.currentRole == .realtor) {
            User.currentRole = .client
        } else {
            User.currentRole = .realtor
        }
    }
    
    @objc func registerAsRealtor() {
        let dvc = SignUpViewController()
        dvc.realtorModeCompletion = true
        ProfileTabViewController.shared.navigationController?.pushViewController(dvc, animated: true)
    }
}
