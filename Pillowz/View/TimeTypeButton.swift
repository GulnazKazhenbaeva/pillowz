//
//  TimeTypeButton.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 27.07.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class TypeSwitcherView: UIView {
    var dayImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Colors.mainVioletColor
        iv.image = #imageLiteral(resourceName: "dayIcon_violet")
        return iv
    }()
    
    var dayLabel: UILabel = {
        let label = UILabel()
        label.text = "Посуточно"
        label.font = UIFont.init(name: "OpenSans-Regular", size: 14)
        return label
    }()
    
    var dayView = UIView()
    
    var monthImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Colors.mainVioletColor
        iv.image = #imageLiteral(resourceName: "monthIcon-white").withRenderingMode(.alwaysTemplate)
        return iv
    }()
    
    var monthLabel: UILabel = {
        let label = UILabel()
        label.text = "Помесячно"
        label.font = UIFont.init(name: "OpenSans-Regular", size: 14)
        return label
    }()
    
    var monthView = UIView()
    
    var viewHeight: CGFloat! {
        didSet {
            [dayImageView, dayView, monthImageView, monthView].forEach { (view) in
                view.layer.cornerRadius = viewHeight/2
                view.clipsToBounds = true
                view.layer.borderWidth = 1
            }
            setupViews()
        }
    }
    
    var violetLightColor = UIColor.init(hexString: "#BAC2DE")

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupViews() {
        let viewWidth = (Constants.screenWidth - 10 - Constants.basicOffset * 2)/2
        
        [dayView, monthView].forEach({addSubview($0)})
        
        dayView.snp.makeConstraints { (make) in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(viewWidth)
        }
        
        [dayImageView, dayLabel].forEach({dayView.addSubview($0)})
        
        dayImageView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(viewHeight)
        }
        
        dayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dayImageView.snp.right).offset(15)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(22)
        }
        
        monthView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(dayView.snp.right).offset(10)
        }
        
        [monthImageView, monthLabel].forEach({monthView.addSubview($0)})
        
        monthImageView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(viewHeight)
        }
        
        monthLabel.snp.makeConstraints { (make) in
            make.left.equalTo(monthImageView.snp.right).offset(15)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(22)
        }

    }
    
    func changeSelection(toMonth: Bool) {
        if toMonth {
            monthView.backgroundColor = Colors.mainVioletColor
            monthView.layer.borderColor = Colors.mainVioletColor.cgColor
            monthLabel.textColor = .white
            monthImageView.image = #imageLiteral(resourceName: "monthIcon-white").withRenderingMode(.alwaysOriginal)
            monthImageView.layer.borderColor = Colors.mainVioletColor.cgColor
            
            dayView.backgroundColor = .white
            dayView.layer.borderColor = UIColor.clear.cgColor
            dayLabel.textColor = violetLightColor
            dayImageView.image = #imageLiteral(resourceName: "dayIcon_violet").withRenderingMode(.alwaysOriginal)
            dayImageView.layer.borderColor = UIColor.clear.cgColor
        } else {
            dayView.backgroundColor = Colors.mainVioletColor
            dayView.layer.borderColor = Colors.mainVioletColor.cgColor
            dayLabel.textColor = .white
            dayImageView.image = #imageLiteral(resourceName: "dayIcon_white").withRenderingMode(.alwaysOriginal)
            dayImageView.layer.borderColor = Colors.mainVioletColor.cgColor
            
            monthView.backgroundColor = .white
            monthView.layer.borderColor = UIColor.clear.cgColor
            monthLabel.textColor = violetLightColor
            monthImageView.image = #imageLiteral(resourceName: "monthIcon-violet").withRenderingMode(.alwaysOriginal)
            monthImageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}

class TimeTypeButton: UIButton {
    var view = TypeSwitcherView()
    var button = UIButton()
    
    var buttonHeight: CGFloat! {
        didSet {
            isUserInteractionEnabled = true
            initViews()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initViews() {
        isSelected = true
        backgroundColor = .clear
        layer.borderColor = UIColor.init(hexString: "#BAC2DE").cgColor
        layer.borderWidth = 1
        layer.cornerRadius = buttonHeight/2
        clipsToBounds = true

        [view, button].forEach({ (view) in
            addSubview(view)
            view.layer.cornerRadius = buttonHeight/2
            view.clipsToBounds = true
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        })
        bringSubview(toFront: button)
        view.viewHeight = buttonHeight
    }
}
