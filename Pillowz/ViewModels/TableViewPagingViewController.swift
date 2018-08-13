//
//  TableViewPagingViewController.swift
//  Pillowz
//
//  Created by Samat on 14.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol TableViewPagingViewControllerDelegate: UITableViewDelegate {
    var limit:Int {get set}
    var page:Int {get set}
    var tableView:UITableView {get set}
    var dataSource:[AnyObject] {get set}
    var isLastPage:Bool {get set}
    
    func loadNextPage()
    
    func insertNewLoadedDataToTableView()
}

extension TableViewPagingViewControllerDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == dataSource.count-1) {
            loadNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = .white
        
        let activityIndicator = UIActivityIndicatorView()
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        activityIndicator.startAnimating()
        activityIndicator.activityIndicatorViewStyle = .gray
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (!isLastPage) {
            return 50
        } else {
            return 0
        }
    }
    
    //called after you updated data source
    func insertNewLoadedDataToTableView() {
        tableView.beginUpdates()
        
        var indexPaths = [IndexPath]()
        for i in 0..<limit {
            let indexPath:IndexPath = IndexPath(row:(self.dataSource.count - 1 - i), section:0)
            
            indexPaths.append(indexPath)
        }
        
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        tableView.endUpdates()
    }
}
