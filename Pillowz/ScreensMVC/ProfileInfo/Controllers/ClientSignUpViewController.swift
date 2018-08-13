//
//  ClientSignUpViewController.swift
//  Pillowz
//
//  Created by Samat on 31.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class ClientSignUpViewController: UIViewController {

    let crudVM = CreateEditObjectTableViewGenerator()

    let client = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        crudVM.viewController = self
        crudVM.object = client
        crudVM.keys = ["name", "phoneNumber", "password", "countryCode"]
        crudVM.tableView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.bottom.equalToSuperview().offset(100)
        }
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
