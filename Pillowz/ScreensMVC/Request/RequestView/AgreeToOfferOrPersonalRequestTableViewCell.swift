//
//  AgreeToOfferTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 27.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol AgreeToOfferTableViewCellDelegate {
    func agreeTapped()
}

class AgreeToOfferOrPersonalRequestTableViewCell: UITableViewCell {
    let agreeButton = UIButton()

    var delegate:AgreeToOfferTableViewCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        agreeButton.backgroundColor = Constants.paletteVioletColor
        agreeButton.layer.cornerRadius = 10
        agreeButton.setTitle("Согласиться", for: .normal)
        agreeButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        agreeButton.addCenterImage(#imageLiteral(resourceName: "agree"), color: .white)
    }
    
    @objc func agreeTapped() {
        self.delegate?.agreeTapped()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
