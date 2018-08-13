//
//  SpaceCRUDPricesViewController.swift
//  Pillowz
//
//  Created by Samat on 04.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceCRUDPricesViewController: StepViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    var prices:[Price] = []
    var headers:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.register(PriceTableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        generateFields()
        
        let _ = checkIfAllFieldsAreFilled()
    }
    
    func generateFields() {
        for price in SpaceEditorManager.sharedInstance.currentEditingSpace.prices! {
            if price.rent_type == .HOURLY {
                continue
            }
            
            prices.append(price)
            headers.append(price.rent_type_display!["ru"]!)
        }
        
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PriceTableViewCell
        
        let price = prices[indexPath.row]
        
        cell.header = headers[indexPath.row]
        cell.initialValue = price.price
        cell.didPickValueClosure = { (newValue) in
            if let spaceCRUDVC = SpaceEditorManager.sharedInstance.spaceCRUDVC, spaceCRUDVC.isPublished && !spaceCRUDVC.shouldSendToModerationWhileEditing {
                let infoView = ModalInfoView(titleText: "Изменение этих данных отправит объект недвижимости на модерацию", descriptionText: "Вы уверены, что хотите изменить данные об объекте недвижимости?")
                
                infoView.addButtonWithTitle("Да", action: {
                    price.price = newValue
                    SpaceEditorManager.sharedInstance.spaceCRUDVC!.shouldSendToModerationWhileEditing = true
                })
                
                infoView.addButtonWithTitle("Отмена", action: {
                    cell.initialValue = price.price
                    self.view.endEditing(true)
                })
                
                infoView.show()
            } else {
                price.price = newValue
            }
            
            let _ = self.checkIfAllFieldsAreFilled()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prices.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func checkIfAllFieldsAreFilled() -> Bool {
        SpaceEditorManager.sharedInstance.spaceCRUDVC!.nextButton.backgroundColor = Constants.paletteLightGrayColor
        
        var filled = false
        
        for price in SpaceEditorManager.sharedInstance.currentEditingSpace.prices! {
            if (price.price != nil && price.price != 0) {
                filled = true
            }
        }

        SpaceEditorManager.sharedInstance.spaceCRUDVC!.nextButton.isEnabled = filled
        
        if filled {
            SpaceEditorManager.sharedInstance.spaceCRUDVC!.nextButton.backgroundColor = UIColor(hexString: "#FA533C")
        }
        
        return filled
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
