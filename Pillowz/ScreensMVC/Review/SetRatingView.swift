//
//  SetRatingView.swift
//  Pillowz
//
//  Created by Samat on 15.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

protocol SetRatingViewDelegate {
    func didPickRatingValue(_ value:Int)
}

class SetRatingView: UIView {
    var delegate:SetRatingViewDelegate?
    
    var starImageViews:[UIImageView] = []
    var starButtons:[UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        
        setStars(stars: 3)
    }
    
    func initViews() {
        for i in 0..<5 {
            let starImageView = UIImageView()
            addSubview(starImageView)
            starImageViews.append(starImageView)
            
            let starButton = UIButton()
            addSubview(starButton)
            starButtons.append(starButton)
            
            starButton.tag = i + 1
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            
            starImageView.snp.makeConstraints({ (make) in
                make.leading.equalToSuperview().offset(CGFloat(i) * 34)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(27)
            })
            
            starButton.snp.makeConstraints({ (make) in
                make.edges.equalTo(starImageView.snp.edges)
            })
        }
    }
    
    func setStars(stars: Int){
        for i in 0..<5 {
            let originalImage = (i < stars) ? UIImage(named: "bigFilledStar") : UIImage(named: "bigUnfilledStar")

            starImageViews[i].fillImageView(image: originalImage!, color: Constants.paletteVioletColor)
        }
    }
    
    @objc func starTapped(_ sender:UIButton) {
        let starNumber = sender.tag
        
        setStars(stars: starNumber)
        
        delegate?.didPickRatingValue(starNumber)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
