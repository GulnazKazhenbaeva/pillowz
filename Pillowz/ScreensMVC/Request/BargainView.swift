//
//  BargainView.swift
//  Pillowz
//
//  Created by Samat on 23.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

protocol BargainViewDelegate {
    func rejectTapped()
    func agreeTapped()
    func offerNewPriceTapped(newPrice:Int)
}

class BargainView: UIView {
    var offer:Offer?
    var request:Request?
    
    var delegate:BargainViewDelegate?
    
    let leftButton = UIButton()
    let rightButton = UIButton()
    let titleLabel = UILabel()
    var collectionView: UICollectionView!
    
    var iterations:[[String:Any]] = []
    
    var isScrollEnabled = false {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        leftButton.setImage(#imageLiteral(resourceName: "leftViolet"), for: .normal)
        leftButton.imageView?.contentMode = .scaleToFill
        self.addSubview(leftButton)
        leftButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }
        leftButton.addTarget(self, action: #selector(leftTapped), for: .touchUpInside)
        
        titleLabel.textColor = Constants.paletteVioletColor
        titleLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 13)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(leftButton)
            make.left.equalTo(leftButton.snp.right).offset(10)
            make.width.equalTo(170)
            make.height.equalTo(25)
        }
        
        rightButton.setImage(#imageLiteral(resourceName: "rightViolet"), for: .normal)
        rightButton.imageView?.contentMode = .scaleToFill
        self.addSubview(rightButton)
        rightButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(4)
            make.left.equalTo(titleLabel.snp.right).offset(0)
            make.width.height.equalTo(40)
        }
        rightButton.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 110)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 1 // set to 0 if it should be to no spacing between items
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 110), collectionViewLayout: layout)
        collectionView.register(BargainCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(leftButton.snp.bottom).offset(0)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func leftTapped() {
        if collectionView.contentOffset.x == 0 {
            return
        }
        
        let offset = CGPoint(x: collectionView.contentOffset.x - Constants.screenFrame.size.width, y: 0)
        collectionView.setContentOffset(offset, animated: true)
    }
    
    @objc func rightTapped() {
        if collectionView.contentOffset.x == collectionView.contentSize.width - Constants.screenFrame.size.width {
            return
        }
        
        let offset = CGPoint(x: collectionView.contentOffset.x + Constants.screenFrame.size.width, y: 0)
        collectionView.setContentOffset(offset, animated: true)
    }
    
    func fillWithOffer(_ fillingOffer:Offer?, fillingRequest:Request?) {
        self.offer = fillingOffer
        self.request = fillingRequest
        
        if (offer == nil) {
            if (request!.price_histories != nil) {
                iterations = request!.price_histories!
            }
        } else {
            if (offer!.price_histories != nil) {
                iterations = offer!.price_histories!
            }
        }
        
        if let lastIteration = iterations.last {
            var myPrice:Int?
            var otherUserPrice:Int?
            
            if (User.currentRole == .realtor) {
                myPrice = lastIteration["price_realtor"] as? Int
                otherUserPrice = lastIteration["price_client"] as? Int
            } else {
                myPrice = lastIteration["price_client"] as? Int
                otherUserPrice = lastIteration["price_realtor"] as? Int
            }
            
//            var status:RequestStatus
            var isWaitingForAnswer:Bool
            var isCompleted:Bool
            
            if (offer != nil) {
//                status = offer!.status!
                isWaitingForAnswer = offer!.isWaitingForAnswer()
                isCompleted = offer!.isCompleted()
            } else {
//                status = request!.status!
                isWaitingForAnswer = request!.isWaitingForAnswer()
                isCompleted = request!.isCompleted()
            }
            
            if myPrice != nil && otherUserPrice != nil && !isWaitingForAnswer && !isCompleted {
                iterations.append([:]) //adding to give ability to offer
            }
        }
        
        collectionView.reloadData()
        
        titleLabel.text = "История торгов " + iterations.count.description + " из " + 5.description
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // change 2 to desired number of seconds
            let rightOffset = CGPoint(x: self.collectionView.contentSize.width - self.collectionView.bounds.size.width, y: 0)
            self.collectionView.setContentOffset(rightOffset, animated: true)
        }
    }
    
    @objc func agreeTapped() {
        self.delegate?.agreeTapped()
    }
    
    @objc func offerNewPriceTapped(sender: UIButton) {
        var status:RequestStatus
        
        if (offer != nil) {
            status = offer!.status!
        } else {
            status = request!.status!
        }
        
        let isWaitingForAnswer = (User.currentRole == .client && (status == .CLIENT_OFFER || status == .CLIENT_OFFER_VIEWED || (offer == nil && (status == .VIEWED || status == .NOT_VIEWED)))) || (User.currentRole == .realtor && (status == .REALTOR_OFFER || status == .REALTOR_OFFER_VIEWED || (offer != nil && (status == .VIEWED || status == .NOT_VIEWED))))

        if !isWaitingForAnswer {
            let cell = collectionView.cellForItem(at: IndexPath(item: sender.tag, section: 0)) as! BargainCollectionViewCell
            self.delegate?.offerNewPriceTapped(newPrice: cell.newPricePickerView.value)
        }
    }
}


