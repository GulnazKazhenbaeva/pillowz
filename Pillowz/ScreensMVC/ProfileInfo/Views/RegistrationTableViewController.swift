//
//  RegistrationTableViewController.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/30/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class RegistrationTableViewController: UITableViewController {
    var cellTypes: [String] = []
    var numberOfCells = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func loadView() {
        super.loadView()
        
        tableView.register(GuideTableViewCell.self, forCellReuseIdentifier: "guideCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells 
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "guideCell") as! GuideTableViewCell
        return cell
    }
}
