//
//  ListPickerViewController.swift
//  Pillowz
//
//  Created by Samat on 25.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

protocol ListPickerViewControllerDelegate {
    func didPickValue(_ value:AnyObject)
    func didPickMultipleValues(_ values:[AnyObject])
}

class ListPickerViewController: PillowzViewController, UITableViewDelegate, UITableViewDataSource {
    var values:[AnyObject]!
    let tableView = UITableView()
    var delegate:ListPickerViewControllerDelegate!
    
    var allowsMultipleSelection = false
    let saveButton = PillowzButton()
    var multipleSelectionValues:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        
        if (allowsMultipleSelection) {
            self.view.addSubview(saveButton)
            PillowzButton.makeBasicButtonConstraints(button: saveButton, pinToTop: false)
            saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return values.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        let value = values[indexPath.row]
        
        if (value is Country) {
            let country = value as! Country
            cell.textLabel?.text = country.name! + " (" + country.code! + ")"
        } else {
            cell.textLabel?.text = value.value(forKey: "name") as? String
        }
        cell.textLabel?.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        cell.textLabel?.textColor = Constants.paletteBlackColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!allowsMultipleSelection) {
            let value = values[indexPath.row]
            
            delegate.didPickValue(value)
            
            self.navigationController?.popViewController(animated: true)
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            
            let value = values[indexPath.row]
            
            let index = multipleSelectionValues.index(where: { (object) -> Bool in
                let firstString = (object as! NSObject).value(forKey: "name") as? String
                let secondString = (value as! NSObject).value(forKey: "name") as? String
                
                return firstString == secondString
            })

            if index != nil {
                multipleSelectionValues.remove(at: index!)
                cell?.accessoryType = .none
            } else {
                multipleSelectionValues.append(value)
                cell?.accessoryType = .checkmark
            }
        }
    }
    
    @objc func saveTapped() {
        delegate.didPickMultipleValues(multipleSelectionValues)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
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
