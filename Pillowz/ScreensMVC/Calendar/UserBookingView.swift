//
//  UserView.swift
//  Pillowz
//
//  Created by Samat on 28.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class UserBookingView: UIView {
    let userImageView = UIImageView()
    let imageViewBorderView = UIView()
    let usernameLabel = UILabel()
    let timeLeftLabel = UILabel()
    let fieldsLabel = UILabel()
    let startTimeLabel = UILabel()
    let endTimeLabel = UILabel()
    
    var shouldOpenBookingVCOnTap = true
    
    var user:User! {
        didSet {
            if (user.name != nil) {
                usernameLabel.text = user.name
            }
            
            if (user.avatar != nil) {
                userImageView.sd_setImage(with: URL(string: user.avatar!), placeholderImage: UIImage())
            }
        }
    }
    
    var request:Request! {
        didSet {
            if (User.currentRole == .client) {
                self.backgroundColor = UIColor(hexString: "#E0E0E0")
                usernameLabel.text = "Забронировано"
                userImageView.isHidden = true
                imageViewBorderView.isHidden = true
                imageViewBorderView.snp.updateConstraints({ (make) in
                    make.width.equalTo(0)
                })
                usernameLabel.snp.updateConstraints({ (make) in
                    make.left.equalTo(imageViewBorderView.snp.right)
                })
            } else {
                if (request.timestamp != nil) {
                    fieldsLabel.text = request.open_price
                    timeLeftLabel.text = request.getRequestStartTimeLeftText()
                    
                    user = request.user!
                } else {
                    usernameLabel.text = "Забронировано Вами"
                    userImageView.isHidden = true
                    imageViewBorderView.isHidden = true
                    imageViewBorderView.snp.updateConstraints({ (make) in
                        make.width.equalTo(0)
                    })
                    usernameLabel.snp.updateConstraints({ (make) in
                        make.left.equalTo(imageViewBorderView.snp.right)
                    })
                }
            }
        }
    }
    
    var book:Book! {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM в HH:mm"
            dateFormatter.timeZone = NSTimeZone.local

            startTimeLabel.text = "Заезд "+dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(book.timestamp_start)))
            endTimeLabel.text = "Выезд "+dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(book.timestamp_end)))
            
            request = book.request
        }
    }
    
    init(full:Bool, book:Book) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = Constants.paletteVioletColor
        self.layer.cornerRadius = 8
        
        self.addSubview(imageViewBorderView)
        imageViewBorderView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(12)
            make.width.height.equalTo(70)
        }
        imageViewBorderView.layer.cornerRadius = 35
        imageViewBorderView.layer.borderColor = UIColor.white.cgColor
        imageViewBorderView.layer.borderWidth = 1
        
        self.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageViewBorderView.snp.centerX)
            make.centerY.equalTo(imageViewBorderView.snp.centerY)
            make.width.height.equalTo(62)
        }
        userImageView.layer.cornerRadius = 32
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor

        self.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageViewBorderView.snp.right).offset(11)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-5)
        }
        usernameLabel.font = UIFont.init(name: "OpenSans-Bold", size: 16)!
        usernameLabel.textColor = .white
        
        self.addSubview(timeLeftLabel)
        timeLeftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageViewBorderView.snp.right).offset(11)
            make.top.equalTo(usernameLabel.snp.bottom)
            make.bottom.equalTo(imageViewBorderView.snp.bottom)
            make.right.equalToSuperview().offset(-5)
        }
        timeLeftLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        timeLeftLabel.textColor = .white
        timeLeftLabel.numberOfLines = 0

        self.addSubview(fieldsLabel)
        fieldsLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(imageViewBorderView.snp.bottom).offset(10)
            make.height.equalTo(45)
            make.right.equalToSuperview().offset(-5)
        }
        fieldsLabel.font = UIFont.init(name: "OpenSans-Bold", size: 16)!
        fieldsLabel.textColor = .white
        fieldsLabel.numberOfLines = 0

        self.addSubview(startTimeLabel)
        startTimeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(fieldsLabel.snp.bottom).offset(10)
            make.height.equalTo(15)
            make.right.equalToSuperview().offset(-5)
        }
        startTimeLabel.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
        startTimeLabel.textColor = .white
        
        self.addSubview(endTimeLabel)
        endTimeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(startTimeLabel.snp.bottom).offset(5)
            make.height.equalTo(15)
            make.right.equalToSuperview().offset(-5)
        }
        endTimeLabel.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
        endTimeLabel.textColor = .white
        
        self.book = book
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (shouldOpenBookingVCOnTap && User.currentRole == .realtor) {
            let view = BookingModalView()
            
            view.book = book
            view.deleteBookingButton.isHidden = true
            
            view.show()
        }
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
