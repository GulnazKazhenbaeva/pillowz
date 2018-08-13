//
//  ValidationViewController.swift
//  Pillowz
//
//  Created by Samat on 18.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

public typealias SaveWithAPIClosure = () -> Void

protocol ValidationDelegate {
    func isValid() -> Bool
    func saveWithAPI()
}

class ValidationViewController: PillowzViewController, UIGestureRecognizerDelegate, ValidationDelegate {
    var dataChanged:Bool = false {
        didSet {
            if (dataChanged) {
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = !dataChanged
            }
        }
    }
    var isSaved:Bool = false {
        didSet {
            if (isSaved) {
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = isSaved
            }
        }
    }
    let backButton = UIButton()
    var saveButton = PillowzButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        let leftButton: UIButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "backGrey"), for: .normal)
        leftButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        leftButton.frame = CGRect(x:0, y:0, width:20, height:25)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton

//        let rightButton: UIButton = UIButton(type: .custom)
//        rightButton.setTitle("Сбросить все", for: .normal)
//        rightButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
//        rightButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
//        rightButton.addTarget(self, action: #selector(clearFilterTapped), for: .touchUpInside)
//        rightButton.frame = CGRect(x:0, y:0, width:50, height:30)
//        let rightBarButton = UIBarButtonItem(customView: rightButton)
//        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.view.addSubview(saveButton)
        PillowzButton.makeBasicButtonConstraints(button: saveButton, pinToTop: false)
        saveButton.addTarget(self, action: #selector(saveActionTapped), for: .touchUpInside)
    }
    
    @objc func clearFilterTapped() {
        
    }
    
    @objc func backAction() -> Void {
        if (!isSaved && dataChanged) {
            let alertController = UIAlertController(title: "Данные изменились, хотите сохранить изменения?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            let saveAction = UIAlertAction(title: "Сохранить", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                self.saveWithAPI()
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.cancel) {
                (result : UIAlertAction) -> Void in
                self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func saveWithAPI() {
        
    }
    
    func isValid() -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (!isSaved && dataChanged)
    }
    
    @objc func saveActionTapped() {
        if isValid() {
            saveWithAPI()
        } else {
            let alertController = UIAlertController(title: "Валидация", message: "Заполните все поля", preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "ОК", style: UIAlertActionStyle.cancel) {
                (result : UIAlertAction) -> Void in

            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
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
