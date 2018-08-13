//
//  SpaceOfferTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 20.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceOfferTableViewCell: RequestAndOfferSwipeActionsHandlerTableViewCell, BargainViewDelegate, UserTableViewCellDelegate {
    let spaceOfferView = SpaceOfferView()
    
    var request:Request!
    
    var offer:Offer! {
        didSet {
            agreeButton.isHidden = true
            bargainView.isHidden = true
            completedView.isHidden = true
            cancelOrArchiveButton.isHidden = true
            self.scrollViewContentView.snp.updateConstraints { (make) in
                make.width.equalTo(Constants.screenFrame.size.width)
            }

            spaceOfferView.request = request
            spaceOfferView.offer = offer
            
            scrollView.snp.updateConstraints { (make) in
                make.height.equalTo(160)
            }
            
            if User.currentRole == .client {
                self.cancelOrArchiveLabel.text = "отклонить"
            } else {
                self.cancelOrArchiveLabel.text = "отменить"
            }
            
            //THIS IS A BAD DECISION, BUT I'M DOING THIS BECAUSE THERE IS NO TIME FOR NOW
            cancelOrArchiveButton.backgroundColor = .white
            
            if request.isActive() {
                self.scrollViewContentView.snp.updateConstraints { (make) in
                    make.width.equalTo(Constants.screenFrame.size.width)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.configureSwipes()
                }
            } else {
                self.scrollViewContentView.snp.updateConstraints { (make) in
                    make.width.equalTo(Constants.screenFrame.size.width)
                }

                self.spaceOfferView.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(0)
                }
            }
            
            self.scrollViewContentView.snp.updateConstraints { (make) in
                make.height.equalTo(150)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        scrollView.addSubview(spaceOfferView)
        spaceOfferView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(104)
            make.width.equalTo(Constants.screenFrame.size.width)
        }
        
        cancelOrArchiveButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        
        bargainView.delegate = self
    }
    
    func configureSwipes() {
        self.cancelOrArchiveButton.backgroundColor = UIColor(hexString: "#FA533C")
        self.cancelOrArchiveButton.isHidden = false
                
        if self.offer.status == .COMPLETED {
            self.completedView.isHidden = false
            
            self.completedView.delegate = self
            
            self.completedView.user = self.offer.otherUser
            self.completedView.priceLabel.text = String(self.offer.agreePrice) + "₸"
            
            self.scrollViewContentView.snp.updateConstraints { (make) in
                make.width.equalTo(104 + Constants.screenFrame.size.width + 258)
            }
        } else {
            // Your code with delay
            if self.request.bargain == true {
                self.scrollViewContentView.snp.updateConstraints { (make) in
                    make.width.equalTo(104 + Constants.screenFrame.size.width + 258)
                }
                
                self.bargainView.fillWithOffer(self.offer, fillingRequest: self.request)
                
                self.bargainView.isHidden = false
            } else {
                self.scrollViewContentView.snp.updateConstraints { (make) in
                    make.width.equalTo(104*2 + Constants.screenFrame.size.width)
                }
                
                self.agreeButton.isHidden = false
                
                let justSentAnOffer = self.offer.justSentAnOffer()
                
                if justSentAnOffer {
                    self.agreeButton.backgroundColor = Constants.paletteLightGrayColor
                    self.agreeButton.isEnabled = false
                    self.agreeLabel.text = "ответ ожидается"
                } else {
                    self.agreeButton.backgroundColor = Constants.paletteVioletColor
                    self.agreeButton.isEnabled = true
                    self.agreeLabel.text = "забронировать"
                }
            }
        }
        
        self.spaceOfferView.snp.updateConstraints { (make) in
            make.left.equalToSuperview().offset(104)
        }
        
        self.scrollView.setContentOffset(CGPoint(x: 104, y: 0), animated: false)
    }
    
    func rejectTapped() {
        cancelTapped()
    }
    
    func offerNewPriceTapped(newPrice: Int) {
        self.offer.offerNewPriceTapped(newPrice: newPrice) { (responseObject, error) in
            if error == nil {
                self.request = responseObject as? Request
            }
        }
    }
    
    @objc func agreeTapped() {
        self.offer.agreeTapped { (responseObject, error) in
            if error == nil {
                self.request = responseObject as? Request
                
                for iteratingOffer in self.request!.offers! {
                    if (self.offer!.id! == iteratingOffer.id!) {
                        self.offer = iteratingOffer
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let rightOffset = CGPoint(x: self.scrollView.contentSize.width - self.scrollView.bounds.size.width, y:0)
                    self.scrollView.setContentOffset(rightOffset, animated: true)
                }
            }
        }
    }
    
    @objc func cancelTapped() {
        self.offer.rejectTapped { (responseObject, error) in
            if error == nil {
                self.request = responseObject as? Request
            }
        }
    }
    
    func chatTapped() {
        if let chat_room = request?.chat_room {
            let chatVC = ChatViewController()
            chatVC.hidesBottomBarWhenPushed = true

            chatVC.room = chat_room
            
            UIApplication.topViewController()?.navigationController?.pushViewController(chatVC, animated: true)
        } else {
            let infoView = ModalInfoView(titleText: "Чат недоступен", descriptionText: "Поле chat_room отсутствует")
            
            infoView.addButtonWithTitle("OK", action: {
                
            })
            
            infoView.show()
        }
    }
    
    func callTapped() {
        var phone:String = ""
        
        phone = offer!.otherUser.phone!
        
        if let phoneCallURL = URL(string: "tel://\(phone)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                
            }
        } else {
            let infoView = ModalInfoView(titleText: "Не удается вызвать указанный номер:" + phone, descriptionText: "Свяжитесь с сервисом техподдержки если владелец недоступен, мы решим данную проблему")
            
            infoView.addButtonWithTitle("OK", action: {
                
            })
            
            infoView.show()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let leftSideOffsetToSnap:CGFloat = 50
        var middleOffsetToSnap:CGFloat = 124
        
        if request.bargain == true {
            middleOffsetToSnap = (CGFloat(104) + Constants.screenFrame.size.width/2)
        } else {
            middleOffsetToSnap = CGFloat(124)
        }
        
        if targetContentOffset.pointee.x < leftSideOffsetToSnap {
            targetContentOffset.pointee.x = 0
        } else if targetContentOffset.pointee.x > leftSideOffsetToSnap && targetContentOffset.pointee.x < middleOffsetToSnap {
            targetContentOffset.pointee.x = 104
        } else {
            targetContentOffset.pointee.x = 104 + Constants.screenFrame.size.width
        }
        
        print("here")
        
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        
        viewOffer()
    }
    
    func viewOffer() {
        if !self.spaceOfferView.unreadDotView.isHidden {
            RequestAPIManager.viewOffer(self.offer!.id!) { (responseObject, error) in
                self.offer.client_viewed = true
                self.offer.realtor_viewed = true
                self.spaceOfferView.unreadDotView.isHidden = true
            }
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
