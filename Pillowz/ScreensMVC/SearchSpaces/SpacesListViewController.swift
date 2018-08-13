//
//  SpacesListViewController.swift
//  Pillowz
//
//  Created by Samat on 04.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

enum SpacesListViewControllerType {
    case favourite
    case search
}

class SpacesListViewController: TableViewPagingViewController, UITableViewDataSource {
    var superViewController:SearchSpacesViewController!
    
    var type = SpacesListViewControllerType.search
    
    var shouldShowLoadingIndicator = false
    
    var navigationBarView = UIView()
    var addressPickerView = AddressPickerView()

    var searchFilterControlsView:SearchFilterControlsView!
    
    var lastContentOffset:CGFloat!
    
    var noInfoView:NoInfoTapPlusView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(navigationBarView)
        navigationBarView.backgroundColor = .white
        navigationBarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(-20)
            make.left.right.equalToSuperview()
            make.height.equalTo(108)
        }
        navigationBarView.dropShadow()
        
        searchFilterControlsView = SearchFilterControlsView(superViewController: superViewController, isForMap: false)
        navigationBarView.addSubview(searchFilterControlsView)
        searchFilterControlsView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        navigationBarView.addSubview(addressPickerView)
        addressPickerView.saveAddressWithAPIClosure = { (address, lat, lon, placeID) in
            UserLastUsedValuesForFieldAutofillingHandler.shared.address = address
            UserLastUsedValuesForFieldAutofillingHandler.shared.lat = lat!
            UserLastUsedValuesForFieldAutofillingHandler.shared.lon = lon!
            
            self.shouldShowLoadingIndicator = true
            self.page = 1
            
            self.loadNextPage()            
        }
        addressPickerView.deleteAddressClosure = { () in
            UserLastUsedValuesForFieldAutofillingHandler.shared.address = ""
            UserLastUsedValuesForFieldAutofillingHandler.shared.lat = 0
            UserLastUsedValuesForFieldAutofillingHandler.shared.lon = 0
            
            self.shouldShowLoadingIndicator = true
            self.page = 1
            
            self.loadNextPage()
        }
        addressPickerView.addressTextField.text = UserLastUsedValuesForFieldAutofillingHandler.shared.address
        addressPickerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(40)
        }
        addressPickerView.addressTextFieldBottomSeparatorView.isHidden = true
        
        tableView.dataSource = self
        tableView.register(SpaceTableViewCell.classForCoder(), forCellReuseIdentifier: "Space")
        tableView.separatorColor = .clear
        
        tableView.snp.remakeConstraints { (make) in
            if type == .search {
                make.top.equalTo(navigationBarView.snp.bottom)
            } else {
                make.top.equalToSuperview()
            }
            make.left.bottom.right.equalToSuperview()
        }
        
        navigationBarView.isHidden = type != .search
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadedCategories), name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
        
        if (type == .favourite) {
            self.navigationItem.title = "Избранные"
        }
        
        loadNextPage()
    }
    
    func showFilterAndDatesButtons(_ show:Bool) {
        self.view.layoutIfNeeded()
        
        if (show) {
            navigationBarView.snp.updateConstraints({ (make) in
                make.height.equalTo(108)
            })
        } else {
            navigationBarView.snp.updateConstraints({ (make) in
                make.height.equalTo(70)
            })
        }
        
        UIView.animate(withDuration: 0.25) {
            if show {
                self.searchFilterControlsView.alpha = 1.0
            } else {
                self.searchFilterControlsView.alpha = 0.0
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollPos = scrollView.contentOffset.y
        
        if (self.lastContentOffset > scrollPos) {
            showFilterAndDatesButtons(true)
        } else if (self.lastContentOffset < scrollPos) {
            showFilterAndDatesButtons(false)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    @objc func loadedCategories() {
        loadNextPage()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
    }
    
    override func loadNextPage() {
        let favourite = type == .favourite
        
        var filter:Filter
        
        if (favourite) {
            filter = Filter()
        } else {
            filter = superViewController.filter
        }
        
        if (shouldShowLoadingIndicator) {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        self.noInfoView?.isHidden = true

        SearchAPIManager.searchSpaces(filter: filter, limit: limit, page: page, polygonString: nil, favourite: favourite, only_count:false,  completion: { (responseObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.shouldShowLoadingIndicator = false
            
            self.tableView.refreshControl?.endRefreshing()

            if (error == nil) {
                self.num_pages = (responseObject as! [Any])[1] as! Int

                if (self.page <= 1) {
                    if self.num_pages > 1 {
                        self.isLastPage = false
                    } else {
                        self.isLastPage = true
                    }
                    
                    self.dataSource.removeAll()
                    self.tableView.reloadData()
                }
                
                let loadedSpaces = (responseObject as! [Any])[0] as! [Space]
                
                if self.page <= 1 && loadedSpaces.count == 0 {
                    if (self.type == .favourite) {
                        self.noInfoView = NoInfoTapPlusView(showPlus: false)
                        self.noInfoView.noInfoText = "Вы еще не добавляли объекты в Избранное"
                        self.view.addSubview(self.noInfoView)
                        self.noInfoView.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                        
                        self.noInfoView.actionClosure = { () in
                            MainTabBarController.shared.selectedIndex = 0
                        }
                        
                        self.noInfoView.actionButton.setTitle("Перейти в поиск", for: .normal)
                        
                        self.noInfoView?.isHidden = false
                    } else {
                        self.noInfoView = NoInfoTapPlusView(showPlus: false)
                        self.noInfoView.noInfoText = "Подходящих объявлений нет :(\n\nНе нашли то, что вам нужно? Создайте общую заявку и укажите все пожелания. Владелец жилья найдет вас сам!"
                        self.view.addSubview(self.noInfoView)
                        self.noInfoView.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                        
                        self.noInfoView.actionClosure = { () in
                            MainTabBarController.shared.selectedIndex = 2
                        }
                        
                        self.noInfoView.actionButton.setTitle("Создать заявку", for: .normal)
                        
                        self.noInfoView?.isHidden = false
                    }
                } else {
                    self.noInfoView?.isHidden = true
                }
                
                self.dataSource.append(contentsOf: loadedSpaces as [AnyObject])
                
                self.insertNewLoadedDataToTableView()
            } else {
                self.isLastPage = true
            }
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Space") as! SpaceTableViewCell
        
        cell.space = dataSource[indexPath.row] as! Space
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
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
