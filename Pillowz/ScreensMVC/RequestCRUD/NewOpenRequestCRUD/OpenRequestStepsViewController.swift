//
//  OpenRequestStepsViewController.swift
//  Pillowz
//
//  Created by Samat on 17.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD


class OpenRequestStepsViewController: StepsViewController, DateAndTimePickerViewControllerDelegate {
    static let shared = OpenRequestStepsViewController()
    var shouldSetFirstAsInitialController = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberOfPages = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (shouldSetFirstAsInitialController) {
            self.title = "Какое вам нужно жильё?"
            
            self.currentPage = 0
            self.currentVC = self.getItemController(itemIndex: 0)! as! StepViewController
            
            self.pageViewController.setViewControllers([currentVC], direction: .reverse, animated: false, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        shouldSetFirstAsInitialController = false
    }
    
    override func setTitleAndProgressForCurrentPage() {
        if (currentPage == 0) {
            self.title = "Какое Вам нужно жильё?"
        } else if (currentPage == 1) {
            if progressView.progress < 0.4 {
                progressView.setProgress(0.4, animated: true)
            }
            
            self.title = "Какие удобства Вам необходимы?"
        } else if (currentPage == 2) {
            if progressView.progress < 0.8 {
                progressView.setProgress(0.8, animated: true)
            }
            
            self.title = "На какой период вам нужно жильё?"
        } else if (currentPage == 3) {
            if progressView.progress < 0.95 {
                progressView.setProgress(0.95, animated: true)
            }
            
            self.title = "Цена"
        }
    }
    
    override func getItemController(itemIndex: Int) -> UIViewController? {
        if itemIndex < numberOfPages {
            var vc:StepViewController!
            
            if (itemIndex == 0) {
                vc = OpenRequestFirstStepViewController.shared
            } else if (itemIndex == 1) {
                vc = OpenRequestSecondStepViewController.shared
            } else if (itemIndex == 2) {
                vc = DateAndTimePickerViewController()
                (vc as! DateAndTimePickerViewController).rentType = UserLastUsedValuesForFieldAutofillingHandler.shared.rentType
                (vc as! DateAndTimePickerViewController).delegate = self
                (vc as! DateAndTimePickerViewController).isForSteps = true

            } else if (itemIndex == 3) {
                vc = OpenRequestFourthStepViewController.shared
            }
            
            if (vc == nil) {
                return nil
            }
            
            vc.itemIndex = itemIndex
            
            currentVC = vc
            
            return vc
        }
        
        return nil
    }
    
    func didPickStartDate(_ startDate: Date, endDate: Date?) {
        var endDate = endDate
        
        let start_time = Int(startDate.timeIntervalSince1970)
        
        var end_time:Int
        
        if (UserLastUsedValuesForFieldAutofillingHandler.shared.rentType == .HALFDAY) {
            endDate = startDate.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
        } else if (UserLastUsedValuesForFieldAutofillingHandler.shared.rentType == .MONTHLY) {
            endDate = startDate.add(.init(seconds: 0, minutes: 0, hours:0, days: 0, weeks: 0, months: 1, years: 0))
        }
        
        end_time = Int(endDate!.timeIntervalSince1970)
        
        CurrentNewOpenRequestValues.shared.startTime = start_time
        CurrentNewOpenRequestValues.shared.endTime = end_time
    }
    
    override func lastStepTapped() {
        createRequest()
    }
    
    func createRequest() {
        CurrentNewOpenRequestValues.shared.bargain = OpenRequestFourthStepViewController.shared.bargainPickerSwitch.isOn
        
        if (UserLastUsedValuesForFieldAutofillingHandler.shared.address == "" || UserLastUsedValuesForFieldAutofillingHandler.shared.lat == 0 || UserLastUsedValuesForFieldAutofillingHandler.shared.lon == 0 || CurrentNewOpenRequestValues.shared.startTime == nil || CurrentNewOpenRequestValues.shared.endTime == nil || CurrentNewOpenRequestValues.shared.price == 0 || CurrentNewOpenRequestValues.shared.bargain == nil || CurrentNewOpenRequestValues.shared.chosenCategoryFields == nil || UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory == "") {
            
            DesignHelpers.makeToastWithText("Заполните все данные")

            return
        }
        
        if (!User.isLoggedIn()) {
            self.navigationController?.pushViewController(GuestRoleViewController(), animated: true)
            
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        RequestAPIManager.createRequest(address: UserLastUsedValuesForFieldAutofillingHandler.shared.address, lat: UserLastUsedValuesForFieldAutofillingHandler.shared.lat, lon: UserLastUsedValuesForFieldAutofillingHandler.shared.lon, start_time: CurrentNewOpenRequestValues.shared.startTime, end_time: CurrentNewOpenRequestValues.shared.endTime, rent_type: UserLastUsedValuesForFieldAutofillingHandler.shared.rentType, price: CurrentNewOpenRequestValues.shared.price, bargain: CurrentNewOpenRequestValues.shared.bargain, rules: CurrentNewOpenRequestValues.shared.rules, fields: CurrentNewOpenRequestValues.shared.chosenCategoryFields, category: UserLastUsedValuesForFieldAutofillingHandler.shared.chosenSpaceCategory, comforts: CurrentNewOpenRequestValues.shared.comforts, urgent: false, photo: false, owner: CurrentNewOpenRequestValues.shared.owner, guests_count: CurrentNewOpenRequestValues.shared.guests_count) { (requestObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)

            if (error == nil) {
                self.progressView.setProgress(1, animated: true)

                RequestEditorManager.sharedInstance.currentEditingRequest = requestObject as? Request
                
                let infoView = ModalInfoView(titleText: "Отлично! Ваша заявка успешно создана и будет активна в течение 24 часов.", descriptionText: "Владельцы жилья получили уведомления и скоро Вам ответят. Теперь Ваша заявка находится в разделе “Мои заявки”, где Вы можете отслеживать ее статус.")
                
                infoView.addButtonWithTitle("Посмотреть заявку", action: {
                    
                })
                                
                infoView.show()
                
                MainTabBarController.shared.selectedIndex = 2
                
                let vc = (MainTabBarController.shared.viewControllers![2] as! UINavigationController).viewControllers.first as! RequestsListViewController
                vc.page = 1
                vc.loadNextPage()
                
                self.closeTapped()
            } else {
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

