//
//  NewOfferViewController.swift
//  Pillowz
//
//  Created by Samat on 13.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD


class NewOfferViewController: PillowzViewController, UITableViewDataSource, UITableViewDelegate, SpaceOfferDelegate {
    var request:Request!
    var spaces:[Space] = []
    
    var chosenSpaces:[Space] = []
    
    let createOfferButton = PillowzButton()
    
    let tableView = UITableView()
    
    let loadingActivityView = UIActivityIndicatorView()
    
    let noObjectsLabel = UILabel()
    let openObjectButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Предложить"
                
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CreateSpaceOfferTableViewCell.classForCoder(), forCellReuseIdentifier: "spaceCell")
        tableView.estimatedRowHeight = 120
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullDownToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        self.view.bringSubview(toFront: createOfferButton)
        
        getSpaces()
        
        self.view.addSubview(loadingActivityView)
        loadingActivityView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        loadingActivityView.hidesWhenStopped = true
        loadingActivityView.activityIndicatorViewStyle = .gray
        loadingActivityView.startAnimating()
    }
    
    @objc func pullDownToRefresh() {
        getSpaces()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spaceCell") as! CreateSpaceOfferTableViewCell
        
        cell.delegate = self
        
        let space = spaces[indexPath.row]
        
        cell.space = space
        cell.request = request
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spaces.count
    }
    
    func didOfferSpace(_ space: Space) {
        var spaceIds = [Int]()
        var prices = [Int]()
        
        spaceIds.append(space.space_id.intValue)
        prices.append(space.offerPrice)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        RequestAPIManager.createOfferForRequestId(requestId: request.request_id!, prices: prices, spaceIds: spaceIds) { (requestObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                let vc = self.navigationController!.viewControllers[1] as! RequestOrOfferViewController
                vc.request = requestObject as? Request
                vc.tableView.reloadData()
                
                space.offerState = .alreadyOffered
                self.tableView.reloadData()
                
                DesignHelpers.makeToastWithText("Предложение отправлено")
            }
        }
    }

    func getSpaces() {
        SpaceAPIManager.getSpacesForRequest(request.request_id!) { (object, error) in
            self.loadingActivityView.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
            
            if (error == nil) {
                var visibleSpaces = [Space]()
                
                for space in object as! [Space] {
//                    if (space.status == .VISUAL) {
                    visibleSpaces.append(space)
//                    }
                }
                
//                if ((object as! [Space]).count == 0) {
//                    let infoView = ModalInfoView(titleText: "У Вас нет опубликованных объектов недвижимости", descriptionText: "Хотите добавить объект недвижимости?")
//                    
//                    infoView.addButtonWithTitle("Добавить объект", action: {
//                        MainTabBarController.shared.selectedIndex = 0
//                        
//                        if let nvc = MainTabBarController.shared.viewControllers![0] as? UINavigationController, let vc = nvc.visibleViewController as? RealtorSpacesViewController {
//                            vc.createNewObjectTapped()
//                        }
//                    })
//                    
//                    infoView.show()

//                }
                
                self.spaces = visibleSpaces

                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
