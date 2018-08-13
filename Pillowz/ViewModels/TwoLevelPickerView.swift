//
//  TwoLevelPickerView.swift
//  Pillowz
//
//  Created by Samat on 01.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class TwoLevelPickerView: UIView, UITableViewDataSource, UITableViewDelegate {
    let firstLevelTableView = UITableView()
    let secondLevelTableView = UITableView()

    var firstLevelObjects:[Any] = []
    var secondLevelObjects:[[Any]]?
    
    var currentSecondLevelObjects:[Any]?
    
    var chosenFirstLevelObject:Any?
    var chosenSecondLevelObject:Any?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        firstLevelTableView.dataSource = self
        firstLevelTableView.delegate = self
        
        self.addSubview(firstLevelTableView)
        
        firstLevelTableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        secondLevelTableView.dataSource = self
        secondLevelTableView.delegate = self

        self.addSubview(secondLevelTableView)

        secondLevelTableView.snp.makeConstraints { (make) in
            make.top.equalTo(firstLevelTableView.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        firstLevelTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        secondLevelTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === firstLevelTableView {
            return firstLevelObjects.count
        } else {
            if (currentSecondLevelObjects != nil) {
                return currentSecondLevelObjects!.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        if tableView === firstLevelTableView {
            let firstLevelObject = firstLevelObjects[indexPath.row]
            
            if (firstLevelObject is String) {
                cell.textLabel?.text = firstLevelObject as? String
            } else {
                let object = firstLevelObject as! NSObject
                cell.textLabel?.text = object.value(forKey: "name") as? String
            }
        } else {
            let secondLevelObject = currentSecondLevelObjects![indexPath.row]
            
            if (secondLevelObject is String) {
                cell.textLabel?.text = secondLevelObject as? String
            } else {
                let object = secondLevelObject as! NSObject
                cell.textLabel?.text = object.value(forKey: "name") as? String
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === firstLevelTableView {
            chosenFirstLevelObject = firstLevelObjects[indexPath.row]
            
            currentSecondLevelObjects = secondLevelObjects?[indexPath.row]
            
            secondLevelTableView.reloadData()
        } else {
            chosenSecondLevelObject = currentSecondLevelObjects![indexPath.row]
        }
    }

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
