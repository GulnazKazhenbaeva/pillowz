//
//  NoInfoTapPlusView.swift
//  Pillowz
//
//  Created by Samat on 17.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class NoInfoTapPlusView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    let noInfoLabel = UILabel()
    let arrowImageView = UIImageView()
    let actionButton = PillowzButton()
    
    override var isHidden: Bool {
        didSet {
            self.actionButton.isHidden = isHidden
        }
    }
    
    var noInfoText:String! {
        didSet {
            noInfoLabel.text = noInfoText
            noInfoLabel.snp.updateConstraints { (make) in
                let height = noInfoText.height(withConstrainedWidth: Constants.screenFrame.size.width - 2*Constants.basicOffset, font: noInfoLabel.font)
                
                make.height.equalTo(height + 20)
            }
        }
    }
    
    var actionClosure:ModalViewActionClosure? {
        didSet {
            addActionButton()
            arrowImageView.isHidden = true
            actionButton.isHidden = false
        }
    }
    
    init(showPlus:Bool) {
        super.init(frame: CGRect.zero)
        
        self.isUserInteractionEnabled = false
        
        self.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-Constants.basicOffset - 20)
            make.right.equalToSuperview().offset(-Constants.basicOffset - 56 - 10)
            make.width.equalTo(70)
            make.height.equalTo(115)
        }
        arrowImageView.image = #imageLiteral(resourceName: "arrow")
        
        self.addSubview(noInfoLabel)
        noInfoLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(80)
            if showPlus {
                make.bottom.equalTo(arrowImageView.snp.top).offset(-20)
            } else {
                make.centerY.equalToSuperview()
            }
        }
        noInfoLabel.font = UIFont.init(name: "OpenSans-Regular", size: 15)
        noInfoLabel.textColor = Constants.paletteLightGrayColor
        noInfoLabel.textAlignment = .center
        noInfoLabel.numberOfLines = 0
    }
    
    func addActionButton() {
        self.superview!.addSubview(actionButton)
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(noInfoLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(33)
        }
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        actionButton.setTitle("Войти", for: .normal)
        actionButton.isHidden = true
        actionButton.isUserInteractionEnabled = true
    }
    
    @objc func actionTapped() {
        actionClosure?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
