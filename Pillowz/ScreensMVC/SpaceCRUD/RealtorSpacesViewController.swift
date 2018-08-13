//
//  .swift
//  Pillowz
//
//  Created by Samat on 03.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON

enum RealtorSpacesDisplayMode {
    case CRUD
    case offer
}

class RealtorSpacesViewController: PillowzViewController, UITableViewDelegate, UITableViewDataSource, SpaceAvailabilityDelegate {
    let tableView = UITableView()
    var spaces:[Space] = []
    var displayMode:RealtorSpacesDisplayMode = .CRUD
    
    let loadingActivityView = UIActivityIndicatorView()
    
    var shouldReloadTableView = false
    
    let createSpaceButton = UIButton()
    var noInfoView:NoInfoTapPlusView = NoInfoTapPlusView(showPlus: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Мои объекты"
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SpaceEditTableViewCell.classForCoder(), forCellReuseIdentifier: "spaceCell")
        tableView.estimatedRowHeight = 120
        tableView.tableFooterView = UIView()

        getSpaces()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullDownToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        self.view.addSubview(loadingActivityView)
        loadingActivityView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        loadingActivityView.hidesWhenStopped = true
        loadingActivityView.activityIndicatorViewStyle = .gray
        loadingActivityView.startAnimating()
        
        self.view.addSubview(createSpaceButton)
        createSpaceButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.height.equalTo(56)
        }
        createSpaceButton.backgroundColor = UIColor(hexString: "#FF6B57")
        createSpaceButton.setTitle("+", for: .normal)
        createSpaceButton.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 36)
        createSpaceButton.setTitleColor(.white, for: .normal)
        createSpaceButton.layer.cornerRadius = 28
        createSpaceButton.dropShadow()
        createSpaceButton.addTarget(self, action: #selector(createNewObjectTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (shouldReloadTableView || (User.isLoggedIn() && !noInfoView.isHidden)) {
            shouldReloadTableView = false
            getSpaces()
        }
    }
    
    @objc func pullDownToRefresh() {
        getSpaces()
    }

    @objc func createNewObjectTapped() {
        loadCategories()
    }
    
    func loadCategories() {
        shouldReloadTableView = true
        
        if !User.isLoggedIn() {
            let infoView = ModalInfoView(titleText: "Вы не зарегистрированы", descriptionText: "Для создания объекта недвижимости нужно войти")
            
            infoView.addButtonWithTitle("Войти", action: {
                MainTabBarController.shared.navigationController?.pushViewController(GuestRoleViewController(), animated: true)
            })
            
            infoView.show()
        } else {
            let vc = SpaceCategoryPickerViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getSpaces() {
        SpaceAPIManager.getSpaces { (object, error) in
            self.noInfoView.isHidden = true

            self.loadingActivityView.stopAnimating()

            self.tableView.refreshControl?.endRefreshing()
            
            if (error == nil) {
                self.spaces = object as! [Space]
                self.tableView.reloadData()
                
                if self.spaces.count == 0 {
                    self.noInfoView = NoInfoTapPlusView(showPlus: true)
                    self.noInfoView.noInfoText = "Здесь будут показаны ваши объекты недвижимости. Добавьте первый, нажав на кнопку «Создать»"
                    self.view.addSubview(self.noInfoView)
                    self.noInfoView.snp.makeConstraints({ (make) in
                        make.edges.equalToSuperview()
                    })
                    self.noInfoView.isHidden = false
                } else {
                    self.noInfoView.isHidden = true
                }
            } else {
                if let error = error as NSError? {
                    if error.code == 100 {
                        self.spaces = []
                        self.tableView.reloadData()

                        self.noInfoView = NoInfoTapPlusView(showPlus: true)
                        self.noInfoView.noInfoText = "Для того, создать список объектов недвижимости - нужно авторизоваться"
                        self.view.addSubview(self.noInfoView)
                        self.noInfoView.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                        self.noInfoView.actionClosure = { () in
                            MainTabBarController.shared.navigationController?.pushViewController(GuestRoleViewController(), animated: true)
                        }
                        self.noInfoView.isHidden = false
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return spaces.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spaceCell") as! SpaceEditTableViewCell
        
        cell.space = spaces[indexPath.row]
        cell.availabilityDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldReloadTableView = true
        
        let space = spaces[indexPath.row]
        
        SpaceEditorManager.sharedInstance.currentEditingSpace = space
        
        let vc = NewSpaceCRUDViewController()
        SpaceEditorManager.sharedInstance.spaceCRUDVC = vc

        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    func addAvailabilityForSpace(_ space: Space) {
        let alert = UIAlertController(title: "", message: "Выберите опцию", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Добавить бронь", style: .default, handler: { action in
            let vc = PeriodPickerViewController()
            vc.mode = .booking
            vc.space = space
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Удалить объект недвижимости", style: .default, handler: { action in
            let infoView = ModalInfoView(titleText: "Вы уверены, что хотите удалить объект недвижимости?", descriptionText: "Это действие будет необратимо. ")
            
            infoView.addButtonWithTitle("Удалить", action: {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                
                SpaceAPIManager.deleteSpace(space: space) { (responseObject, error) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    if (error == nil) {
                        DesignHelpers.makeToastWithText("Объект удален")

                        let json = responseObject as! JSON
                        self.spaces = Space.parseSpacesArray(json: json["spaces"].arrayValue, forMap: false)
                        self.tableView.reloadData()
                    }
                }
            })
            
            infoView.addButtonWithTitle("Отмена", action: {
                
            })
            
            infoView.show()
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
