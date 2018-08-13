//
//  RequestCellView.swift
//  Pillowz
//
//  Created by Samat on 24.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol OpenRequestOpenerDelegate {
    func openRequestTapped(_ request:Request)
}

class RequestCellView: UIView {
    var request:Request! {
        didSet {
            calculatedHeight = 103
            
            leftTimeLabel.text = request.getRequestActiveTimeLeftText()
            
            if (request.favourite != nil) {
                favorite = request.favourite!
            }
            
            if (request.req_type! == .OPEN && User.currentRole == .realtor) {
                self.favoriteButton.isHidden = false
            } else {
                self.favoriteButton.isHidden = true
            }
            
            let isOpen = request.req_type! == .OPEN
            categoryRentTypePriceLabel.isHidden = isOpen
            
            if (!isOpen) {
                if (request.otherUser.review == nil) {
                    self.rateView.setStars(stars: 0)
                } else {
                    self.rateView.setStars(stars: request.otherUser.review!)
                }
                
                categoryRentTypePriceLabel.snp.updateConstraints({ (make) in
                    make.height.equalTo(18)
                })
                
                calculatedHeight = calculatedHeight + 18
                
                self.nameOrCategoryRentTypePriceLabel.text = request.open_name
            } else {
                categoryRentTypePriceLabel.snp.updateConstraints({ (make) in
                    make.height.equalTo(0)
                })
                self.nameOrCategoryRentTypePriceLabel.text = request.open_price
                
                if let offers_count = request.offers_count, offers_count != 0, User.currentRole == .realtor {
                    offerLabel.attributedText = NSAttributedString(string: String(offers_count) + " предложений", attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
                } else {
                    offerLabel.text = ""
                }
            }
            
            if let height = self.nameOrCategoryRentTypePriceLabel.text?.height(withConstrainedWidth: Constants.screenFrame.size.width - 2*Constants.basicOffset - 56 - 14, font: self.nameOrCategoryRentTypePriceLabel.font) {
                nameOrCategoryRentTypePriceLabel.snp.updateConstraints { (make) in
                    make.height.equalTo(height + 4)
                }
                
                calculatedHeight = calculatedHeight + height + 4
            }
            
            if let name = request.otherUser.name {
                self.userNameLabel.attributedText = NSAttributedString(string: name, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            }
            
            if request.req_type! == .PERSONAL {
                offerLabel.isHidden = true
            } else {
                offerLabel.isHidden = false
            }
            
            categoryRentTypePriceLabel.text = request.open_price
            
            let status = Request.getStatusText(isOffer: (offer != nil), request: self.request, offer: offer)
            statusLabel.text = status.0
            statusLabel.textColor = status.1
            statusLabel.font = status.2
            
//            if (leftTimeLabel.text == "Заявка аннулирована") {
//                statusLabel.text = "Заявка просрочена"
//                statusLabel.textColor = UIColor(hexString: "#FA3C3C")
//                statusLabel.font = UIFont(name: "OpenSans-Bold", size: 10)
//            }
            
            bargainArrowImageView.isHidden = true
            bargainArrowImageView.snp.updateConstraints { (make) in
                make.width.equalTo(0)
                make.height.equalTo(0)
            }
            
            if (request.bargain != nil && request.bargain!) {
                bargainTextLabel.isHidden = false
            } else {
                bargainTextLabel.isHidden = true
            }
            
            spaceOrUserAvatarImageView.clipsToBounds = true
            spaceOrUserAvatarImageView.image = UIImage()

            if (request.req_type! == .OPEN) {
                if let url = request.user?.avatar {
                    spaceOrUserAvatarImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage())
                }
                
                spaceOrUserAvatarImageView.layer.cornerRadius = 28
                spaceOrUserAvatarImageView.layer.borderWidth = 1
                spaceOrUserAvatarImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
            } else {
                var url = request.space_info?["image"] as? String
                
                if (request.space != nil) {
                    url = request.space?.images?.first?.image
                }
                
                if (url != nil) {
                    spaceOrUserAvatarImageView.sd_setImage(with: URL(string: url!), placeholderImage: UIImage())
                }
                
                spaceOrUserAvatarImageView.layer.cornerRadius = 2
                spaceOrUserAvatarImageView.layer.borderWidth = 0
                
                if (request.bargain != nil && request.bargain!) {
                    bargainArrowImageView.isHidden = false
                    
                    bargainArrowImageView.snp.updateConstraints { (make) in
                        make.width.equalTo(21)
                        make.height.equalTo(21)
                    }
                    
                    if !request.isCompleted() && !request.isWaitingForAnswer() {
                        bargainArrowImageView.image = #imageLiteral(resourceName: "rightRed")
                        
                        animateArrow()
                    }
                }
            }
            
            var viewed = true
            
            if (User.currentRole == .realtor && !request.realtor_viewed) {
                viewed = false
            }
            
            if (User.currentRole == .client && !request.client_viewed) {
                viewed = false
            }
            
            unreadDotView.isHidden = viewed
            
            if let rent_type = request.rent_type, let start_time = request.start_time, let end_time = request.end_time {
                let periodText = Request.getStringForRentType(rent_type, startTime: start_time, endTime: end_time, shouldGoToNextLine: false, includeRentTypeText: false)
                periodLabel.text = periodText
            }
        }
    }
    
    var calculatedHeight:CGFloat = 103
    
    var favorite:Bool! {
        didSet {
            let favoriteImage = (favorite) ? #imageLiteral(resourceName: "loveRequestFilled") : #imageLiteral(resourceName: "loveRequest")
            self.favoriteButton.setImage(favoriteImage, for: .normal)
        }
    }
    
    var delegate:RequestTableViewCellDelegate?
    
    var offer:Offer?
    
    let statusLabel = UILabel()
    
    let spaceOrUserAvatarImageView = UIImageView()
    let userNameLabel = UILabel()
    let userNameButton = UIButton()
//    let moreButton = UIButton()
    let rateView = RateView()
    
    let nameOrCategoryRentTypePriceLabel = UILabel()
    let categoryRentTypePriceLabel = UILabel()
    
    let favoriteButton = UIButton()
    let bargainTextLabel = UILabel()
    
    
    let leftTimeLabel = UILabel()
    let clockImageView = UIImageView()
    let offerLabel = UILabel()
    
    let unreadDotView = UIView()
    
    let periodLabel = UILabel()
    
    let bargainArrowImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        statusLabel.textAlignment = .right
        statusLabel.setLightGrayStyle()
        self.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(16)
            make.left.equalToSuperview().offset(Constants.basicOffset)
        }
        
//        moreButton.setImage(#imageLiteral(resourceName: "verticalDots"), for: .normal)
//        moreButton.imageView?.contentMode = .center
//        self.addSubview(moreButton)
//        moreButton.snp.makeConstraints { (make) in
//            make.top.equalTo(statusLabel.snp.bottom).offset(0)
//            make.right.equalToSuperview().offset(0)
//            make.width.equalTo(3+2*Constants.basicOffset)
//            make.height.equalTo(32)
//        }
//        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        
        self.addSubview(unreadDotView)
        unreadDotView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(10)
        }
        unreadDotView.backgroundColor = Constants.paletteVioletColor
        unreadDotView.layer.cornerRadius = 5
        
        
        spaceOrUserAvatarImageView.contentMode = .scaleAspectFill
        spaceOrUserAvatarImageView.backgroundColor = .lightGray
        spaceOrUserAvatarImageView.clipsToBounds = true
        spaceOrUserAvatarImageView.layer.masksToBounds = true
        self.addSubview(spaceOrUserAvatarImageView)
        spaceOrUserAvatarImageView.snp.makeConstraints { (make) in
            make.top.equalTo(statusLabel.snp.bottom).offset(7)
            make.width.equalTo(56)
            make.height.equalTo(56)
            make.left.equalToSuperview().offset(Constants.basicOffset)
        }
        
        userNameLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 11)!
        userNameLabel.textColor = Constants.paletteVioletColor
        self.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(spaceOrUserAvatarImageView.snp.top)
            make.left.equalTo(spaceOrUserAvatarImageView.snp.right).offset(14)
            make.height.equalTo(16)
        }
        
        self.addSubview(rateView)
        rateView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userNameLabel)
            make.left.equalTo(userNameLabel.snp.right).offset(10)
            make.height.equalTo(22)
            make.width.equalTo(60)
        }
        
        userNameButton.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
        self.addSubview(userNameButton)
        userNameButton.snp.makeConstraints { (make) in
            make.top.equalTo(statusLabel.snp.bottom).offset(10)
            make.left.equalTo(userNameLabel)
            make.right.equalTo(rateView)
            make.height.equalTo(16)
        }
        
        self.addSubview(nameOrCategoryRentTypePriceLabel)
        nameOrCategoryRentTypePriceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userNameButton.snp.bottom).offset(2)
            make.left.equalTo(spaceOrUserAvatarImageView.snp.right).offset(14)
            make.right.equalToSuperview().offset(-Constants.basicOffset-12)
            make.height.equalTo(50)
        }
        nameOrCategoryRentTypePriceLabel.numberOfLines = 0
        nameOrCategoryRentTypePriceLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 16)!
        nameOrCategoryRentTypePriceLabel.textColor = Constants.paletteBlackColor
        
        categoryRentTypePriceLabel.textColor = Constants.paletteBlackColor
        categoryRentTypePriceLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 11)!
        categoryRentTypePriceLabel.clipsToBounds = false
        self.addSubview(categoryRentTypePriceLabel)
        categoryRentTypePriceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameOrCategoryRentTypePriceLabel.snp.bottom).offset(0)
            make.left.equalTo(spaceOrUserAvatarImageView.snp.right).offset(14)
            make.height.equalTo(18)
        }
        
        periodLabel.textColor = UIColor.init(hexString: "5263FF")
        periodLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)
        self.addSubview(periodLabel)
        periodLabel.snp.makeConstraints { (make) in
            make.top.equalTo(categoryRentTypePriceLabel.snp.bottom).offset(0)
            make.left.equalTo(spaceOrUserAvatarImageView.snp.right).offset(14)
            make.height.equalTo(21)
        }
        
        leftTimeLabel.setLightGrayStyle()
        self.addSubview(leftTimeLabel)
        leftTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(periodLabel.snp.bottom).offset(0)
            make.left.equalTo(spaceOrUserAvatarImageView.snp.right).offset(14+14+7)
            make.height.equalTo(21)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        
        self.addSubview(bargainArrowImageView)
        bargainArrowImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(leftTimeLabel.snp.bottom)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(21)
            make.width.equalTo(31)
        }
        bargainArrowImageView.image = #imageLiteral(resourceName: "rightGray")
        bargainArrowImageView.contentMode = .center
        
        
        bargainTextLabel.textAlignment = .right
        bargainTextLabel.textColor = UIColor(hexString: "#FA533C")
        bargainTextLabel.font = UIFont.init(name: "OpenSans-Bold", size: 10)!
        bargainTextLabel.text = "торг"
        self.addSubview(bargainTextLabel)
        bargainTextLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(leftTimeLabel.snp.bottom)
            make.right.equalTo(bargainArrowImageView.snp.left).offset(0)
            make.height.equalTo(21)
            make.width.equalTo(50)
        }
        
        

        
        clockImageView.image = #imageLiteral(resourceName: "clock")
        clockImageView.contentMode = .center
        self.addSubview(clockImageView)
        clockImageView.snp.makeConstraints { (make) in
            make.left.equalTo(spaceOrUserAvatarImageView.snp.right).offset(14)
            make.centerY.equalTo(leftTimeLabel.snp.centerY)
            make.width.height.equalTo(14)
            make.height.equalTo(21)
        }
        
        offerLabel.setLightGrayStyle()
        self.addSubview(offerLabel)
        offerLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(leftTimeLabel)
            make.left.equalTo(leftTimeLabel.snp.right).offset(14)
            make.height.equalTo(14)
        }
        
        calculatedHeight = leftTimeLabel.frame.origin.y + leftTimeLabel.frame.size.height + CGFloat(10)
    }
    
    @objc func moreTapped() {
        self.delegate?.moreTappedForRequest(request)
    }
    
    @objc func userTapped() {
        self.delegate?.openUserWithId(request.otherUser.user_id!)
    }
    
    @objc func openOffersTapped() {
        self.delegate?.openOffersOfRequest(request)
    }
    
    @objc func didTapFavorite() {
        let window = UIApplication.shared.delegate!.window!!
        
        MBProgressHUD.showAdded(to: window, animated: true)
        
        let favorite = !request.favourite!
        
        RequestAPIManager.setRequestFavourite(favorite, request_id: request.request_id!) { (requestObject, error) in
            MBProgressHUD.hide(for: window, animated: true)
            
            if (error == nil) {
                self.favorite = favorite
                self.request.favourite = favorite
            }
        }
    }
    
    func animateArrow() {
        bargainArrowImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.10),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIViewAnimationOptions.repeat,
                       animations: {
                        self.bargainArrowImageView.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
