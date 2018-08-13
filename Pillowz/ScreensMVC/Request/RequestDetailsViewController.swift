//
//  RequestDetailsViewController.swift
//  Pillowz
//
//  Created by Samat on 20.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class RequestDetailsViewController: PillowzViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    
    var request:Request!
    
    var displayedComforts:[ComfortItem] = []
    var displayedRulesFields:[Field] = []
    var rulesFields:[Field]!
    
    var tableViewDataSource:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Детали заявки"
        
        rulesFields = CategoriesHandler.getFieldsOfObject(object: request!.space_rule!, shouldControlObject: false).0
        
        tableViewDataSource.append("fields" as AnyObject)
        
        tableViewDataSource.append("guests" as AnyObject)

        for comfort in request!.comforts! {
            if (comfort.checked == true) {
                tableViewDataSource.append(comfort)
                displayedComforts.append(comfort)
            }
        }
        
        for rulesField in rulesFields {
            if rulesField.type != "CharField" && rulesField.value.toBool() == true {
                tableViewDataSource.append(rulesField)
                displayedRulesFields.append(rulesField)
            }
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.tableFooterView = UIView()
        
        tableView.register(FieldsTableViewCell.classForCoder(), forCellReuseIdentifier: "fields")
        tableView.register(BooleanValuePickerTableViewCell.classForCoder(), forCellReuseIdentifier: "BooleanValuePickerTableViewCell")
        tableView.register(GuestsDetailsTableViewCell.classForCoder(), forCellReuseIdentifier: "guests")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = tableViewDataSource[indexPath.row]
        
        if (object is String) {
            let string = object as! String
            if (string == "fields") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "fields") as! FieldsTableViewCell
                
                cell.header = "Общие характеристики"
                cell.fields = Field.getNonEmptyFields(fields: request.fields!)
                
                return cell
            } else if (string == "guests") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "guests") as! GuestsDetailsTableViewCell
                
                cell.header = "Количество гостей"
                cell.guests_count = request.guests_count!
                
                return cell
            }
        } else if (object is ComfortItem) {
            let comfort = object as! ComfortItem
            
            let boolCell = tableView.dequeueReusableCell(withIdentifier: "BooleanValuePickerTableViewCell") as! BooleanValuePickerTableViewCell
            
            if (comfort === displayedComforts.first) {
                boolCell.header = "Желаемые удобства"
            } else {
                boolCell.header = ""
            }
            
            boolCell.removeSeparatorView()
            
            if (comfort === displayedComforts.last!) {
                boolCell.addSeparatorView()
            }
            
            boolCell.placeholder = comfort.name!
            
            boolCell.icon = comfort.logo_64x64
            
            boolCell.valuePickerSwitch.isHidden = true
            
            boolCell.nameLabel.snp.updateConstraints({ (make) in
                make.right.equalToSuperview().offset(-Constants.basicOffset)
            })
            
            return boolCell
        } else if (object is Field) {
            let field = object as! Field
            
            let boolCell = tableView.dequeueReusableCell(withIdentifier: "BooleanValuePickerTableViewCell") as! BooleanValuePickerTableViewCell
            
            if (field === displayedRulesFields.first) {
                boolCell.header = "Желаемые правила"
            } else {
                boolCell.header = ""
            }
            
            boolCell.removeSeparatorView()
            
            if (field === displayedRulesFields.last!) {
                boolCell.addSeparatorView()
            }
            
            boolCell.placeholder = field.name!
            
            boolCell.icon = field.icon
            boolCell.notAllowed = field.notAllowed
            
            boolCell.valuePickerSwitch.isHidden = true
            
            boolCell.nameLabel.snp.updateConstraints({ (make) in
                make.right.equalToSuperview().offset(-Constants.basicOffset)
            })
            
            return boolCell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let numberOfRows = (Field.getNonEmptyFields(fields: request.fields!).count + 1)/2
            
            return CGFloat(15 + 62*numberOfRows + 40)
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
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
