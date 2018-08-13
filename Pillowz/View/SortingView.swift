//
//  SortingView.swift
//  Pillowz
//
//  Created by Samat on 09.02.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SortingView: UIView {
    var collectionView: UICollectionView! = nil
    
    var headerLabel = UILabel()
    var headerBackgroundView = UIView()

    var sortTypes:[SPACE_SORT_TYPES] = SPACE_SORT_TYPES.allValues
    
    var chosenSortType:SPACE_SORT_TYPES!
    
    var delegate:SortingDelegate?
    
    let cellHeight = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView.register(SortingViewCollectionViewCell.self, forCellWithReuseIdentifier: "SortingViewCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(5*cellHeight)
        }
        
        
        
        self.addSubview(headerBackgroundView)
        headerBackgroundView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.height.equalTo(30)
            make.bottom.equalTo(collectionView.snp.top).offset(0)
        }
        headerBackgroundView.backgroundColor = .white
        
        headerBackgroundView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6 )
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-8*2)
            make.height.equalTo(30)
        }
        headerLabel.textColor = Constants.paletteBlackColor
        headerLabel.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        headerLabel.text = "Сортировка"
        headerLabel.backgroundColor = .white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


extension SortingView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SortingViewCollectionViewCell", for: indexPath) as! SortingViewCollectionViewCell
        
        let sortType = sortTypes[indexPath.item]
        
        cell.sortTypeLabel.text = SortingViewController.getDisplayNameForSortType(sort_type: sortType)["ru"]!
        cell.sortTypeLabel.layer.borderColor = UIColor.lightGray.cgColor
        cell.sortTypeLabel.textColor = Constants.paletteBlackColor
        cell.sortTypeLabel.font = UIFont.init(name: "OpenSans-Regular", size: 11)!

        if (sortType == chosenSortType) {
            cell.sortTypeLabel.layer.borderColor = Constants.paletteVioletColor.cgColor
            cell.sortTypeLabel.textColor = Constants.paletteVioletColor
            cell.sortTypeLabel.font = UIFont.init(name: "OpenSans-Bold", size: 11)!
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.screenFrame.size.width/2, height: CGFloat(cellHeight))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sortType = sortTypes[indexPath.item]

        self.chosenSortType = sortType
        self.delegate?.didFinishSorting(sortingType: sortType)
        self.collectionView.reloadData()
        
        self.removeFromSuperview()
    }
}

