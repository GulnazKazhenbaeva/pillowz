
//
//  BargainIterationsView.swift
//  Pillowz
//
//  Created by Samat on 03.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class BargainIterationsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    var iterationLabels:[UILabel] = []
    
    func setIterations(_ iterations: [[String:Any]]){
        for label in iterationLabels {
            label.removeFromSuperview()
        }
        
        for i in 0..<5 {
            let iterationLabel = UILabel()
            addSubview(iterationLabel)
            iterationLabels.append(iterationLabel)
            
            let viewWidth = Constants.screenFrame.size.width - 2*Constants.basicOffset
            
            let xCoodinate:CGFloat = CGFloat(i)*(viewWidth - 26)/4
            
            let spaceBetweenTwoIterationLabels = (viewWidth - 26)/4 - 26
            
            let iterationColor = (i < iterations.count) ? Constants.paletteVioletColor : Constants.paletteVioletColor.lighter()!
            let iterationConnectionColor = (i < iterations.count-1) ? Constants.paletteVioletColor : Constants.paletteVioletColor.lighter()!
            let shouldShowPrices = (i < iterations.count)
            
            var myPrice:Int?
            var otherUserPrice:Int?
            
            if (shouldShowPrices) {
                if (User.currentRole == .realtor) {
                    myPrice = iterations[i]["price_realtor"] as? Int
                    otherUserPrice = iterations[i]["price_client"] as? Int
                } else {
                    myPrice = iterations[i]["price_client"] as? Int
                    otherUserPrice = iterations[i]["price_realtor"] as? Int
                }
            }
            
            iterationLabel.backgroundColor = iterationColor
            iterationLabel.text = String(i+1)
            iterationLabel.textColor = .white
            iterationLabel.layer.cornerRadius = 13
            iterationLabel.font = UIFont.init(name: "OpenSans-Bold", size: 16)!
            iterationLabel.textAlignment = .center
            iterationLabel.clipsToBounds = true
            
            iterationLabel.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(xCoodinate)
                make.width.height.equalTo(26)
                make.top.equalToSuperview()
            })
            
            let otherUserPriceLabel = UILabel()
            addSubview(otherUserPriceLabel)
            iterationLabels.append(otherUserPriceLabel)

            otherUserPriceLabel.snp.makeConstraints({ (make) in
                make.centerX.equalTo(iterationLabel.snp.centerX)
                make.top.equalTo(iterationLabel.snp.bottom).offset(10)
                make.height.equalTo(13)
                make.width.equalTo(50)
            })
            otherUserPriceLabel.font = UIFont.init(name: "OpenSans-Light", size: 11)!
            otherUserPriceLabel.textColor = Constants.paletteVioletColor
            
            if (otherUserPrice != nil) {
                otherUserPriceLabel.text = String(otherUserPrice!)+"₸"
            }
            
            otherUserPriceLabel.textAlignment = .center
            otherUserPriceLabel.isHidden = !shouldShowPrices
            
            let currentUserPriceLabel = UILabel()
            addSubview(currentUserPriceLabel)
            iterationLabels.append(currentUserPriceLabel)
            
            currentUserPriceLabel.snp.makeConstraints({ (make) in
                make.centerX.equalTo(iterationLabel.snp.centerX)
                make.top.equalTo(otherUserPriceLabel.snp.bottom).offset(5)
                make.height.equalTo(13)
                make.width.equalTo(50)
            })
            currentUserPriceLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 11)!
            currentUserPriceLabel.textColor = Constants.paletteBlackColor
            
            if (myPrice != nil) {
                currentUserPriceLabel.text = String(myPrice!)+"₸"
            }
            
            currentUserPriceLabel.textAlignment = .center
            currentUserPriceLabel.isHidden = !shouldShowPrices

            if (i < 4) {
                let iterationConnectionView = UIView()
                iterationConnectionView.backgroundColor = iterationConnectionColor
                
                addSubview(iterationConnectionView)
                iterationConnectionView.snp.makeConstraints({ (make) in
                    make.left.equalTo(iterationLabel.snp.right)
                    make.width.equalTo(spaceBetweenTwoIterationLabels)
                    make.height.equalTo(1)
                    make.centerY.equalTo(iterationLabel.snp.centerY)
                })
            }
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
