//
//  RealtorRequestsViewController.swift
//  Pillowz
//
//  Created by Samat on 25.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import MBProgressHUD

class RealtorRequestsViewController: ButtonBarPagerTabStripViewController, RequestFilterDelegate {
    let filter:RequestFilter = RequestFilter()
    let allRequestsVC = RequestsListViewController()
    let myRequestsVC = RequestsListViewController()
    
    var isShowingAllRequests = true
    
    var openFilterAfterLoadingCategories:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Заявки"
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        DesignHelpers.setBasicSettingsForTabVC(viewController: self)
                
        let filterRightButton: UIButton = UIButton(type: .custom)
        filterRightButton.setImage(UIImage(named: "filter"), for: .normal)
        filterRightButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        filterRightButton.frame = CGRect(x:0, y:0, width:35, height:44)
        let filterRightBarButton = UIBarButtonItem(customView: filterRightButton)
        
        self.navigationItem.rightBarButtonItems = [filterRightBarButton]

        NotificationCenter.default.addObserver(self, selector: #selector(loadedCategories), name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
        
        if (User.shared.isRealtor() && User.isLoggedIn()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.moveToViewController(at: 1)
            }
        }
        
        let text = String(BadgeView.myRequestsRealtorTopTabBadge.value)
        
        var width:CGFloat
        
        if (text.count > 1) {
            width = text.width(withConstraintedHeight: 20, font: BadgeView.myRequestsRealtorTopTabBadge.font)
        } else {
            width = 14
        }
        
        self.buttonBarView.addSubview(BadgeView.myRequestsRealtorTopTabBadge)
        BadgeView.myRequestsRealtorTopTabBadge.frame = CGRect(x: 180, y: 5, width: width + 6, height: 14)
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
        isShowingAllRequests = toIndex == 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func filterTapped() {
        if (CategoriesHandler.sharedInstance.categories.count == 0) {
            let window = UIApplication.shared.delegate!.window!!
            
            MBProgressHUD.showAdded(to: window, animated: true)
            
            openFilterAfterLoadingCategories = true
            CategoriesHandler.sharedInstance.getCategories()
        } else {
            openFilter()
        }
    }
    
    func openFilter() {
        let filterVC = RequestFilterViewController()
        filterVC.filter = self.filter
        filterVC.delegate = self
        
        self.present(UINavigationController(rootViewController: filterVC), animated: true, completion: nil)
    }
    
    @objc func loadedCategories() {
        let window = UIApplication.shared.delegate!.window!!
        
        MBProgressHUD.hide(for: window, animated: true)
        
        if (openFilterAfterLoadingCategories) {
            openFilter()
        }
        
        openFilterAfterLoadingCategories = false
    }
    
    func didFinishFiltering() {
        allRequestsVC.page = 1
        allRequestsVC.shouldShowLoadingIndicator = true
        allRequestsVC.loadNextPage()
        myRequestsVC.loadNextPage()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //allRequestsVC.itemInfo = IndicatorInfo(title: "Все заявки")
        allRequestsVC.requestFilter = filter
        allRequestsVC.displayMode = .realtorAll
        //myRequestsVC.itemInfo = IndicatorInfo(title: "Мои заявки")
        myRequestsVC.requestFilter = filter
        myRequestsVC.displayMode = .realtorMy
        return [allRequestsVC, myRequestsVC]
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
