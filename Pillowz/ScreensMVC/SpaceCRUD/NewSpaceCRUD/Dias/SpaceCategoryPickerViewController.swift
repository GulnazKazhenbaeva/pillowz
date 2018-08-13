//
//  SpaceCategoryPickerViewController.swift
//  Pillowz
//
//  Created by Samat on 30.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD

class SpaceCategoryPickerViewController: PillowzViewController {
    let progressView = UIProgressView()
    let tableView = UITableView()
    let bottomView = SpaceBottomView()
    var typeButton = TimeTypeButton()
    
    var categories:[NewSpaceCategory] = []
    var chosenCategory:NewSpaceCategory?

    let allCategories: [NewSpaceCategory]
        = [NewSpaceCategory(name: "Дом", unselectedImage: #imageLiteral(resourceName: "house-unselected"), selectedImage: #imageLiteral(resourceName: "house-selected"), value: "house"),
           NewSpaceCategory(name: "Квартира", unselectedImage: #imageLiteral(resourceName: "flat-unselected"), selectedImage: #imageLiteral(resourceName: "flat-selected"), value: "flat"),
           NewSpaceCategory(name: "Комната", unselectedImage: #imageLiteral(resourceName: "room-unselected"), selectedImage: #imageLiteral(resourceName: "room-selected"), value: "room"),
           NewSpaceCategory(name: "Спальное место", unselectedImage: #imageLiteral(resourceName: "bed-unselected"), selectedImage: #imageLiteral(resourceName: "bed-selected"), value: "bed"),
           NewSpaceCategory(name: "Хостел", unselectedImage: #imageLiteral(resourceName: "hostel-unselected"), selectedImage: #imageLiteral(resourceName: "hostel-selected"), value: "hostel")]
    
    let headerTextLabel = UILabel()
    
    override func loadView() {
        super.loadView()
        [progressView, typeButton, tableView, bottomView].forEach({view.addSubview($0)})
        
        progressView.setProgress(1/8, animated: true)
        progressView.tintColor = Colors.strongVioletColor
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        
        typeButton.buttonHeight = 34
        typeButton.snp.makeConstraints { (make) in
            make.top.equalTo(progressView.snp.bottom).offset(34)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(34)
        }
    
        bottomView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(48)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(typeButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        bottomView.nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        bottomView.previousButton.isHidden = true
        typeButton.button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        tapped()
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Выберите тип жилья"
        navigationItem.setHidesBackButton(true, animated: false)
        
        let rightButton: UIButton = UIButton(type: .custom)
        rightButton.setImage(#imageLiteral(resourceName: "CloseWhite2"), for: .normal)
        rightButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        rightButton.frame = CGRect(x:0, y:0, width:30, height:30)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tapped() {
        typeButton.isSelected = !typeButton.isSelected
        
        typeButton.view.changeSelection(toMonth: typeButton.isSelected)
        
        if typeButton.isSelected { //month
            categories = Array(allCategories.prefix(3))
        } else {//day
            categories = allCategories
        }
        tableView.reloadData()
    }
}

extension SpaceCategoryPickerViewController {
    @objc func nextTapped() {
        if (chosenCategory == nil) {
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        var type: String = "daily"
        
        if typeButton.isSelected {
            type = "monthly"
        }
        
        SpaceAPIManager.createSpaceWithCategory(type: type, category: chosenCategory!.value) { (space, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                //SpaceEditorManager.sharedInstance.currentEditingSpace = (space as! Space)
                SpacesManager.shared.currentEditingSpace = space as! Spaces
                
                let vc = NewSpaceCRUDViewController()
                SpaceEditorManager.sharedInstance.spaceCRUDVC = vc
                
                vc.isCreating = true
                
                self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension SpaceCategoryPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SpaceCategoryPickerTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SpaceCategoryPickerTableViewCell
        let category = categories[indexPath.row]
        cell.title = category.name
        
        if let chosen = chosenCategory {
            if category === chosen {
                cell.backView.backgroundColor = Colors.lightVioletColor
                cell.imgView.image = category.selectedImage.withRenderingMode(.alwaysOriginal)
            } else {
                cell.imgView.image = category.unselectedImage.withRenderingMode(.alwaysOriginal)
                cell.backView.backgroundColor = .clear
            }
        } else {
            cell.imgView.image = category.unselectedImage.withRenderingMode(.alwaysOriginal)
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        if category.value != "hostel" {
            chosenCategory = category
            tableView.reloadData()
        }
    }

}
