//
//  SpaceOfferView.swift
//  Pillowz
//
//  Created by Samat on 25.05.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceOfferView: UIView {

    var calculatedHeight:CGFloat = 103

    let spaceImageView = UIImageView()
    let statusLabel = UILabel()
    let nameLabel = UILabel()
    let fieldsLabel = UILabel()
    let addressLabel = UILabel()
    let rateView = RateView()
    let reviewDetailLabel = UILabel()
    let unreadDotView = UIView()
    
    var request:Request!

    
    let bargainTextLabel = UILabel()
    let bargainArrowImageView = UIImageView()

    
    
    var offer:Offer! {
        didSet {
            if (offer.space!.review == nil) {
                self.rateView.setStars(stars: 0)
            } else {
                self.rateView.setStars(stars: offer.space!.review!)
            }
            
            self.reviewDetailLabel.text = String(offer.space!.reviews!.count) + " отзывов"
            
            if (offer.space!.name != "") {
                nameLabel.text = offer.space!.name
            } else {
                nameLabel.text = "Название не указано"
            }
            
            if (offer.space!.images!.count != 0) {
                spaceImageView.sd_setImage(with: URL(string: offer.space!.images![0].image!), placeholderImage: UIImage())
            }
            
            fieldsLabel.text = offer.space!.open_name
            addressLabel.text = offer.space!.address
            
            let status = Request.getStatusText(isOffer: (offer != nil), request: self.request, offer: offer)
            statusLabel.text = status.0
            statusLabel.textColor = status.1
            statusLabel.font = status.2
            
            
            
            if (request.bargain != nil && request.bargain!) {
                bargainTextLabel.isHidden = false
            } else {
                bargainTextLabel.isHidden = true
            }
            
            
            if (request.bargain != nil && request.bargain!) {
                bargainArrowImageView.isHidden = false
                
                bargainArrowImageView.snp.updateConstraints { (make) in
                    make.width.equalTo(21)
                    make.height.equalTo(21)
                }
                
                if !offer.isCompleted() && !offer.isWaitingForAnswer() {
                    bargainArrowImageView.image = #imageLiteral(resourceName: "rightRed")
                    
                    animateArrow()
                }
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(unreadDotView)
        unreadDotView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(10)
        }
        unreadDotView.backgroundColor = Constants.paletteVioletColor
        unreadDotView.layer.cornerRadius = 5
        
        spaceImageView.layer.cornerRadius = 2
        spaceImageView.contentMode = .scaleAspectFill
        spaceImageView.backgroundColor = .lightGray
        spaceImageView.clipsToBounds = true
        spaceImageView.layer.masksToBounds = true
        self.addSubview(spaceImageView)
        spaceImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(110)
            make.height.equalTo(110)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.bottom.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        statusLabel.setLightGrayStyle()
        self.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(spaceImageView.snp.top)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(18)
            make.left.equalTo(spaceImageView.snp.right).offset(9)
        }
        
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(statusLabel.snp.bottom)
            make.left.equalTo(spaceImageView.snp.right).offset(9)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(20)
        }
        nameLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 17)
        
        
        fieldsLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        fieldsLabel.textColor = Constants.paletteLightGrayColor
        self.addSubview(fieldsLabel)
        fieldsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(16)
            make.left.equalTo(spaceImageView.snp.right).offset(9)
        }

        addressLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        addressLabel.textColor = Constants.paletteLightGrayColor
        self.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fieldsLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(16)
            make.left.equalTo(spaceImageView.snp.right).offset(9)
        }
        
        self.addSubview(rateView)
        rateView.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
            make.height.equalTo(10)
            make.width.equalTo(58)
            make.left.equalTo(spaceImageView.snp.right).offset(9)
        }
        
        reviewDetailLabel.textColor = UIColor.init(hexString: "#5263FF")
        reviewDetailLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        self.addSubview(reviewDetailLabel)
        reviewDetailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(rateView.snp.right).offset(9)
            make.height.equalTo(18)
            make.width.equalTo(64)
            make.centerY.equalTo(rateView)
        }
        
        self.addSubview(bargainArrowImageView)
        bargainArrowImageView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(15)
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
            make.centerY.equalTo(bargainArrowImageView.snp.centerY)
            make.right.equalTo(bargainArrowImageView.snp.left).offset(0)
            make.height.equalTo(21)
            make.width.equalTo(50)
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
