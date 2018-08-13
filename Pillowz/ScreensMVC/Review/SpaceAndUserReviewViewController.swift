//
//  SpaceAndUserReviewViewController.swift
//  Pillowz
//
//  Created by Samat on 20.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SpaceAndUserReviewViewController: ButtonBarPagerTabStripViewController {

    var request:Request!
    
    let spaceReviewVC = CreateReviewViewController()
    let userReviewVC = CreateReviewViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Отзыв"
        
        self.view.backgroundColor = .white
        
        DesignHelpers.setBasicSettingsForTabVC(viewController: self)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        spaceReviewVC.isUser = false
        spaceReviewVC.itemInfo = "Объект"
        spaceReviewVC.request = request
        spaceReviewVC.superVC = self
        userReviewVC.isUser = true
        userReviewVC.itemInfo = "Владелец"
        userReviewVC.request = request
        userReviewVC.superVC = self

        return [spaceReviewVC, userReviewVC]
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
