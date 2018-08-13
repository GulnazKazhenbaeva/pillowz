//
//  RequestFilterViewController.swift
//  Pillowz
//
//  Created by Samat on 25.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol RequestFilterDelegate {
    func didFinishFiltering()
}

class RequestFilterViewController: PillowzViewController, SaveActionDelegate {
    var filter:RequestFilter!
    let crudVM = CreateEditObjectTableViewGenerator()
    var delegate:RequestFilterDelegate?
    
    let saveButton = PillowzButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Фильтр"

        view.backgroundColor = .white

        filter.crudVM = crudVM
        
        crudVM.viewController = self
        
        crudVM.tableView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(0)
        }
        
        crudVM.headers = filter.headers
        crudVM.object = filter.parameters as AnyObject
        
        let leftButton: UIButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "close"), for: .normal)
        leftButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        leftButton.frame = CGRect(x:0, y:0, width:44, height:44)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightButton: UIButton = UIButton(type: .custom)
        rightButton.setTitle("Сбросить все", for: .normal)
        rightButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        rightButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        rightButton.addTarget(self, action: #selector(clearFilterTapped), for: .touchUpInside)
        rightButton.frame = CGRect(x:0, y:0, width:50, height:30)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.view.addSubview(saveButton)
        PillowzButton.makeBasicButtonConstraints(button: saveButton, pinToTop: false)
        saveButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getRequestsCount), name: Notification.Name(Constants.changedRequestFilterValueNotification), object: nil)
        
        getRequestsCount()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.changedRequestFilterValueNotification), object: nil)
    }
    
    @objc func getRequestsCount() {
        RequestAPIManager.getRealtorRequests(limit: 0, page: 0, my: false, sort_by: String(filter.sort_by.rawValue), requestFilter: filter, only_count:true, completion: { (responseObject, error) in
            if (error == nil) {
                let count = responseObject as! Int
                
                self.saveButton.setTitle("Показать " + String(count) + " заявок", for: .normal)
            }
        })
    }

    @objc func closeTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func actionButtonTapped() {
        self.delegate?.didFinishFiltering()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func clearFilterTapped() {
        //filter.clearFilter()
        filter.getParameters()
        
        crudVM.tableView.reloadData()
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
