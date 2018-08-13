//
//  SettingsPage.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/8/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class SettingsViewController: PillowzViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    let textLabelTitles = ["Изменить пароль", "Условия предоставления услуг", "Выйти из аккаунта", "Версия приложения"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textLabelTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ProfileTableViewCell
        
        cell?.titleLabel.text = textLabelTitles[indexPath.row]
        
        if indexPath.row != 3 {
            cell?.accessoryType = .disclosureIndicator
            cell?.detailTextLabel?.font = UIFont.init(name: "OpenSans-Light", size: 12)!
        } else {
            cell?.accessoryType = .none
            cell?.detailTextLabel?.font = UIFont.init(name: "OpenSans-Light", size: 16)!
            cell?.detailTextLabel?.textColor = Constants.paletteVioletColor
            
            cell?.detailTextLabel?.text = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        }
        
        cell?.selectionStyle = .none
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            let vc = ChangePasswordViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if (indexPath.row == 1) {
            let vc = WebViewPageViewController()
            
            vc.link = "https://pillowz.kz/terms"
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else if (indexPath.row == 2) {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            AuthorizationAPIManager.logout { (responseObject, error) in
                MBProgressHUD.hide(for: self.view, animated: true)

                if error == nil {
                    ProfileTabViewController.shared.navigationController?.popToRootViewController(animated: true)
                    User.logout()
                    ProfileTabViewController.shared.profileView.isHidden = true
                    ProfileTabViewController.shared.loginView.isHidden = false
                    MainTabBarController.shared.selectedIndex = 0
                    MainTabBarController.shared.navigationController?.pushViewController(GuestRoleViewController(), animated: true)
                    
                    User.currentRole = .client
                }
            }
        }
    }
}

extension SettingsViewController {
    func setupNavigationBar() {
        title = "Настройки"
//        let newBackButton = UIBarButtonItem(image: UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
//        navigationItem.hidesBackButton = true
//        navigationItem.leftBarButtonItem = newBackButton
    }
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
    }
}

