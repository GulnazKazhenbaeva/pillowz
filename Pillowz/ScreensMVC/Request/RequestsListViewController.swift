//
//  RequestsListViewController.swift
//  Pillowz
//
//  Created by Samat on 09.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD
import XLPagerTabStrip
import FirebaseDatabase

enum RequestsDisplayMode {
    case client
    case realtorMy
    case realtorAll
}

class RequestsListViewController: TableViewPagingViewController, UITableViewDataSource, IndicatorInfoProvider, RequestTableViewCellDelegate {
    
    var displayMode:RequestsDisplayMode!
    //var itemInfo: IndicatorInfo = IndicatorInfo(title: "Мои заявки")
    
    var superVC:RealtorRequestsViewController?

    var requestFilter:RequestFilter!
    
    let createRequestButton = PillowzButton()
    
    var ref: DatabaseReference!

    var shouldShowLoadingIndicator = false
    
    var openNewRequestAfterLoadingCategories = false
    
    var noInfoView:NoInfoTapPlusView!
    
    var isLoadingRequests:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Мои заявки"
        
        if (!User.isLoggedIn() && User.currentRole == .client) {
            self.noInfoView = NoInfoTapPlusView(showPlus: true)
            self.noInfoView.noInfoText = "Ваш список заявок пуст. Создайте заявку."
            self.view.addSubview(self.noInfoView)
            self.noInfoView.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(Constants.screenFrame.size.height-200)
                make.bottom.equalToSuperview()
            })
        } else {
            self.noInfoView?.isHidden = true
        }
        
        tableView.register(RequestTableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        tableView.register(SpaceOfferTableViewCell.classForCoder(), forCellReuseIdentifier: "SpaceOfferTableViewCell")

        tableView.dataSource = self
        
        if (self.displayMode != .client) {
            
        } else {
            self.view.addSubview(createRequestButton)
            createRequestButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-Constants.basicOffset)
                make.right.equalToSuperview().offset(-Constants.basicOffset)
                make.width.height.equalTo(56)
            }
            createRequestButton.backgroundColor = UIColor(hexString: "#FF6B57")
            createRequestButton.setTitle("+", for: .normal)
            createRequestButton.titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 36)
            createRequestButton.setTitleColor(.white, for: .normal)
            createRequestButton.layer.cornerRadius = 28
            createRequestButton.dropShadow()
            createRequestButton.addTarget(self, action: #selector(createNewRequestTapped), for: .touchUpInside)
        }
        
        if let userId = User.shared.user_id, displayMode == .realtorAll {
            ref = Database.database().reference().child("requests_list").child(String(userId))
            
            ref.observe(DataEventType.value, with: { (snapshot) in
                let timestamp = snapshot.value as? NSNumber
                // ...
                if (timestamp != nil && self.tableView.contentOffset.y < 500) {
                    self.page = 1
                    self.loadNextPage()
                }
            })
        }
        
        self.page = 1
        self.loadNextPage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadedCategories), name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
    }
    
    @objc func loadedCategories() {
        let window = UIApplication.shared.delegate!.window!!
        
        MBProgressHUD.hide(for: window, animated: true)
        
        if (openNewRequestAfterLoadingCategories) {
            openNewRequest()
        }
        
        openNewRequestAfterLoadingCategories = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSource[indexPath.row] is Request {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RequestTableViewCell
            
            cell.request = dataSource[indexPath.row] as! Request
            cell.delegate = self
            
            return cell
        } else if dataSource[indexPath.row] is Offer {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceOfferTableViewCell") as! SpaceOfferTableViewCell
            
            let offer = dataSource[indexPath.row] as! Offer
            
            cell.request = openedRequest
            cell.offer = offer
            
            var viewed = true
            if (User.currentRole == .realtor && !offer.realtor_viewed) {
                viewed = false
            }
            if (User.currentRole == .client && !offer.client_viewed) {
                viewed = false
            }
            
            cell.spaceOfferView.unreadDotView.isHidden = viewed
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        return UITableViewCell()
    }
            
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if (self.displayMode == .realtorMy) {
            return IndicatorInfo(title: "Мои заявки")
        } else {
            return IndicatorInfo(title: "Все заявки")
        }
    }
    
    @objc func createNewRequestTapped() {
        if (CategoriesHandler.sharedInstance.categories.count == 0) {
            let window = UIApplication.shared.delegate!.window!!
            
            MBProgressHUD.showAdded(to: window, animated: true)
            
            openNewRequestAfterLoadingCategories = true
            CategoriesHandler.sharedInstance.getCategories()
        } else {
            openNewRequest()
        }
    }
    
    func openNewRequest() {
        let newRequestVC = OpenRequestStepsViewController.shared
        newRequestVC.shouldSetFirstAsInitialController = true
        
        self.present(UINavigationController(rootViewController: newRequestVC), animated: true, completion: nil)
    }
    
    override func loadNextPage() {
        if self.isLoadingRequests {
            self.tableView.refreshControl?.endRefreshing()
            return
        }
        
        self.isLoadingRequests = true
        
        self.noInfoView?.isHidden = true
        
        if self.displayMode == .client {
            RequestAPIManager.getClientRequests(limit: limit, page: page) { (responseObject, error) in
                self.tableView.refreshControl?.endRefreshing()

                self.isLoadingRequests = false
                
                if (error == nil) {
                    self.num_pages = (responseObject as! [Any])[1] as! Int

                    if (self.page <= 1) {
                        self.openedRequest = nil
                        
                        if self.num_pages > 1 {
                            self.isLastPage = false
                        } else {
                            self.isLastPage = true
                        }
                        
                        self.dataSource.removeAll()
                        self.tableView.reloadData()
                    }
                    
                    let loadedRequests = (responseObject as! [Any])[0] as! [Request]
                    
                    self.dataSource.append(contentsOf: loadedRequests as [AnyObject])
                    
                    self.insertNewLoadedDataToTableView()
                    
                    if self.dataSource.count == 0 {
                        self.noInfoView = NoInfoTapPlusView(showPlus: true)
                        self.noInfoView.noInfoText = "Ваш список заявок пуст. Создайте заявку."
                        self.view.addSubview(self.noInfoView)
                        self.noInfoView.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                        self.noInfoView?.isHidden = false
                    } else {
                        self.noInfoView?.isHidden = true
                    }
                } else {
                    self.isLastPage = true
                    
                    self.noInfoView = NoInfoTapPlusView(showPlus: true)
                    self.noInfoView.noInfoText = "Ваш список заявок пуст. Создайте заявку."
                    self.view.addSubview(self.noInfoView)
                    self.noInfoView.snp.makeConstraints({ (make) in
                        make.edges.equalToSuperview()
                    })
                    self.noInfoView?.isHidden = false
                }
            }
        } else  {
            var showingMy:Bool
            if self.displayMode == .realtorAll {
                showingMy = false
            } else {
                showingMy = true
            }
            
            if showingMy && !User.isLoggedIn() {
                self.isLoadingRequests = false
                self.shouldShowLoadingIndicator = false
                self.isLastPage = true
                self.tableView.refreshControl?.endRefreshing()
                return
            }

            if (shouldShowLoadingIndicator) {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            
            RequestAPIManager.getRealtorRequests(limit: limit, page: page, my: showingMy, sort_by: String(requestFilter.sort_by.rawValue), requestFilter: requestFilter, only_count: false, completion: { (responseObject, error) in
                self.isLoadingRequests = false

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
                    
                    
                    let loadedRequests = (responseObject as! [Any])[0] as! [Request]
                                        
                    self.dataSource.append(contentsOf: loadedRequests as [AnyObject])
                    
                    self.insertNewLoadedDataToTableView()
                    
                    
                    
                    if self.dataSource.count == 0 {
                        self.noInfoView = NoInfoTapPlusView(showPlus: false)
                        
                        self.noInfoView?.isHidden = false
                        
                        self.noInfoView.noInfoText = "У Вас нет заявок, попробуйте откликнуться на заявки клиентов"
                        self.view.addSubview(self.noInfoView)
                        self.noInfoView.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                        self.noInfoView.actionClosure = { () in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.superVC?.moveToViewController(at: 1)
                            }
                        }
                        
                        self.noInfoView.actionButton.setTitle("Откликнуться", for: .normal)
                        self.noInfoView?.isHidden = false
                    } else {
                        self.noInfoView?.isHidden = true
                    }
                } else {
                    self.isLastPage = true
                }
            })
        }
    }
    
    func openUserWithId(_ userId: Int) {
        let profileVC = UserProfileViewController()
        profileVC.user_id = userId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

    func openOffersOfRequest(_ request: Request) {
        self.removeOffersOfOpenedRequest()
        
        self.openedRequest = request
        
        self.insertOffersOfOpenedRequest()
    }
    
    func closeOffersOfRequest(_ request: Request) {
        self.removeOffersOfOpenedRequest()
    }
    
    func moreTappedForRequest(_ request: Request) {
        let alert = UIAlertController(title: "", message: "Выберите опцию", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if (User.currentRole == .client || request.req_type == .PERSONAL) {
            alert.addAction(UIAlertAction(title: "Отменить заявку", style: .default, handler: { action in
                var titleText:String = ""
                var descriptionText:String = ""
                var viewIdentifier:String = ""
                
                if (User.currentRole == .client) {
                    if (request.req_type == .PERSONAL) {//----eee
                        if let spaceName = request.space?.name {
                            titleText = "Вы уверены что хотите отменить заявку на жилье " + spaceName + "?"
                        } else {
                            if let spaceName = request.open_name {
                                titleText = "Вы уверены что хотите отменить заявку на жилье " + spaceName + "?"
                            }
                        }
                        
                        if titleText == "" {
                            titleText = "Вы уверены что хотите отменить заявку на жилье?"
                        }
                        
                        descriptionText = "Заявка будет удалена и вы больше не сможете по ней получать отклики."
                        
                        if (request.status == .COMPLETED) {
                            descriptionText = descriptionText + "\n\nВы отменяете заявку которая уже одобрена. Это может повлиять на Ваш рейтинг."
                        }
                        
                        viewIdentifier = "rejectTapped" + "Personal" + "Client"
                    } else {//----eee
                        titleText = "Вы уверены что хотите отменить открытую заявку?"
                        descriptionText = "Заявка будет удалена и вы больше не сможете по ней получать отклики."
                        
                        if (request.status == .COMPLETED) {
                            descriptionText = descriptionText + "\n\n Мы обнаружили что по данной заявке уже есть одно одобренное предложение. Отмена заявки может повлиять на Ваш рейтинг."
                        }
                        
                        viewIdentifier = "rejectTapped" + "Open" + "Client"
                    }
                } else {
                    if (request.req_type == .PERSONAL) {
                        titleText = "Вы уверены что хотите отклонить заявку на жилье " + request.space!.name + "?"
                        descriptionText = "Заявка будет удалена из списка и вы больше не сможете по ней делать отклики."
                        viewIdentifier = "rejectTapped" + "Personal" + "Realtor"
                    }
                }
                
                let infoView = ModalInfoView(titleText: titleText, descriptionText: descriptionText, viewIdentifier: viewIdentifier)
                
                infoView.addButtonWithTitle("Да", action: {
                    var status:RequestStatus
                    
                    if (User.currentRole == .client) {
                        status = .CLIENT_REJECTED
                    } else {
                        status = .REALTOR_REJECTED
                    }
                    
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    
                    if (request.req_type == .PERSONAL) {
                        RequestAPIManager.updatePersonalRequestStatus(request: request, status: status) { (responseObject, error) in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            
                            if (error == nil) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    } else {
                        RequestAPIManager.deleteRequest(request.request_id!, completion: { (responseObject, error) in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            
                            if (error == nil) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                })
                
                infoView.addButtonWithTitle("Нет", action: {
                    
                })
                
                infoView.show()
            }))
        }
        
        if (User.currentRole == .realtor && request.req_type == .OPEN) {
            alert.addAction(UIAlertAction(title: "Скрыть заявку", style: .default, handler: { action in
                let titleText = "Вы уверены что хотите скрыть заявку " + request.open_name! + "?"
                let descriptionText = "После скрытия заявка будет удалена из вашего списка заявок."
                let viewIdentifier = "hideTapped"
                
                let infoView = ModalInfoView(titleText: titleText, descriptionText: descriptionText, viewIdentifier: viewIdentifier)
                
                infoView.addButtonWithTitle("Да", action: {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    
                    RequestAPIManager.hideRequest(request.request_id!) { (responseObject, error) in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        if (error == nil) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
                
                infoView.addButtonWithTitle("Нет", action: {
                    
                })
                
                infoView.show()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
