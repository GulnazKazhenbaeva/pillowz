//
//  FilterViewController.swift
//  Pillowz
//
//  Created by Samat on 06.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol FilterDelegate {
    func didFinishFiltering()
}

class FilterViewController: PillowzViewController, SaveActionDelegate, UITextFieldDelegate, ExpandActionTableViewCellDelegate {
    static let shared = FilterViewController()
    
    var filter:Filter!
    let crudVM = CreateEditObjectTableViewGenerator()
    var delegate:FilterDelegate?
    let options:[String:String] = ["additional_rule":"longText", "other":"longText"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Фильтр"

        view.backgroundColor = .white
        
        crudVM.viewController = self
        crudVM.options = options
        
        crudVM.tableView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(0)
        }

        filter.crudVM = crudVM

        filter.getFields()
        
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
        rightButton.frame = CGRect(x:0, y:0, width:90, height:30)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(getSpacesCount), name: Notification.Name(Constants.changedFilterValueNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filter.crudVM?.tableView?.reloadData()
        
        getSpacesCount()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.changedFilterValueNotification), object: nil)
    }
    
    @objc func getSpacesCount() {
        SearchAPIManager.searchSpaces(filter: filter, limit: 0, page: 0, polygonString: nil, favourite: false, only_count:true,  completion: { (responseObject, error) in
            if (error == nil) {
                let count = responseObject as! Int
                
                self.crudVM.saveButton?.setTitle("Показать " + String(count) + " объявлений", for: .normal)
            }
        })
    }
    
    func expandButtonTapped() {
        filter.isShowingFullList = !filter.isShowingFullList
    }
    
    @objc func closeTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func clearFilterTapped() {
        filter.clearFilter()
        filter.getFields()
        
        crudVM.tableView.reloadData()
    }
    
    func actionButtonTapped() {
        self.delegate?.didFinishFiltering()
        self.navigationController?.dismiss(animated: true, completion: nil)
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
