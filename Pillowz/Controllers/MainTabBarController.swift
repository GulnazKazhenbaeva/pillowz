//
//  MainTabBarController.swift
//  TabBarTest
//
//  Created by Samat on 24.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    static let shared = MainTabBarController()
    
    var currentIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.unselectedItemTintColor = .black
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.tabBar.addSubview(BadgeView.messagesBadge)
        BadgeView.messagesBadge.frame = CGRect(x: (Constants.screenFrame.size.width/5)*2 - Constants.screenFrame.size.width/10 + 12, y: 2, width: 14, height: 14)
        
        self.tabBar.addSubview(BadgeView.myRequestsClientBadge)
        BadgeView.myRequestsClientBadge.frame = CGRect(x: Constants.screenFrame.size.width/2 + 12, y: 2, width: 14, height: 14)
        
        self.tabBar.addSubview(BadgeView.myRequestsRealtorBadge)
        BadgeView.myRequestsRealtorBadge.frame = CGRect(x: Constants.screenFrame.size.width/2 + 12, y: 2, width: 7, height: 7)
        
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let navigationController = viewController as? UINavigationController else {
            return true
        }
        
        if navigationController.viewControllers.first is ProfileTabViewController && !User.isLoggedIn() {
            self.navigationController?.pushViewController(GuestRoleViewController(), animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.selectedIndex = self.currentIndex
            }
            
            return false
        }
        
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let userIsLoggedIn = User.isLoggedIn()
        
        if let indexOfTab = tabBar.items?.index(of: item), (indexOfTab != 4 && !userIsLoggedIn) || userIsLoggedIn {
            currentIndex = indexOfTab
        }
    }
    
    
    override func loadView() {
        super.loadView()
        
        self.tabBar.tintColor = .black
        self.tabBar.isTranslucent = false
        
        self.setClientOrRealtorControllers()
    }
    
    func setClientOrRealtorControllers() {
        var vc1:UIViewController!
        var vc3:UIViewController!
        var vc4:UIViewController!
        
        if (User.currentRole == .client) {
            vc1 = UINavigationController(rootViewController: SearchSpacesViewController())
            vc1.tabBarItem.image = #imageLiteral(resourceName: "search")
            vc1.tabBarItem.selectedImage = #imageLiteral(resourceName: "searchSelected")
            vc1.tabBarItem.title = "поиск"
            
            let requestsVC = RequestsListViewController()
            requestsVC.displayMode = .client
            vc3 = UINavigationController(rootViewController: requestsVC)
            vc3.tabBarItem.image = #imageLiteral(resourceName: "requests")
            vc3.tabBarItem.selectedImage = #imageLiteral(resourceName: "requestsSelected")
            vc3.tabBarItem.title = "заявки"
            
            let favouriteSpacesVC = SpacesListViewController()
            favouriteSpacesVC.type = .favourite
            vc4 = UINavigationController(rootViewController: favouriteSpacesVC)
            vc4.tabBarItem.image = #imageLiteral(resourceName: "favourite")
            vc4.tabBarItem.selectedImage = #imageLiteral(resourceName: "favouriteSelected")
            vc4.tabBarItem.title = "избранные"
        } else {
            vc1 = UINavigationController(rootViewController: RealtorSpacesViewController())
            vc1.tabBarItem.image = #imageLiteral(resourceName: "spaces")
            vc1.tabBarItem.selectedImage = #imageLiteral(resourceName: "spacesSelected")
            vc1.tabBarItem.title = "объекты"
            
            let requestsVC = RealtorRequestsViewController()
            
            vc3 = UINavigationController(rootViewController: requestsVC)
            vc3.tabBarItem.image = #imageLiteral(resourceName: "requests")
            vc3.tabBarItem.selectedImage = #imageLiteral(resourceName: "requestsSelected")
            vc3.tabBarItem.title = "заявки"

            vc4 = UINavigationController(rootViewController: CalendarOfPlansViewController())
            vc4.tabBarItem.image = #imageLiteral(resourceName: "calendar")
            vc4.tabBarItem.selectedImage = #imageLiteral(resourceName: "calendarSelected")
            vc4.tabBarItem.title = "календарь"
        }
        
        let vc2 = UINavigationController(rootViewController: ChatsViewController())
        vc2.tabBarItem.image = #imageLiteral(resourceName: "chat")
        vc2.tabBarItem.selectedImage = #imageLiteral(resourceName: "chatSelected")
        vc2.tabBarItem.title = "чат"

        let vc5 = UINavigationController(rootViewController: ProfileTabViewController.shared)
        vc5.tabBarItem.image = #imageLiteral(resourceName: "profile")
        vc5.tabBarItem.selectedImage = #imageLiteral(resourceName: "profileSelected")
        vc5.tabBarItem.title = "профиль"

        let viewControllers = [vc1, vc2, vc3, vc4, vc5]
        
        self.setViewControllers(viewControllers as? [UIViewController], animated: true)
    }
}
