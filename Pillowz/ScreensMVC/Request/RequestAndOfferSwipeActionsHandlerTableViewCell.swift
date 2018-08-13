//
//  RequestAndOfferSwipeActionsHandlerTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 25.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class RequestAndOfferSwipeActionsHandlerTableViewCell: UITableViewCell, UIScrollViewDelegate {
    
    let scrollView = UIScrollViewSuperTaps()
    let scrollViewContentView = UIView()
    
    let cancelOrArchiveButton = UIButton()
    let cancelOrArchiveIconImageView = UIImageView()
    let cancelOrArchiveLabel = UILabel()
    
    let agreeButton = UIButton()
    let agreeIconImageView = UIImageView()
    let agreeLabel = UILabel()
    
    let bargainView = BargainSwipeView()
    let completedView = CompletedSwipeView()
    
    let openBargainButton = UIButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
            make.height.equalTo(300)
        }
        
        scrollView.addSubview(scrollViewContentView)
        scrollViewContentView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
            make.width.equalTo(Constants.screenFrame.size.width)
            make.height.equalTo(100)
        }
        
        scrollViewContentView.addSubview(cancelOrArchiveButton)
        cancelOrArchiveButton.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(104)
        }
        
        cancelOrArchiveButton.addSubview(cancelOrArchiveIconImageView)
        cancelOrArchiveIconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
            make.width.height.equalTo(34)
        }
        cancelOrArchiveIconImageView.image = #imageLiteral(resourceName: "cancelSwipeIcon")
        
        cancelOrArchiveButton.addSubview(cancelOrArchiveLabel)
        cancelOrArchiveLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(25)
            make.width.equalToSuperview()
            make.height.equalTo(34)
        }
        cancelOrArchiveLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        cancelOrArchiveLabel.textColor = .white
        cancelOrArchiveLabel.textAlignment = .center
        
        
        scrollViewContentView.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(104)
            make.left.equalTo(104 + Constants.screenFrame.size.width)
        }
        agreeButton.backgroundColor = Constants.paletteVioletColor
        
        agreeButton.addSubview(agreeIconImageView)
        agreeIconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
            make.width.height.equalTo(34)
        }
        agreeIconImageView.image = #imageLiteral(resourceName: "agreeSwipeIcon")
        
        agreeButton.addSubview(agreeLabel)
        agreeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(25)
            make.width.equalToSuperview()
            make.height.equalTo(34)
        }
        agreeLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        agreeLabel.textColor = .white
        agreeLabel.text = "забронировать"
        agreeLabel.textAlignment = .center
        
        
        scrollViewContentView.addSubview(openBargainButton)
        openBargainButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalTo(104)
            make.height.equalTo(30)
            make.right.equalTo(agreeButton.snp.left)
        }
        openBargainButton.addTarget(self, action: #selector(openBargainTapped), for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scrollView.bringSubview(toFront: self.openBargainButton)
        }
        
        
        scrollViewContentView.addSubview(bargainView)
        bargainView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(258)
            make.left.equalTo(104 + Constants.screenFrame.size.width)
        }
        
        
        scrollViewContentView.addSubview(completedView)
        completedView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(258)
            make.left.equalTo(104 + Constants.screenFrame.size.width)
        }
        
        scrollView.delegate = self
        
        scrollView.contentSize = CGSize(width: 900, height: 50)
        self.scrollView.setContentOffset(CGPoint(x: 104, y: 0), animated: false)
        
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }
    
    func animateRightSwipe() {
        self.scrollView.setContentOffset(CGPoint(x: 150, y: 0), animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scrollView.setContentOffset(CGPoint(x: 104, y: 0), animated: true)
        }
    }
    
    func animateLeftSwipe() {
        self.scrollView.setContentOffset(CGPoint(x: 50, y: 0), animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scrollView.setContentOffset(CGPoint(x: 104, y: 0), animated: true)
        }
    }
    
    @objc func openBargainTapped() {
        let rightOffset = CGPoint(x: scrollView.contentSize.width - scrollView.bounds.size.width, y: 0)
        scrollView.setContentOffset(rightOffset, animated: true)
    }
    
    class func setDidShowCancel(_ didShowCancel:Bool) {
        UserDefaults.standard.set(didShowCancel, forKey: "didShowCancel")
    }
    
    class func getDidShowCancel() -> Bool {
        let didShowCancel = UserDefaults.standard.value(forKey: "didShowCancel") as? Bool
        
        if (didShowCancel == nil) {
            return false
        } else {
            return didShowCancel!
        }
    }
    
    
    
    class func setDidShowArchive(_ didShowArchive:Bool) {
        UserDefaults.standard.set(didShowArchive, forKey: "didShowArchive")
    }
    
    class func getDidShowArchive() -> Bool {
        let didShowArchive = UserDefaults.standard.value(forKey: "didShowArchive") as? Bool
        
        if (didShowArchive == nil) {
            return false
        } else {
            return didShowArchive!
        }
    }
    
    
    
    class func setDidShowAgree(_ didShowAgree:Bool) {
        UserDefaults.standard.set(didShowAgree, forKey: "didShowAgree")
    }
    
    class func getDidShowAgree() -> Bool {
        let didShowAgree = UserDefaults.standard.value(forKey: "didShowAgree") as? Bool
        
        if (didShowAgree == nil) {
            return false
        } else {
            return didShowAgree!
        }
    }

    
    
    class func setDidShowCompleted(_ didShowCompleted:Bool) {
        UserDefaults.standard.set(didShowCompleted, forKey: "didShowCompleted")
    }
    
    class func getDidShowCompleted() -> Bool {
        let didShowCompleted = UserDefaults.standard.value(forKey: "didShowCompleted") as? Bool
        
        if (didShowCompleted == nil) {
            return false
        } else {
            return didShowCompleted!
        }
    }
    
    
    
    class func setDidShowBargain(_ didShowBargain:Bool) {
        UserDefaults.standard.set(didShowBargain, forKey: "didShowBargain")
    }
    
    class func getDidShowBargain() -> Bool {
        let didShowBargain = UserDefaults.standard.value(forKey: "didShowBargain") as? Bool
        
        if (didShowBargain == nil) {
            return false
        } else {
            return didShowBargain!
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
