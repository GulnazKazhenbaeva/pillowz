//
//  BadgeView.swift
//  Pillowz
//
//  Created by Samat on 07.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class BadgeView: UILabel {
    static let messagesBadge = BadgeView()
    static let myRequestsClientBadge = BadgeView()
    static let myRequestsRealtorBadge = BadgeView(isSmall: true)
    static let myRequestsRealtorTopTabBadge = BadgeView()
    
    var value:Int = 0 {
        didSet {
            setValueForBadge()
        }
    }
    
    var shouldBeShown = true {
        didSet {
            setValueForBadge()
        }
    }
    
    func setValueForBadge() {
        self.font = UIFont.init(name: "OpenSans-Bold", size: 10)!
        
        if (value <= 0) {
            self.isHidden = true
        } else {
            self.isHidden = !shouldBeShown
            
            if (!isSmall) {
                self.text = String(value)
                
                if (self.text!.count > 1) {
                    let width = self.text!.width(withConstraintedHeight: 20, font: self.font)
                    
                    self.frame.size.width = width + 6
                } else {
                    self.frame.size.width = 14
                }
            }
        }
    }
    
    var isSmall = false
    
    init(isSmall:Bool = false) {
        super.init(frame: CGRect.zero)
        
        self.isSmall = isSmall
        
        self.backgroundColor = Constants.paletteVioletColor
        
        if (isSmall) {
            self.layer.cornerRadius = 3.5
        } else {
            self.layer.cornerRadius = 7
        }
        self.textColor = .white
        self.clipsToBounds = true
        self.textAlignment = .center
        
        self.isHidden = true
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
