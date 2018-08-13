//
//  SearchFilterControlsView.swift
//  Pillowz
//
//  Created by Samat on 11.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SearchFilterControlsView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let datesButton = UIButton()
    let filterButton = UIButton()
    let sortButton = UIButton()
    let rentTypeButton = UIButton()
    let topScrollView = UIScrollView()
    let clearDatesButton = UIButton()
    let clearFilterButton = UIButton()

    init(superViewController:SearchSpacesViewController!, isForMap:Bool) {
        super.init(frame: CGRect.zero)
        
        if superViewController == nil {
            return
        }
        
        self.addSubview(topScrollView)
        topScrollView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        topScrollView.showsVerticalScrollIndicator = false
        topScrollView.showsHorizontalScrollIndicator = false
        topScrollView.contentSize = CGSize(width: 450, height: 30)
        topScrollView.contentInset = UIEdgeInsetsMake(0, Constants.basicOffset, 5, 0)
        topScrollView.contentOffset = CGPoint(x: -Constants.basicOffset, y: 0)
        topScrollView.alwaysBounceHorizontal = false
        topScrollView.clipsToBounds = false
        
        topScrollView.addSubview(datesButton)
        datesButton.backgroundColor = .white
        datesButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
        datesButton.addTarget(superViewController, action: #selector(SearchSpacesViewController.datesTapped), for: .touchUpInside)
        datesButton.setTitle("Даты", for: .normal)
        datesButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
        datesButton.layer.cornerRadius = 5
        datesButton.layer.borderWidth = 1
        datesButton.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
        datesButton.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 10)
        datesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        superViewController.datesButtons.append(datesButton)
        
        datesButton.addSubview(clearDatesButton)
        clearDatesButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        clearDatesButton.isHidden = true
        clearDatesButton.addTarget(superViewController, action: #selector(SearchSpacesViewController.didClearDates), for: .touchUpInside)
        clearDatesButton.setImage(#imageLiteral(resourceName: "closeWhite"), for: .normal)
        superViewController.clearDatesButtons.append(clearDatesButton)
        
        topScrollView.addSubview(rentTypeButton)
        rentTypeButton.backgroundColor = .white
        rentTypeButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(datesButton.snp.right).offset(6)
            make.height.equalTo(30)
            make.width.equalTo(84)
        }
        rentTypeButton.setTitle("Тип периода", for: .normal)
        rentTypeButton.addTarget(superViewController, action: #selector(SearchSpacesViewController.rentTypeTapped), for: .touchUpInside)
        rentTypeButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
        rentTypeButton.layer.cornerRadius = 5
        rentTypeButton.layer.borderWidth = 1
        rentTypeButton.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
        rentTypeButton.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 10)
        superViewController.rentTypeButtons.append(rentTypeButton)
        
        topScrollView.addSubview(filterButton)
        filterButton.backgroundColor = .white
        filterButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(rentTypeButton.snp.right).offset(6)
            make.height.equalTo(30)
            make.width.equalTo(66)
        }
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.addTarget(superViewController, action: #selector(SearchSpacesViewController.filterTapped), for: .touchUpInside)
        filterButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
        filterButton.layer.cornerRadius = 5
        filterButton.layer.borderWidth = 1
        filterButton.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
        filterButton.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 10)
        superViewController.filterButtons.append(filterButton)

        filterButton.addSubview(clearFilterButton)
        clearFilterButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        clearFilterButton.isHidden = true
        clearFilterButton.addTarget(superViewController, action: #selector(SearchSpacesViewController.didClearFilter), for: .touchUpInside)
        clearFilterButton.setImage(#imageLiteral(resourceName: "closeViolet"), for: .normal)
        superViewController.clearFilterButtons.append(clearFilterButton)
        
        if (!isForMap) {
            topScrollView.addSubview(sortButton)
            sortButton.backgroundColor = .white
            sortButton.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(filterButton.snp.right).offset(6)
                make.height.equalTo(30)
                make.width.equalTo(78)
            }
            sortButton.setTitle("Сортировка", for: .normal)
            sortButton.addTarget(superViewController, action: #selector(SearchSpacesViewController.sortTapped), for: .touchUpInside)
            sortButton.setTitleColor(Constants.paletteBlackColor, for: .normal)
            sortButton.layer.cornerRadius = 5
            sortButton.layer.borderWidth = 1
            sortButton.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
            sortButton.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
