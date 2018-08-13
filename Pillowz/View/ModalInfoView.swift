//
//  ModalInfoView.swift
//  Pillowz
//
//  Created by Samat on 02.02.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

public typealias ModalViewActionClosure = () -> Void

class ModalInfoView: UIView {
    var actions:[ModalViewActionClosure] = []
    var buttonTitles:[String] = []
    var titleText:String!
    var descriptionText:String!
    var viewIdentifier:String?
    let whiteAlertView = UIView()
    
    init(titleText:String, descriptionText:String, viewIdentifier:String? = nil) {
        super.init(frame: CGRect.zero)
        
        self.titleText = titleText
        self.descriptionText = descriptionText
        self.viewIdentifier = descriptionText
    }
    
    func addButtonWithTitle(_ title:String, action:@escaping ModalViewActionClosure) {
        buttonTitles.append(title)
        actions.append(action)
    }
    
    func addViews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        var totalHeight:CGFloat = 15
        
        whiteAlertView.backgroundColor = .white
        whiteAlertView.layer.cornerRadius = 3
        self.addSubview(whiteAlertView)
        whiteAlertView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(200)
        }
        
        let titleLabel = UILabel()
        
        whiteAlertView.addSubview(titleLabel)
        titleLabel.textColor = Constants.paletteBlackColor
        titleLabel.text = self.titleText
        titleLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 17)!
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            
            let height = self.titleText.height(withConstrainedWidth: Constants.screenFrame.size.width - 2*Constants.basicOffset, font: titleLabel.font)
            make.height.equalTo(height)
            
            totalHeight = totalHeight + height + CGFloat(20)
        }

        let infoLabel = UILabel()

        whiteAlertView.addSubview(infoLabel)
        infoLabel.textColor = Constants.paletteBlackColor
        infoLabel.text = self.descriptionText
        infoLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        infoLabel.numberOfLines = 0
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            
            let height = self.descriptionText.height(withConstrainedWidth: Constants.screenFrame.size.width - 2*Constants.basicOffset, font: infoLabel.font)
            make.height.equalTo(height)
            
            totalHeight = totalHeight + height + CGFloat(30)
        }

        var currentOffset = Constants.basicOffset
        
        for title in self.buttonTitles {
            let button = UIButton()
            let index = self.buttonTitles.index(of: title)!
            
            let font = UIFont.init(name: "OpenSans-Regular", size: 17)!
            
            whiteAlertView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalTo(infoLabel.snp.bottom).offset(10)
                make.height.equalTo(40)
                
                make.right.equalToSuperview().offset(-currentOffset)
                
                let labelWidth = title.width(withConstraintedHeight: 20, font: font) + 10
                
                currentOffset = currentOffset + labelWidth + 16
                
                make.width.equalTo(labelWidth)
            }
            button.tag = index
            button.setTitleColor(Constants.paletteVioletColor, for: .normal)
            button.titleLabel?.font = font
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_ :)), for: .touchUpInside)
        }
        
        totalHeight = totalHeight + CGFloat(20)
        
        totalHeight = totalHeight + CGFloat(14)

        whiteAlertView.snp.updateConstraints { (make) in
            make.height.equalTo(totalHeight)
        }
    }
    
    func saveShouldShowViewValue(_ shouldShowView:Bool) {
        var shouldShowViewString:String
        
        shouldShowViewString = shouldShowView.description
        
        UserDefaults.standard.set(shouldShowViewString, forKey: self.viewIdentifier!)
    }
    
    func shouldShowView() -> Bool {
        if (self.viewIdentifier != nil) {
            let shouldShowViewString = UserDefaults.standard.value(forKey: self.viewIdentifier!) as? String
            
            if (shouldShowViewString == nil) {
                return true
            } else {
                return shouldShowViewString!.toBool()
            }
        } else {
            return false
        }
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow!

        for view in window.subviews {
            if view is ModalInfoView {
                let modalInfoView = view as! ModalInfoView
                modalInfoView.dismissView()
            }
        }
        
        if (self.shouldShowView()) {
            addViews()
            window.addSubview(self)
            self.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else {
            let action = actions.last
            action?()
        }
    }

    @objc func dismissView() {
        self.removeFromSuperview()
    }

    func dismissViewWithLastAction() {
        let action = actions.last
        action?()
        
        self.removeFromSuperview()
    }
    
    @objc func didSelectValue(_ valuePickerSwitch:UISwitch) {
        self.saveShouldShowViewValue(!valuePickerSwitch.isOn)
    }

    @objc func buttonTapped(_ button:UIButton) {
        let action = actions[button.tag]
        action()
        dismissView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if actions.count > 1 {
            dismissViewWithLastAction()
        } else {
            dismissView()
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
