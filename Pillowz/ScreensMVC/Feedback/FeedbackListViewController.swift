//
//  ComplaintsListViewController.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 22.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class FeedbackListViewController: PillowzViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    var feedbackArray = [Feedback]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        
        getFeedback()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(getFeedback), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func getFeedback() {
        AuthorizationAPIManager.getFeedback { (responseObject, error) in
            self.refreshControl.endRefreshing()

            if (error == nil) {
                self.feedbackArray = responseObject as! [Feedback]
                
                if (self.feedbackArray.count == 0) {
                    let vc = CreateFeedbackViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func createFeedback() {
        let dvc = CreateFeedbackViewController()
        self.navigationController?.pushViewController(dvc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedbackArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FeedbackTableViewCell.self), for: indexPath) as! FeedbackTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.feedback = feedbackArray[indexPath.section]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedback = feedbackArray[indexPath.row]
        
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true

        chatVC.room = feedback.room
        
        ProfileTabViewController.shared.navigationController?.pushViewController(chatVC, animated: true)
    }
}

extension FeedbackListViewController {
    func setupNavigationBar() {
        title = "Обращения и жалобы"
        
        let createButton = UIBarButtonItem(image: UIImage.init(named: "plus")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(createFeedback))
        navigationItem.rightBarButtonItem = createButton
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        tableView.register(FeedbackTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(FeedbackTableViewCell.self))
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()//.offset(0)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
