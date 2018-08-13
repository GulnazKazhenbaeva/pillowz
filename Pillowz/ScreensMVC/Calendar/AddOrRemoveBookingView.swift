//
//  AddBookingView.swift
//  Pillowz
//
//  Created by Samat on 22.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol AddBookingViewDelegate {
    func didTapAddBookingForDate(_ date:Date)
    func didTapRemoveBooking(_ booking:Book)
}

class AddOrRemoveBookingView: UIView {
    let dateLabel = UILabel()
    let bottomView = UIView()
    let statusLabel = UILabel()
    let addOrRemoveBookingButton = UIButton()
    
    var date:Date! {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "dd MMMM"

            dateLabel.text = dateFormatter.string(from: date)
        }
    }
    var delegate:AddBookingViewDelegate?
    
    var book:Book?
    
    init(date: Date, delegate: AddBookingViewDelegate, book:Book?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        self.addSubview(bottomView)
        bottomView.backgroundColor = Constants.paletteVioletColor
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            
            if (book == nil) {
                make.top.equalTo(self.snp.bottom).offset(-136 - 49)
                make.height.equalTo(144)
            } else {
                make.top.equalTo(self.snp.bottom).offset(-181 - 49)
                make.height.equalTo(189)
            }
        }
        bottomView.layer.cornerRadius = 8
        
        bottomView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(20)
        }
        dateLabel.font = UIFont.init(name: "OpenSans-Light", size: 13)!
        dateLabel.textColor = .white
        
        bottomView.addSubview(addOrRemoveBookingButton)
        addOrRemoveBookingButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(225)
            make.bottom.equalToSuperview().offset(-27)
        }
        addOrRemoveBookingButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
        addOrRemoveBookingButton.setTitleColor(.white, for: .normal)
        addOrRemoveBookingButton.layer.borderColor = UIColor.white.cgColor
        addOrRemoveBookingButton.layer.borderWidth = 1
        addOrRemoveBookingButton.layer.cornerRadius = 20
        addOrRemoveBookingButton.addTarget(self, action: #selector(addOrRemoveBookingTapped), for: .touchUpInside)
        addOrRemoveBookingButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        addOrRemoveBookingButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        if (book == nil) {
            addOrRemoveBookingButton.setImage(#imageLiteral(resourceName: "addBooking"), for: .normal)
            addOrRemoveBookingButton.setTitle("Добавить бронь", for: .normal)
        } else {
            addOrRemoveBookingButton.setImage(#imageLiteral(resourceName: "deleteBooking"), for: .normal)
            addOrRemoveBookingButton.setTitle("Удалить бронирование", for: .normal)
        }
        
        self.date = date
        self.delegate = delegate
        self.book = book
    }
    
    @objc func addOrRemoveBookingTapped() {
        if (book == nil) {
            delegate?.didTapAddBookingForDate(date)
        } else {
            delegate?.didTapRemoveBooking(book!)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
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
