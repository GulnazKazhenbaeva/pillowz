//
//  RateView.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 11/23/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class RateView: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var starImageViews:[UIImageView] = []
    
    func setStars(stars: Int){
        for view in starImageViews {
            view.removeFromSuperview()
        }
        
        for i in 0..<5 {
            let starImageView = UIImageView()
            addSubview(starImageView)
            
            starImageViews.append(starImageView)
            
            let originalImage = (i < stars) ? UIImage(named: "filledStar") : UIImage(named: "unfilledStar")

            starImageView.fillImageView(image: originalImage!, color: Constants.paletteVioletColor)
            
            starImageView.snp.makeConstraints({ (make) in
                make.leading.equalToSuperview().offset(CGFloat(i) * 12)
                make.centerY.equalToSuperview()
            })
            
            starImageView.contentMode = .center
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
