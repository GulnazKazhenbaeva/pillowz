//
//  BookingRequestViewController.swift
//  Pillowz
//
//  Created by Samat on 28.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import MBProgressHUD

class BookingRequestViewController: PillowzViewController {
    let deleteBookingButton = UIButton()
    let userView = UserBookingView(full: true, book: Book())
    
    let chatButton = UIButton()
    let callButton = UIButton()
    
    let closeButton = UIButton()
    
    var book:Book! {
        didSet {
            userView.book = book
            
            if (book.request.timestamp == nil) {
                chatButton.isHidden = true
                callButton.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Constants.paletteVioletColor
        
        self.view.addSubview(deleteBookingButton)
        deleteBookingButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(225)
            make.bottom.equalToSuperview().offset(-26)
        }
        deleteBookingButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
        deleteBookingButton.setTitleColor(.white, for: .normal)
        deleteBookingButton.layer.borderColor = UIColor.white.cgColor
        deleteBookingButton.layer.borderWidth = 1
        deleteBookingButton.layer.cornerRadius = 20
        deleteBookingButton.addTarget(self, action: #selector(deleteBookingTapped), for: .touchUpInside)
        deleteBookingButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        deleteBookingButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        deleteBookingButton.setImage(#imageLiteral(resourceName: "deleteBooking"), for: .normal)
        deleteBookingButton.setTitle("Удалить бронирование", for: .normal)
        
        self.view.addSubview(chatButton)
        chatButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(deleteBookingButton.snp.top).offset(-25)
            make.centerX.equalToSuperview().offset(-60)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        chatButton.backgroundColor = .white
        chatButton.layer.cornerRadius = 10
        chatButton.setTitle("Написать", for: .normal)
        chatButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        chatButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        chatButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        chatButton.isUserInteractionEnabled = true
        chatButton.addCenterImage(#imageLiteral(resourceName: "chat"), color: Constants.paletteVioletColor)
        
        self.view.addSubview(callButton)
        callButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(deleteBookingButton.snp.top).offset(-25)
            make.centerX.equalToSuperview().offset(60)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        callButton.backgroundColor = .white
        callButton.layer.cornerRadius = 10
        callButton.setTitle("Позвонить", for: .normal)
        callButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        callButton.setTitleColor(Constants.paletteVioletColor, for: .normal)
        callButton.isUserInteractionEnabled = true
        callButton.addCenterImage(#imageLiteral(resourceName: "call"), color: Constants.paletteVioletColor)

        self.view.addSubview(userView)
        userView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(callButton.snp.top).offset(-20)
        }
        userView.shouldOpenBookingVCOnTap = false
        
        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview()
            make.width.height.equalTo(50)
        }
        closeButton.setImage(#imageLiteral(resourceName: "closeWhite"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func chatTapped() {
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true

        chatVC.room = book.request!.chat_room!
                
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc func callTapped() {
        if let phoneCallURL = URL(string: "tel://\(book.request!.user!.phone!)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                
            }
        }
    }
    
    @objc func deleteBookingTapped() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpaceAPIManager.deleteBooking(bookId: book.book_id) { (responseObject, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if (error == nil) {
                DesignHelpers.makeToastWithText("Бронь удалена")
                
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func closeTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
