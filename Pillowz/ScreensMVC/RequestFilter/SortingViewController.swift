//
//  SortingViewController.swift
//  Pillowz
//
//  Created by Samat on 18.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol SortingDelegate {
    func didFinishSorting(sortingType:SPACE_SORT_TYPES)
}

protocol RequestSortingDelegate {
    func didFinishSorting(sortingType:REQUEST_SORT_TYPES)
}

enum SPACE_SORT_TYPES: Int {
    case SORT_DATE_ASC = 0
    case SORT_DATE_DESC = 1
    case SORT_PRICE_ASC = 2
    case SORT_PRICE_DESC = 3
    case SORT_REVIEW_ASC = 4
    case SORT_REVIEW_DESC = 5
    case SORT_AREA_ASC = 6
    case SORT_AREA_DESC = 7
    case SORT_DISTANCE_ASC = 8
    case SORT_DISTANCE_DESC = 9
    static let allValues = [SORT_DATE_ASC, SORT_DATE_DESC, SORT_PRICE_ASC, SORT_PRICE_DESC, SORT_REVIEW_ASC, SORT_REVIEW_DESC, SORT_AREA_ASC, SORT_AREA_DESC, SORT_DISTANCE_ASC, SORT_DISTANCE_DESC]
}



class SortingViewController: PillowzViewController, SaveActionDelegate {
    let crudVM = CreateEditObjectTableViewGenerator()
    
    var chosenSortType:SPACE_SORT_TYPES = .SORT_DATE_ASC
    var chosenRequestSortType:REQUEST_SORT_TYPES = .FRESH

    var delegate:SortingDelegate?
    var requestSortingDelegate:RequestSortingDelegate?

    var fields:[Field] = []
    var headers:[String] = []

    var isRequestSorting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Сортировка"
        
        self.view.backgroundColor = .white
        
        let leftButton: UIButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "close"), for: .normal)
        leftButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        leftButton.frame = CGRect(x:0, y:0, width:44, height:44)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton

        if (!isRequestSorting) {
            for sortType in SPACE_SORT_TYPES.allValues {
                let field = Field()
                field.type = "BooleanField"
                field.param_name = String(sortType.rawValue)
                field.multiLanguageName = SortingViewController.getDisplayNameForSortType(sort_type: sortType)
                if sortType==chosenSortType {
                    field.value = true.description
                }
                
                field.didPickFieldValueClosure = { (newValue) in
                    self.chosenSortType = sortType
                    
                    for iteratingField in self.fields {
                        if iteratingField.param_name != field.param_name {
                            iteratingField.value = false.description
                        }
                    }
                }
                fields.append(field)
                headers.append("")
            }
        } else {
            for sortType in REQUEST_SORT_TYPES.allValues {
                let field = Field()
                field.type = "BooleanField"
                field.param_name = String(sortType.rawValue)
                field.multiLanguageName = SortingViewController.getDisplayNameForRequestSortType(sort_type: sortType)
                if sortType==chosenRequestSortType {
                    field.value = true.description
                }
                
                field.didPickFieldValueClosure = { (newValue) in
                    self.chosenRequestSortType = sortType
                    
                    for iteratingField in self.fields {
                        if iteratingField.param_name != field.param_name {
                            iteratingField.value = false.description
                        }
                    }
                }
                fields.append(field)
                headers.append("")
            }
        }
        
        crudVM.viewController = self
        crudVM.headers = headers
        crudVM.object = fields as AnyObject
        crudVM.hasSaveAction = true
        
        crudVM.tableView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(74)
        }
    }
    
    @objc func closeTapped() {
        if (isRequestSorting) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func actionButtonTapped() {
        delegate?.didFinishSorting(sortingType: self.chosenSortType)
        requestSortingDelegate?.didFinishSorting(sortingType: self.chosenRequestSortType)
        
        closeTapped()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    class func getDisplayNameForSortType(sort_type:SPACE_SORT_TYPES) -> [String:String] {
        var sort_type_display:[String:String]!
        
        switch (sort_type) {
        case (.SORT_DATE_ASC):
            sort_type_display = ["ru":"Старые", "en":"Старые"]
        case (.SORT_DATE_DESC):
            sort_type_display = ["ru":"Новые", "en":"Новые"]
        case (.SORT_PRICE_ASC):
            sort_type_display = ["ru":"Дешевые", "en":"Дешевые"]
        case (.SORT_PRICE_DESC):
            sort_type_display = ["ru":"Дорогие", "en":"Дорогие"]
        case (.SORT_REVIEW_ASC):
            sort_type_display = ["ru":"Низкий рейтинг", "en":"Низкий рейтинг"]
        case (.SORT_REVIEW_DESC):
            sort_type_display = ["ru":"Высокий рейтинг", "en":"Высокий рейтинг"]
        case (.SORT_AREA_ASC):
            sort_type_display = ["ru":"Минимальная площадь", "en":"Минимальная площадь"]
        case (.SORT_AREA_DESC):
            sort_type_display = ["ru":"Максимальная площадь", "en":"Максимальная площадь"]
        case (.SORT_DISTANCE_ASC):
            sort_type_display = ["ru":"Близко", "en":"Близко"]
        case (.SORT_DISTANCE_DESC):
            sort_type_display = ["ru":"Далеко", "en":"Далеко"]
        }

        return sort_type_display
    }
    
    class func getDisplayNameForRequestSortType(sort_type:REQUEST_SORT_TYPES) -> [String:String] {
        var sort_type_display:[String:String]!
        
        switch (sort_type) {
        case (.FRESH):
            sort_type_display = ["ru":"Сначала новые", "en":"Сначала новые"]
        case (.PRICE):
            sort_type_display = ["ru":"Сначала недорогие", "en":"Сначала недорогие"]
        case (.SUITABLE):
            sort_type_display = ["ru":"Сначала подходящие", "en":"Сначала подходящие"]
        case (.FINISHING):
            sort_type_display = ["ru":"Сначала заканчивающиеся", "en":"Сначала заканчивающиеся"]
        case (.PRICE_DESC):
            sort_type_display = ["ru":"Сначала дорогие", "en":"Сначала дорогие"]
        }
        
        return sort_type_display
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
