//
//  SpaceBottomView.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 04.08.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceBottomView: UIView {
    let previousButton = PreviousButton()
    let nextButton = NextButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = Colors.mainVioletColor
        [previousButton, nextButton].forEach({addSubview($0)})
        
        previousButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(43)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
            make.width.equalTo(146)
        }
    }
}
