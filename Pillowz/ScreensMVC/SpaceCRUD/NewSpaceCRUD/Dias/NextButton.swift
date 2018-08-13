//
//  NextButton.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 27.07.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class NextButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 20
        titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 14)!
        setTitleColor(Colors.black, for: .normal)
        setTitle("Продолжить", for: .normal)
        
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
