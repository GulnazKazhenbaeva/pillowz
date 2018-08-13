//
//  HorizontalSpacesList.swift
//  Pillowz
//
//  Created by Samat on 28.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

public typealias SpaceLoaderClosure = () -> Void

class HorizontalSpacesList: UIView {
    var collectionView: UICollectionView! = nil
    
    var displayingSpaces:[Space] = [] {
        didSet {
            loadFailed = false
            
            self.collectionView.reloadData()
        }
    }
    
    var reloadButton = UIButton()
    var loadingActivityView = UIActivityIndicatorView()
    var loadFailed = false {
        didSet {
            reloadButton.isHidden = !loadFailed
        }
    }
    var isLoading = true {
        didSet {
            if (isLoading) {
                loadingActivityView.startAnimating()
            } else {
                loadingActivityView.stopAnimating()
            }
        }
    }
    
    var superViewController:UIViewController!

    var spaceLoaderClosure:SpaceLoaderClosure! 
    
    var cell:RealtorSpacesTableViewCell?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.backgroundColor = UIColor(white: 1, alpha: 0.2)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView.register(SpaceCollectionViewCell.self, forCellWithReuseIdentifier: "SpaceCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(-0)
            make.height.equalTo(Constants.oneSpaceWidthInHorizontalCollectionView*180/340 + 130 + 28)
        }
        
        self.addSubview(loadingActivityView)
        loadingActivityView.activityIndicatorViewStyle = .gray
        loadingActivityView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
        }
        loadingActivityView.hidesWhenStopped = true
        loadingActivityView.startAnimating()
        
        self.addSubview(reloadButton)
        reloadButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        reloadButton.isHidden = true
        reloadButton.setImage(#imageLiteral(resourceName: "logo"), for: .normal)
        reloadButton.addTarget(self, action: #selector(loadTapped), for: .touchUpInside)
        
        self.clipsToBounds = false
    }
    
    @objc func loadTapped() {
        spaceLoaderClosure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension HorizontalSpacesList: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayingSpaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpaceCollectionViewCell", for: indexPath) as! SpaceCollectionViewCell
        
        cell.space = displayingSpaces[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.oneSpaceWidthInHorizontalCollectionView, height: Constants.oneSpaceWidthInHorizontalCollectionView*180/340 + 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = SpaceViewController()
        vc.space = displayingSpaces[indexPath.item]
        self.superViewController.navigationController?.pushViewController(vc, animated: true)
    }
}
