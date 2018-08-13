//
//  TableViewPagingViewController.swift
//  Pillowz
//
//  Created by Samat on 14.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class TableViewPagingViewController:PillowzViewController {
    var limit: Int = 10
    var page: Int = 1
    let tableView = UITableView()
    var dataSource: [AnyObject] = []
    var isLastPage: Bool = false {
        didSet {
            if (isLastPage) {
                footerView.alpha = 0
            } else {
                footerView.alpha = 1
            }
        }
    }
    
    var num_pages: Int!
    
    var isLoading = false
    
    let footerView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.screenFrame.size.width, height: 150))
    
    var openedRequest:Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
        tableView.delegate = self
        
        footerView.backgroundColor = .white
        let activityIndicator = UIActivityIndicatorView()
        footerView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        activityIndicator.startAnimating()
        activityIndicator.activityIndicatorViewStyle = .gray
        
        tableView.tableFooterView = footerView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullDownToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc func pullDownToRefresh() {
        page = 1
        
        loadNextPage()
    }

    func loadNextPage() {
        
    }
    
    //called after you updated data source
    func insertNewLoadedDataToTableView() {
        isLoading = false
        
//        var indexPaths = [IndexPath]()
//        for i in 0..<limit {
//            let indexPath:IndexPath = IndexPath(row:(self.dataSource.count - 1 - i), section:0)
//
//            indexPaths.append(indexPath)
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.tableView.insertRows(at: indexPaths, with: .automatic)
//        }
        
        self.tableView.reloadData()
    }
}

extension TableViewPagingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = dataSource[indexPath.row]
        
        if (object is Request) {
            let request = object as! Request
            
            //marking as viewed
            request.client_viewed = true
            request.realtor_viewed = true
            if let cell = tableView.cellForRow(at: indexPath) as? RequestTableViewCell {
                cell.requestCellView.unreadDotView.isHidden = true
            }
            
            
            let requestVC = RequestOrOfferViewController()
            requestVC.request = request
            
            RequestUpdateFirebaseListener.shared.requestVC = requestVC
            RequestUpdateFirebaseListener.shared.request = request

            if (self is RequestsListViewController) {
                let vc = self as! RequestsListViewController
                if (vc.displayMode == .realtorMy) {
//                    requestVC.hideButton.isEnabled = false
                }
            }
            
            self.navigationController?.pushViewController(requestVC, animated: true)
        } else if (object is Offer) {
            let offer = object as! Offer
            
            //marking as viewed
            offer.client_viewed = true
            offer.realtor_viewed = true
            if let cell = tableView.cellForRow(at: indexPath) as? SpaceOfferTableViewCell {
                cell.spaceOfferView.unreadDotView.isHidden = true
            }
            
            let requestVC = RequestOrOfferViewController()
            requestVC.request = openedRequest
            requestVC.offer = offer
            
            self.navigationController?.pushViewController(requestVC, animated: true)
        } else if (object is Space) {
            let space = object as! Space
            
            let spaceVC = SpaceViewController()
            spaceVC.space = space
            
            if (self is SpacesListViewController) {
                if ((self as! SpacesListViewController).superViewController != nil) {
                    (self as! SpacesListViewController).superViewController.navigationController?.pushViewController(spaceVC, animated: true)
                } else {
                    (self as! SpacesListViewController).navigationController?.pushViewController(spaceVC, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (dataSource.count != 0) {
            if (indexPath.row == dataSource.count-1 && !isLastPage) {
                
                if (!isLoading) {
                    page = page + 1
                    
                    if (!isLastPage) {
                        isLoading = true
                        
                        loadNextPage()
                    }
                    
                    if (page >= num_pages && page > 1) {
                        page = num_pages
                        
                        isLastPage = true
                    }
                }
            }
        }
    }
    
    func removeOffersOfOpenedRequest() {
        if openedRequest != nil {
            guard let indexOfPreviouslyOpenedRequest = dataSource.index(where: { (request) -> Bool in
                return request === openedRequest!
            }) else {
                return
            }
            
            var removingIndexPaths:[IndexPath] = []
            
            for i in 0..<openedRequest!.offers!.count {
                removingIndexPaths.append(IndexPath(row: indexOfPreviouslyOpenedRequest+i+1, section: 0))
                
                dataSource.remove(at: indexOfPreviouslyOpenedRequest+1)
            }
            
            tableView.deleteRows(at: removingIndexPaths, with: .automatic)
            
            openedRequest = nil
        }
    }
    
    func insertOffersOfOpenedRequest() {
        guard let openedRequest = openedRequest else {
            return
        }
        
        let indexOfNewlyOpenedRequest = dataSource.index(where: { (request) -> Bool in
            return request === openedRequest
        })!
        
        var addingIndexPaths:[IndexPath] = []
        
        for i in 0..<openedRequest.offers!.count {
            addingIndexPaths.append(IndexPath(row: indexOfNewlyOpenedRequest+i+1, section: 0))
            
            dataSource.insert(openedRequest.offers![i], at: indexOfNewlyOpenedRequest+i+1)
        }
        
        tableView.insertRows(at: addingIndexPaths, with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource[indexPath.row] is Offer {
            return 160
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