extension BargainView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iterations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var myPrice:Int?
        var otherUserPrice:Int?
        
        let isLastIteration = indexPath.item == iterations.count-1
        
        let isIterationBeforeLast = indexPath.item == iterations.count-2
        
        //iterations.last?.keys.count==0 means that we added one iteration by ourselves to let user create "future" bargain
        let lastIterationAddedProgrammatically = iterations.last?.keys.count==0
        let isIterationBeforeLastIsActualLastIteration = isIterationBeforeLast && lastIterationAddedProgrammatically
        
        var status:RequestStatus
        if (offer != nil) {
            status = offer!.status!
        } else {
            status = request!.status!
        }
        
        let isWaitingForAnswer = (User.currentRole == .client && (status == .CLIENT_OFFER || status == .CLIENT_OFFER_VIEWED || (offer == nil && (status == .VIEWED || status == .NOT_VIEWED)))) || (User.currentRole == .realtor && (status == .REALTOR_OFFER || status == .REALTOR_OFFER_VIEWED || (offer != nil && (status == .VIEWED || status == .NOT_VIEWED))))
        
        var otherUserNextPrice:Int?
        
        if (User.currentRole == .realtor) {
            myPrice = iterations[indexPath.item]["price_realtor"] as? Int
            otherUserPrice = iterations[indexPath.item]["price_client"] as? Int
            
            let isIndexValid = iterations.indices.contains(indexPath.item + 1)
            
            if isIndexValid {
                otherUserNextPrice = iterations[indexPath.item + 1]["price_client"] as? Int
            }
        } else {
            myPrice = iterations[indexPath.item]["price_client"] as? Int
            otherUserPrice = iterations[indexPath.item]["price_realtor"] as? Int
            
            let isIndexValid = iterations.indices.contains(indexPath.item + 1)
            
            if isIndexValid {
                otherUserNextPrice = iterations[indexPath.item + 1]["price_realtor"] as? Int
            }
        }
        
        let hasOtherUserNextPrice = otherUserNextPrice != nil
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BargainCollectionViewCell
        
        if (myPrice != nil) {
            cell.myUserPriceValueLabel.text = String(myPrice!)+"₸"
        } else {
            cell.myUserPriceValueLabel.text = ""
        }
        
        if (otherUserPrice != nil) {
            cell.otherUserPriceValueLabel.text = String(otherUserPrice!)+"₸"
        } else {
            cell.otherUserPriceValueLabel.text = ""
        }
        
        var lastPrice:Int?
        var otherUserName:String?
        
        if (offer != nil) {
            lastPrice = offer!.getLastPrice(role: User.currentRole)
            otherUserName = offer!.otherUser.name
            
            if let avatar = offer?.otherUser.avatar {
                cell.otherUserImageView.sd_setImage(with: URL(string: avatar), placeholderImage: UIImage())
            }
        } else {
            lastPrice = request!.getLastPrice(role: User.currentRole)
            otherUserName = request!.otherUser.name
            
            if let avatar = request?.otherUser.avatar {
                cell.otherUserImageView.sd_setImage(with: URL(string: avatar), placeholderImage: UIImage())
            }
        }
        
        cell.myImageView.sd_setImage(with: URL(string: User.shared.avatar!), placeholderImage: UIImage())
        
        let firstWord = otherUserName?.components(separatedBy: " ").first
        
        cell.otherUserNameLabel.text = firstWord
        cell.youLabel.text = "Вы"
        
        let isCompleted = status == .COMPLETED || status == .COMPLETED_WITH_OTHER || status == .CLIENT_REJECTED || status == .REALTOR_REJECTED || status == .MAX_ITERATIONS_EXCEEDED || status == .REQUEST_TIMED_OUT
        
        let shouldLetEnterNewPrice = isLastIteration && !isWaitingForAnswer && !isCompleted
        
        cell.newPricePickerView.isHidden = !shouldLetEnterNewPrice
        cell.myUserPriceValueLabel.isHidden = shouldLetEnterNewPrice
        cell.offerNewPriceButton.isHidden = !shouldLetEnterNewPrice
        
        
        
        if User.currentRole == .realtor {
            cell.newPricePickerView.maxValue = lastPrice
        } else {
            cell.newPricePickerView.minValue = lastPrice
        }
        
        if let lastPrice = lastPrice {
            cell.newPricePickerView.value = lastPrice
        }
        
        let shouldLetAgree = !hasOtherUserNextPrice && !isCompleted && otherUserPrice != nil
        
        cell.agreeButton.isHidden = !shouldLetAgree
        
        cell.offerNewPriceButton.tag = indexPath.item
        cell.offerNewPriceButton.addTarget(self, action: #selector(offerNewPriceTapped), for: .touchUpInside)
        cell.offerNewPriceButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        
        if (!shouldLetEnterNewPrice) {
            cell.offerNewPriceButton.isHidden = true
        }
        
        cell.agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = collectionView.contentOffset.x / collectionView.frame.size.width
        
        titleLabel.text = "Торг " + Int(page + 1).description + " из " + 5.description
    }
}

