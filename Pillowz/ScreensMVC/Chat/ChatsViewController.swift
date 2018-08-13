//
//  ChatsViewController.swift
//  Pillowz
//
//  Created by Samat on 07.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class ChatsViewController: PillowzViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()
    
    var chats:[Chat] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let loadingActivityView = UIActivityIndicatorView()
    
    var noInfoView:NoInfoTapPlusView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Сообщения"
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        tableView.register(ChatTableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        
        loadChats()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadChats), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        self.view.addSubview(loadingActivityView)
        loadingActivityView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(70)
        }
        loadingActivityView.hidesWhenStopped = true
        loadingActivityView.activityIndicatorViewStyle = .gray
        loadingActivityView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    @objc func loadChats() {
        ChatAPIManager.getChats(timestamp: 0, limit: 20) { (responseObject, error) in
            self.loadingActivityView.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
            self.noInfoView?.isHidden = true
            
            if (error == nil) {
                self.chats = responseObject as! [Chat]
                
                if self.chats.count == 0 {
                    self.noInfoView = NoInfoTapPlusView(showPlus: false)
                    
                    if (User.currentRole == .client) {
                        self.noInfoView.noInfoText = "Переписки появятся когда вы завершите сделки. Создайте заявку, чтобы получить предложение"
                    } else {
                        self.noInfoView.noInfoText = "Переписки появятся когда вы завершите сделки. Откликнитесь на заявки, чтобы совершить сделку"
                    }
                    self.view.addSubview(self.noInfoView)
                    self.noInfoView.snp.makeConstraints({ (make) in
                        make.edges.equalToSuperview()
                    })
                    self.noInfoView.actionClosure = { () in
                        MainTabBarController.shared.selectedIndex = 2
                    }
                    
                    if (User.currentRole == .client) {
                        self.noInfoView.actionButton.setTitle("Создать заявку", for: .normal)
                    } else {
                        self.noInfoView.actionButton.setTitle("Совершить сделку", for: .normal)
                    }

                    self.noInfoView.actionButton.setTitle("Совершить сделку", for: .normal)
                    self.noInfoView?.isHidden = false
                } else {
                    self.noInfoView?.isHidden = true
                }
            } else {
                if let error = error as NSError? {
                    if error.code == 100 {
                        self.chats = []
                        self.tableView.reloadData()
                        
                        self.noInfoView = NoInfoTapPlusView(showPlus: false)
                        self.noInfoView.noInfoText = "Для просмотра списка чатов войдите в аккаунт"
                        self.view.addSubview(self.noInfoView)
                        self.noInfoView.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                        self.noInfoView.actionClosure = { () in
                            MainTabBarController.shared.navigationController?.pushViewController(GuestRoleViewController(), animated: true)
                        }
                        self.noInfoView?.isHidden = false
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ChatTableViewCell
        
        cell.chat = chats[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chats[indexPath.row]
        
        chat.new_messages = 0
        
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true
        
        chatVC.room = chat.chat_id
        chatVC.chat = chat
        //chatVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
