//
//  TotalPaymentView.swift
//  Pillowz
//
//  Created by Samat on 13.02.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class TotalPaymentView: UIView {
    let totalPaymentTextLabel = UILabel()
    let totalPaymentValueLabel = UILabel()

    var payment:Int = 0 {
        didSet {
            totalPaymentValueLabel.text = String(payment) + "₸"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hexString: "#F2F2F2")
        
        self.addSubview(totalPaymentTextLabel)
        totalPaymentTextLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset*2)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(15)
        }
        totalPaymentTextLabel.textColor = Constants.paletteBlackColor
        totalPaymentTextLabel.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        totalPaymentTextLabel.text = "Итого к оплате"
        totalPaymentTextLabel.textAlignment = .center
        
        self.addSubview(totalPaymentValueLabel)
        totalPaymentValueLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.top.equalTo(totalPaymentTextLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(20)
        }
        totalPaymentValueLabel.textColor = Constants.paletteBlackColor
        totalPaymentValueLabel.font = UIFont.init(name: "OpenSans-Bold", size: 16)!
        totalPaymentValueLabel.textAlignment = .center
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
