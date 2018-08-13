//
//  BookingModalView.swift
//  Pillowz
//
//  Created by Samat on 17.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol BookingModalViewDelegate {
    func deleteBookingTapped(_ book:Book)
    func openUserWithId(_ userId:Int)
}

class BookingModalView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    let whiteAlertView = UIView()
    //let userView = UserBookingView(full: true, book: Book())

    let deleteBookingButton = UIButton()
    let chatButton = UIButton()
    let callButton = UIButton()
    let spaceNameLabel = UILabel()
    let periodLabel = UILabel()
    let timeLeftLabel = UILabel()
    let userImageView = UIImageView()
    let usernameLabel = UILabel()
    let priceLabel = UILabel()
    let openUserButton = UIButton()

    var delegate:BookingModalViewDelegate? {
        didSet {
            deleteBookingButton.isHidden = false
        }
    }
    
    var book:Book! {
        didSet {
            periodLabel.text = Request.getStringForRentType(.DAILY, startTime: book.timestamp_start, endTime: book.timestamp_end, includeRentTypeText: false)
            
            spaceNameLabel.text = book.name
            
            var fullTimeText = Request.getTimeLeftStringForTimestamp(book.timestamp_start)
            
            if (fullTimeText == "") {
                fullTimeText = "бронь прошла"
            } else {
                fullTimeText = "осталось " + fullTimeText
            }

            timeLeftLabel.text = fullTimeText
            
            if (book.request.timestamp == nil) {
                chatButton.isHidden = true
                callButton.isHidden = true
                userImageView.isHidden = true
                priceLabel.isHidden = true

                usernameLabel.text = "Забронировано Вами"
                
                usernameLabel.snp.updateConstraints({ (make) in
                    make.right.equalToSuperview().offset(-Constants.basicOffset)
                })
                
                whiteAlertView.snp.updateConstraints { (make) in
                    make.height.equalTo(158)
                }
            } else {
                usernameLabel.attributedText = NSAttributedString(string: book.request.user!.name!, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
                
                priceLabel.text = book.request.price!.formattedWithSeparator + "₸"
                
                whiteAlertView.snp.updateConstraints { (make) in
                    make.height.equalTo(197)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.4)

        whiteAlertView.backgroundColor = .white
        whiteAlertView.layer.cornerRadius = 3
        self.addSubview(whiteAlertView)
        whiteAlertView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(197)
        }
        
        whiteAlertView.addSubview(deleteBookingButton)
        deleteBookingButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.bottom.equalToSuperview().offset(-9)
            make.height.equalTo(23)
            make.width.equalTo(130)
        }
        deleteBookingButton.contentHorizontalAlignment = .right
        deleteBookingButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 13)
        deleteBookingButton.setTitleColor(UIColor(hexString: "#FA533C"), for: .normal)
        deleteBookingButton.setTitle("Удалить бронь", for: .normal)
        deleteBookingButton.addTarget(self, action: #selector(deleteBookingTapped), for: .touchUpInside)
        deleteBookingButton.isHidden = true
        
        whiteAlertView.addSubview(timeLeftLabel)
        timeLeftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.bottom.equalToSuperview().offset(-9)
            make.height.equalTo(23)
            make.width.equalTo(130)
        }
        timeLeftLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)
        timeLeftLabel.textColor = UIColor(hexString: "#828282")
        
        userImageView.backgroundColor = UIColor.init(hexString: "#C4C4C4")
        userImageView.layer.cornerRadius = 20
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
        whiteAlertView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.height.equalTo(40)
        }
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor

        callButton.setImage(#imageLiteral(resourceName: "callIcon"), for: .normal)
        callButton.imageView?.contentMode = .scaleAspectFit
        callButton.backgroundColor = Constants.paletteVioletColor
        callButton.layer.cornerRadius = 20
        callButton.clipsToBounds = true
        callButton.layer.masksToBounds = true
        whiteAlertView.addSubview(callButton)
        callButton.snp.makeConstraints { (make) in
            make.right.equalTo(userImageView.snp.left).offset(-10)
            make.width.height.equalTo(40)
            make.top.equalTo(userImageView)
        }
        callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        
        chatButton.setImage(#imageLiteral(resourceName: "chatIcon"), for: .normal)
        chatButton.imageView?.contentMode = .scaleAspectFit
        chatButton.backgroundColor = Constants.paletteVioletColor
        chatButton.layer.cornerRadius = 20
        chatButton.clipsToBounds = true
        chatButton.layer.masksToBounds = true
        whiteAlertView.addSubview(chatButton)
        chatButton.snp.makeConstraints { (make) in
            make.right.equalTo(callButton.snp.left).offset(-10)
            make.width.height.equalTo(40)
            make.top.equalTo(callButton)
        }
        chatButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        
        whiteAlertView.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset-120-26)
            make.centerY.equalTo(userImageView.snp.centerY)
            make.height.equalTo(40)
        }
        usernameLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)
        usernameLabel.textColor = Constants.paletteVioletColor
        usernameLabel.numberOfLines = 0

        whiteAlertView.addSubview(spaceNameLabel)
        spaceNameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalTo(usernameLabel.snp.bottom).offset(14)
            make.height.equalTo(20)
        }
        spaceNameLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)
        spaceNameLabel.textColor = Constants.paletteBlackColor

        whiteAlertView.addSubview(periodLabel)
        periodLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalTo(spaceNameLabel.snp.bottom).offset(0)
            make.height.equalTo(20)
        }
        periodLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)
        periodLabel.textColor = Constants.paletteBlackColor

        whiteAlertView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.top.equalTo(periodLabel.snp.bottom).offset(14)
            make.height.equalTo(20)
        }
        priceLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)
        priceLabel.textColor = UIColor.init(hexString: "#5FBF00")
        
        whiteAlertView.addSubview(openUserButton)
        openUserButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset-120-26)
            make.centerY.equalTo(userImageView.snp.centerY)
            make.height.equalTo(40)
        }
        openUserButton.addTarget(self, action: #selector(openUserTapped), for: .touchUpInside)
    }
    
    @objc func chatTapped() {
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true
        
        chatVC.room = book.request!.chat_room!
        
        self.dismissView()
        
        UIApplication.topViewController()?.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc func callTapped() {
        self.dismissView()

        if let phoneCallURL = URL(string: "tel://\(book.request!.user!.phone!)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                
            }
        }
    }
    
    @objc func openUserTapped() {
        if let userId = book.request?.user?.user_id {
            self.dismissView()

            delegate?.openUserWithId(userId)
        }
    }
    
    @objc func deleteBookingTapped() {
        self.dismissView()
        
        let infoView = ModalInfoView(titleText: "Вы уверены, что хотите удалить бронь?", descriptionText: "Это действие будет необратимо. ")
        
        infoView.addButtonWithTitle("Удалить", action: {
            self.delegate?.deleteBookingTapped(self.book)
        })
        
        infoView.addButtonWithTitle("Отмена", action: {
            
        })
        
        infoView.show()
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
    
    @objc func dismissView() {
        self.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissView()
    }

}
