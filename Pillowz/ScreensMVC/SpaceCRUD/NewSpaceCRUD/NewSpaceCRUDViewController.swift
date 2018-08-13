//
//  NewSpaceCRUDViewController.swift
//  Pillowz
//
//  Created by Samat on 04.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class NewSpaceCRUDViewController: StepsViewController, SlidingContainerSliderViewDelegate {
    var isCreating = false
    var isPublished = false

    var space:Space = SpaceEditorManager.sharedInstance.currentEditingSpace!
    
    var sliderView: SlidingContainerSliderView!
    
    var shouldCloseAfterSave = false
    
    var shouldSendToModerationWhileEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberOfPages = 7
        
        isCreating = space.status == .DRAFT
        isPublished = space.status == .VISUAL
        
        if (!isCreating) {
            sliderView = SlidingContainerSliderView(width: Constants.screenFrame.size.width, titles: ["Характеристики", "Удобства", "Правила", "Расположение", "Цена", "Фотографии", "Описание"])
            sliderView.sliderDelegate = self
            sliderView.appearance.font = UIFont(name: "OpenSans-Regular", size: 13)!
            sliderView.appearance.selectedFont = UIFont(name: "OpenSans-Regular", size: 13)!
            sliderView.appearance.textColor = Constants.paletteBlackColor
            sliderView.appearance.selectedTextColor = Constants.paletteBlackColor
            sliderView.appearance.selectorHeight = 1
            sliderView.appearance.selectorColor = Constants.paletteVioletColor
            sliderView.appearance.backgroundColor = .white
            self.view.addSubview(sliderView)
            sliderView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(38)
            }
            sliderView.selectItemAtIndex(0)

            self.pageViewController.view.snp.remakeConstraints({ (make) in
                make.top.equalTo(sliderView.snp.bottom)
                make.bottom.left.right.equalToSuperview()
            })
            
            let separatorView = UIView()
            self.view.addSubview(separatorView)
            separatorView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(sliderView.snp.bottom)
                make.height.equalTo(1)
            }
            separatorView.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        } else {
            sliderView?.selectItemAtIndex(SpaceEditorManager.sharedInstance.getCurrentPageInContinuing)
            currentPage = SpaceEditorManager.sharedInstance.getCurrentPageInContinuing
            
            if let vc = getItemController(itemIndex: SpaceEditorManager.sharedInstance.getCurrentPageInContinuing) {
                self.pageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
    override func closeTapped() {
        let infoView = ModalInfoView(titleText: "Вы хотите сохранить изменения перед выходом?", descriptionText: "")
        
        infoView.addButtonWithTitle("Сохранить", action: {
            self.shouldCloseAfterSave = true
            
            self.lastStepTapped()
        })
        
        infoView.addButtonWithTitle("Не сохранять", action: {
            self.close()
        })
        
        infoView.show()
    }
    
    func close() {
        SpaceEditorManager.sharedInstance.spaceCRUDVC = nil
        SpaceEditorManager.sharedInstance.currentStepVC = nil
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func setTitleAndProgressForCurrentPage() {
        if (!isCreating) {
            sliderView.selectItemAtIndex(currentPage)
        }
        
        var currentPageProgress:Float = 2/8

        if (currentPage == 0) {
            currentPageProgress = 2/8

            self.title = "Тип жилья, характеристики?"
        } else if (currentPage == 1) {
            currentPageProgress = 3/8
            
            self.title = "Какие удобства Вам необходимы?"
        } else if (currentPage == 2) {
            currentPageProgress = 4/8

            self.title = "Правила?"
        } else if (currentPage == 3) {
            currentPageProgress = 5/8

            self.title = "Расположение?"
        } else if (currentPage == 4) {
            currentPageProgress = 6/8

            self.title = "Цена?"
        } else if (currentPage == 5) {
            currentPageProgress = 7/8
            
            self.title = "Фотографии?"
        } else if (currentPage == 6) {
            currentPageProgress = 1.0

            self.title = "Описание?"
        }
        
        if progressView.progress < currentPageProgress {
            saveFullInfo()
            
            progressView.setProgress(currentPageProgress, animated: true)
        }
    }
    
    override func getItemController(itemIndex: Int) -> UIViewController? {
        if itemIndex < numberOfPages && itemIndex>=0 {
            var vc:StepViewController!
            
            if (itemIndex == 0) {
                vc = SpaceCRUDCategoryFieldsViewController()
            } else if (itemIndex == 1) {
                vc = SpaceCRUDComfortsViewController()
            } else if (itemIndex == 2) {
                vc = SpaceCRUDRulesViewController()
            } else if (itemIndex == 3) {
                vc = MapAddressPickerViewController()
                (vc as! MapAddressPickerViewController).isEditingSpace = true
            } else if (itemIndex == 4) {
                vc = SpaceCRUDPricesViewController()
            } else if (itemIndex == 5) {
                vc = SpaceCRUDPhotosViewController()
            } else if (itemIndex == 6) {
                vc = SpaceCRUDDescriptionViewController()
            }
                        
            vc.itemIndex = itemIndex
            currentVC = vc
            
            return vc
        }
        
        return nil
    }
    
    override func lastStepTapped() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        shouldCloseAfterSave = true
        
        saveFullInfo()
    }
    
    @objc func updateSpace() {
        if !isCreating && !shouldSendToModerationWhileEditing {
            return
        }
        
        saveFullInfo()
    }
    
    func saveFullInfo() {
        SpaceAPIManager.createSpace(space_id: SpaceEditorManager.sharedInstance.currentEditingSpace.space_id.intValue, name: SpaceEditorManager.sharedInstance.name, cancellation_policy: SpaceEditorManager.sharedInstance.cancellation_policy, additional_charges: SpaceEditorManager.sharedInstance.additional_charges, arrival_time:SpaceEditorManager.sharedInstance.arrival_time, checkout_time:SpaceEditorManager.sharedInstance.checkout_time, description: SpaceEditorManager.sharedInstance.spaceDescription, destination: SpaceEditorManager.sharedInstance.destination, infrastructure: SpaceEditorManager.sharedInstance.infrastructure, lat: SpaceEditorManager.sharedInstance.lat, lon: SpaceEditorManager.sharedInstance.lon, address: SpaceEditorManager.sharedInstance.address, prices: SpaceEditorManager.sharedInstance.currentEditingSpace.prices!, rules: SpaceEditorManager.sharedInstance.rules, fields: SpaceEditorManager.sharedInstance.spaceFields, comforts: SpaceEditorManager.sharedInstance.comforts, should_validate: currentPage == 6, additional_features: SpaceEditorManager.sharedInstance.additional_features, arrival_and_checkout: SpaceEditorManager.sharedInstance.arrival_and_checkout, deposit: SpaceEditorManager.sharedInstance.deposit)  { (spaceObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                if self.shouldCloseAfterSave {
                    let space = spaceObject as! Space
                    if space.status == SpaceStatus.MODERATION {
                        DesignHelpers.makeToastWithText("Вы успешно добавили объект!\nОн появится в поиске после прохождения модерации.")
                    } else if space.status == .DRAFT {
                        DesignHelpers.makeToastWithText("Объект сохранен в черновики.\nВы можете продолжить его добавление в любой момент.")
                    }

                    //Вы успешно добавили объект!\nКак только модератор проверит все данные, ваше жилье появится в поиске, и клиенты смогут его найти. Объект будет активен на сервисе 7 дней, затем уйдет в архив. Проверить статус объекта можно в разделе “Мои объекты”.

                    self.shouldCloseAfterSave = false
                    self.close()
                }
            }
        }
    }

    func slidingContainerSliderViewDidPressed(_ slidingtContainerSliderView: SlidingContainerSliderView, atIndex: Int) {
        sliderView.selectItemAtIndex(atIndex)
        
        if atIndex == currentPage {
            return
        }
        
        var direction = UIPageViewControllerNavigationDirection.forward
        
        if (atIndex<currentPage) {
            direction = UIPageViewControllerNavigationDirection.reverse
        }
        
        if let vc = getItemController(itemIndex: atIndex) {
            self.pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: nil)
            
            currentPage = atIndex
        }
    }
    

}
