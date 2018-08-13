//
//  SpaceCRUDComfortsViewController.swift
//  Pillowz
//
//  Created by Samat on 04.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceCRUDComfortsViewController: StepViewController {
    
    let crudVM = CreateEditObjectTableViewGenerator()
    var fields:[AnyObject] = []
    var headers:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        crudVM.viewController = self
        generateFields()
        crudVM.headers = headers
        crudVM.object = fields as AnyObject
    }
    
    func generateFields() {
        SpaceEditorManager.sharedInstance.comforts = SpaceEditorManager.sharedInstance.currentEditingSpace!.comforts!
        fields.append(contentsOf: SpaceEditorManager.sharedInstance.comforts as [AnyObject])
        
        for _ in 0..<fields.count {
            headers.append("")
        }
    }

    override func checkIfAllFieldsAreFilled() -> Bool {
        return true
    }

}
