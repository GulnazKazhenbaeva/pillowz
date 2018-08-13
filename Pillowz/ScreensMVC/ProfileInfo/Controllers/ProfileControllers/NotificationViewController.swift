//
//  NotificationViewController.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 05.03.18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import OneSignal

class NotificationViewController: PillowzViewController, UITableViewDelegate, UITableViewDataSource  {
    var tableView = UITableView()
    var notifications = [PillowzNotification]()
    
    override func loadView() {
        super.loadView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        
        getNotifications()
        
        tableView.reloadData()
    }
    
    func getNotifications() {
        AuthorizationAPIManager.getNotifications { (responseObject, error) in
            if (error == nil) {
                self.notifications = responseObject as! [PillowzNotification]
                self.tableView.reloadData()
            }
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = .white
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigationBar() {
        title = "Уведомления"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        cell.selectionStyle = .none
        cell.data = notifications[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.pushNotificationOpenedClosure(notification.data)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let notification = notifications[indexPath.row]
        
        let font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        
        let text = notification.contents
        
        let height = text.height(withConstrainedWidth: Constants.screenFrame.size.width - 2*Constants.basicOffset, font: font)

        return height + 50
    }
}
