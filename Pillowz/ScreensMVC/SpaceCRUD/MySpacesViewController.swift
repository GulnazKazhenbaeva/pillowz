//
//  RealtorSpacesViewController.swift
//  Pillowz
//
//  Created by Samat on 03.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class RealtorSpacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()
    var spaces:[Space] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Мои объекты"
        
        let button1 = UIBarButtonItem(image: UIImage(named: "ic_enterprise_storage"), style: .plain, target: self, action:#selector(RealtorSpacesViewController.createNewObjectTapped))
        self.navigationItem.rightBarButtonItem  = button1
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SpaceEditTableViewCell.classForCoder(), forCellReuseIdentifier: "spaceCell")
        
        loadSpaces()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullDownToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func pullDownToRefresh() {
        loadSpaces()
    }

    @objc func createNewObjectTapped() {
        loadCategories()
    }
    
    func loadCategories() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        SpaceAPIManager.getSpaceCategories { (object) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let categories = object as! [SpaceCategory]
            let vc = SpaceCategoryPickerViewController()
            vc.firstLevelCategories = categories
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func loadSpaces() {
        SpaceAPIManager.getSpaces { (object) in
            self.spaces = object as! [Space]
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return spaces.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spaceCell") as! SpaceEditTableViewCell
        
        cell.space = spaces[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let space = spaces[indexPath.row]
        
        let vc = SpaceEditViewController()
        
        SpaceEditorManager.sharedInstance.currentEditingSpace = space
        
        self.navigationController?.pushViewController(vc, animated: true)
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
