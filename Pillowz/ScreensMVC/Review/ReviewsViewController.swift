//
//  ReviewsViewController.swift
//  Pillowz
//
//  Created by Samat on 26.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class ReviewsViewController: PillowzViewController, UITableViewDelegate, UITableViewDataSource, ReviewTableViewCellDelegate {
    
    var reviews:[Review]!
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Отзывы"
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReviewTableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 120
        
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ReviewTableViewCell
        
        cell.review = reviews[indexPath.row]
        cell.header = ""
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func showAllReviewsTapped() {
        
    }
    
    func openUserWithId(_ userId: Int) {
        let profileVC = UserProfileViewController()
        profileVC.user_id = userId
        self.navigationController?.pushViewController(profileVC, animated: true)
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
