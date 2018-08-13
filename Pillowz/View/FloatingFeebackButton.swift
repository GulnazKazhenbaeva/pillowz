//
//  FloatingFeebackButton.swift
//  Pillowz
//
//  Created by Samat on 18.06.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class FloatingFeebackButtonView: UIView {
    let feebackButton = UIButton()
    
    var isShowingButton = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        feebackButton.addTarget(self, action: #selector(createFeedbackTapped), for: .touchUpInside)
        self.addSubview(feebackButton)
        
        let window = UIApplication.shared.keyWindow!

        window.addSubview(self)
    }
    
    @objc func createFeedbackTapped() {
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let subview = super.hitTest(point, with: event)
        
        if !isShowingButton {
            return subview == self.feebackButton ? subview : nil
        } else {
            return subview
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
