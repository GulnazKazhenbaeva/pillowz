//
//  NewFilterViewController.swift
//  Pillowz
//
//  Created by Kazhenbayeva Gulnaz on 8/12/18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class NewFilterViewController: PillowzViewController, SaveActionDelegate, UITextFieldDelegate, ExpandActionTableViewCellDelegate {
    static let shared = NewFilterViewController()
    
    
    var filter:Filter!
    let crudVM = CreateEditObjectTableViewGenerator()
    var delegate:FilterDelegate?
    let options:[String:String] = ["additional_rule":"longText", "other":"longText"]
    
    fileprivate let categories: [CategoryType] = [.house, .flat, .room, .bed, .hostel]
    
    
    fileprivate lazy var categotyButtons: [CategoryButton] = {
        return []
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        crudVM.viewController = self
        crudVM.options = options
        
        crudVM.tableView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(0)
        }
        
        filter.crudVM = crudVM
        setupNavBar()
        setupTypesContainer()
        
        filter.getFields()
        
        
        
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

}

// MARK: - UI
extension NewFilterViewController {
    
    fileprivate func setupNavBar() {
        // segmentedControl
        let segmentedControl = SPSegmentedControl()
        segmentedControl.frame = CGRect.init(x: 0, y: 0, width: 240, height: 35)
        segmentedControl.layer.borderColor = UIColor.pillowBorderColor.cgColor
        segmentedControl.backgroundColor = UIColor.pillowBlueLight
        segmentedControl.indicatorView.backgroundColor = UIColor.pillowBlue
        segmentedControl.styleDelegate = self
        segmentedControl.delegate = self
        
        let firstCell = self.createCell(
            text: "Посуточно",
            image: self.createImage(withName: "f_Day_selected")
        )
        let secondCell = self.createCell(
            text: "Помесячно",
            image: self.createImage(withName: "f_Month_selected")
        )
        for cell in [firstCell, secondCell] {
            cell.layout = .textWithImage
            segmentedControl.add(cell: cell)
        }
        self.navigationItem.titleView = segmentedControl
        
        // closeButton
        let leftButton: UIButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "close"), for: .normal)
        leftButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        leftButton.frame = CGRect(x:0, y:0, width:44, height:44)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    private func createCell(text: String, image: UIImage) -> SPSegmentedControlCell {
        let cell = SPSegmentedControlCell.init()
        cell.label.text = text
        cell.label.font = UIFont.OpenSans.regular()
        cell.imageView.image = image
        return cell
    }
    
    
    fileprivate func setupTypesContainer() {
        let containerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: view.width(), height: 100))
        
        var lastButton = CategoryButton()
        for i in 0..<categories.count {
            
            let button = CategoryButton.init(category: categories[i])
            categotyButtons.append(button)
            
            containerView.addSubview(button)
            button.snp.makeConstraints { m in
                if i == 0 {
                    m.left.equalToSuperview().offset(22)
                } else if i == categories.count - 1 {
                    m.right.equalToSuperview().offset(-14)
                } else {
                    m.left.equalTo(lastButton.snp.right).offset(14)
                }
                m.width.equalTo(56)
                m.height.equalTo(70)
                m.top.bottom.equalToSuperview()
            }
            lastButton = button
        }
        crudVM.tableView.tableHeaderView = containerView
        
    }
}
