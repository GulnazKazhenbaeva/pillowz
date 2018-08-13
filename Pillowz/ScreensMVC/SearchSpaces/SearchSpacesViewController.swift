//
//  SearchSpacesViewController.swift
//  Pillowz
//
//  Created by Samat on 06.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class SearchSpacesViewController: PillowzViewController, FilterDelegate, SortingDelegate, DateAndTimePickerViewControllerDelegate {
    var spaces:[Space] = []
    var mapVC:MapViewController!
    var spacesListVC:SpacesListViewController!
    
    var mapView:UIView!
    var spacesListView:UIView!
    
    var filter:Filter = Filter.shared
    
    let listMapButton = UIButton(type: .custom)
    let listMapButtonBackgroundView = UIView()
    
    var isShowingMap = false
    
    var openFilterAfterLoadingCategories:Bool? //if false - opens sortVC
    
    var clearDatesButtons:[UIButton] = []
    var datesButtons:[UIButton] = []
    var filterButtons:[UIButton] = []
    var clearFilterButtons:[UIButton] = []
    var rentTypeButtons:[UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!UserLastUsedValuesForFieldAutofillingHandler.shared.didChooseRentTypeForFirstTime) {
            self.rentTypeTapped()
        } else {
            getFilter()
        }
        
        self.setTextForRentTypeButtons()
        
        setNavigationBarItems()
        self.view.addSubview(listMapButtonBackgroundView)
        listMapButtonBackgroundView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.height.equalTo(56)
        }
        listMapButtonBackgroundView.addSubview(listMapButton)
        listMapButtonBackgroundView.backgroundColor = UIColor(hexString: "#FF6B57")
        listMapButtonBackgroundView.layer.cornerRadius = 28
        listMapButtonBackgroundView.dropShadow()
        
        listMapButtonBackgroundView.layer.masksToBounds = false

        listMapButton.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        listMapButton.setImage(UIImage(named: "map"), for: .normal)
        listMapButton.addTarget(self, action: #selector(listMapTapped), for: .touchUpInside)
        
        self.navigationItem.title = "Поиск объектов"
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadedCategories), name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
    }
    
    func setTextForRentTypeButtons() {
        for rentTypeButton in self.rentTypeButtons {
            let title = Price.getDisplayNameForRentType(rent_type: UserLastUsedValuesForFieldAutofillingHandler.shared.rentType, isForPrice: false)["ru"]!
            
            rentTypeButton.setTitle(title, for: .normal)
            rentTypeButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
            
            let width = title.width(withConstraintedHeight: 20, font: rentTypeButton.titleLabel!.font)
            
            rentTypeButton.snp.updateConstraints({ (make) in
                make.width.equalTo(width + 10)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureFilterButtons()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.loadedCategoriesNotification), object: nil)
    }
    
    func setNavigationBarItems() {
        let sortRightButton: UIButton = UIButton(type: .custom)
        sortRightButton.setImage(UIImage(named: "sort"), for: .normal)
        sortRightButton.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)
        sortRightButton.frame = CGRect(x:0, y:0, width:35, height:44)
        let sortRightBarButton = UIBarButtonItem(customView: sortRightButton)
        
        let filterRightButton: UIButton = UIButton(type: .custom)
        filterRightButton.setImage(UIImage(named: "filter"), for: .normal)
        filterRightButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        filterRightButton.frame = CGRect(x:0, y:0, width:35, height:44)
        let filterRightBarButton = UIBarButtonItem(customView: filterRightButton)
        
        if (isShowingMap) {
            self.navigationItem.rightBarButtonItems = [filterRightBarButton]
        } else {
            self.navigationItem.rightBarButtonItems = [filterRightBarButton, sortRightBarButton]
        }
    }
    
    override func loadView() {
        super.loadView()
        
        mapVC = MapViewController()
        spacesListVC = SpacesListViewController()
        spacesListVC.superViewController = self
        mapVC.superViewController = self
        
        mapView = mapVC.view
        spacesListView = spacesListVC.view
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(spacesListView)
        spacesListView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        mapView.isHidden = true
    }
    
    func getFilter() {
        if (CategoriesHandler.sharedInstance.categories.count>0) {
            self.searchSpaces()
        }
    }
    
    func searchSpaces() {
        spacesListVC.page = 1
        spacesListVC.shouldShowLoadingIndicator = true
        spacesListVC.loadNextPage()
        mapVC.searchSpaces()
    }
    
    @objc func listMapTapped() {
        isShowingMap = !isShowingMap

        mapView.isHidden = !isShowingMap
        spacesListView.isHidden = isShowingMap
        
        if (isShowingMap) {
            listMapButton.setImage(UIImage(named: "list"), for: .normal)
        } else {
            listMapButton.setImage(UIImage(named: "map"), for: .normal)
        }
        
        setNavigationBarItems()
    }
    
    @objc func loadedCategories() {
        let window = UIApplication.shared.delegate!.window!!

        MBProgressHUD.hide(for: window, animated: true)

        if (openFilterAfterLoadingCategories != nil) {
            if (openFilterAfterLoadingCategories!) {
                openFilter()
            } else {
                openSort()
            }
            
            openFilterAfterLoadingCategories = nil
        }
    }
    
    @objc func datesTapped() {
        let vc = DateAndTimePickerViewController()
        vc.rentType = UserLastUsedValuesForFieldAutofillingHandler.shared.rentType
        vc.doneButton.setTitle("Показать результаты", for: .normal)
        
        if let startTime = Filter.shared.startTime {
            vc.startDate = Date(timeIntervalSince1970: TimeInterval(startTime))
        }
        
        if let endTime = Filter.shared.endTime {
            vc.endDate = Date(timeIntervalSince1970: TimeInterval(endTime))
        }
        
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func didPickStartDate(_ startDate: Date, endDate: Date?) {
        for clearButton in clearDatesButtons {
            clearButton.isHidden = false
        }
        
        Filter.shared.startTime = Int(startDate.timeIntervalSince1970)
        
        if (UserLastUsedValuesForFieldAutofillingHandler.shared.rentType == .HALFDAY) {
            Filter.shared.endTime = Int(startDate.add(.init(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0)).timeIntervalSince1970)
        } else if (UserLastUsedValuesForFieldAutofillingHandler.shared.rentType == .MONTHLY) {
            Filter.shared.endTime = Int(startDate.add(.init(seconds: 0, minutes: 0, hours:0, days: 0, weeks: 0, months: 1, years: 0)).timeIntervalSince1970)
        }
        
        if let endDate = endDate {
            Filter.shared.endTime = Int(endDate.timeIntervalSince1970)
        }
        
        for datesButton in datesButtons {
            let title = Request.getStringForRentType(UserLastUsedValuesForFieldAutofillingHandler.shared.rentType, startTime: Filter.shared.startTime, endTime: Filter.shared.endTime, shouldGoToNextLine: false, includeRentTypeText: false)
            
            datesButton.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 10)
            datesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 33)
            datesButton.setTitle(title, for: .normal)
            datesButton.backgroundColor = Constants.paletteVioletColor
            datesButton.setTitleColor(.white, for: .normal)
            
            let width = title.width(withConstraintedHeight: 20, font: datesButton.titleLabel!.font)
            
            datesButton.snp.updateConstraints({ (make) in
                make.width.equalTo(width + 40)
            })
        }
        
        searchSpaces()
    }
    
    @objc func rentTypeTapped() {
        let view = RentTypePickerView()
        view.didPickRentTypeClosure = { (rentType) in
            UserLastUsedValuesForFieldAutofillingHandler.shared.didChooseRentTypeForFirstTime = true
            self.searchSpaces()
            self.setTextForRentTypeButtons()
            self.didClearDates()
        }
        view.show()
    }
    
    @objc func didClearDates() {
        Filter.shared.startTime = nil
        Filter.shared.endTime = nil

        for clearButton in clearDatesButtons {
            clearButton.isHidden = true
        }
        
        for datesButton in datesButtons {
            let title = "Даты"
            
            datesButton.snp.updateConstraints({ (make) in
                make.width.equalTo(50)
            })
            
            datesButton.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 10)
            datesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            datesButton.setTitle(title, for: .normal)
            datesButton.backgroundColor = .white
            datesButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
        }
    }
    
    @objc func didClearFilter() {
        filter.clearFilter()
        filter.getFields()
        
        filter.crudVM?.tableView.reloadData()
        
        configureFilterButtons()
    }
    
    func configureFilterButtons() {
        if filter.filterIsEmpty() {
            for clearButton in clearFilterButtons {
                clearButton.isHidden = true
            }
            
            for filterButton in filterButtons {
                filterButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                filterButton.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 10)
                filterButton.backgroundColor = UIColor.white
                filterButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
                
                filterButton.snp.updateConstraints({ (make) in
                    make.width.equalTo(66)
                })
                
                filterButton.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
            }
        } else {
            for clearButton in clearFilterButtons {
                clearButton.isHidden = false
            }
            
            for filterButton in filterButtons {
                filterButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 33)
                filterButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
                filterButton.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 10)
                
                filterButton.snp.updateConstraints({ (make) in
                    make.width.equalTo(66 + 36)
                })
            }
        }
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
    
    @objc func sortTapped() {
        if (CategoriesHandler.sharedInstance.categories.count == 0) {
            let window = UIApplication.shared.delegate!.window!!
            
            MBProgressHUD.showAdded(to: window, animated: true)

            openFilterAfterLoadingCategories = false
            CategoriesHandler.sharedInstance.getCategories()
        } else {
            openSort()
        }
    }
    
    func openFilter() {
        let filterVC = NewFilterViewController.shared
        filterVC.filter = self.filter
        filterVC.delegate = self
        
        self.present(UINavigationController(rootViewController: filterVC), animated: true, completion: nil)
    }
    
    func openSort() {
        let sortingView = SortingView()
        sortingView.chosenSortType = filter.sort_by
        sortingView.delegate = self
        sortingView.show()
    }
    
    func didFinishFiltering() {
        searchSpaces()
    }
    
    func didFinishSorting(sortingType: SPACE_SORT_TYPES) {
        filter.sort_by = sortingType
        searchSpaces()
    }
}
