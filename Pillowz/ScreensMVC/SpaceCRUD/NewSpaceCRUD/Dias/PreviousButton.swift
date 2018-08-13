//
//  PreviousButton.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 04.08.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class PreviousButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
        titleLabel?.font = UIFont.init(name: "OpenSans-SemiBold", size: 14)!
        setTitleColor(Colors.previousButtonColor, for: .normal)
        setTitle("Назад", for: .normal)
        
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
