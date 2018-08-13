//
//  OpenRequestOfferTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 18.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol OpenRequestOfferTableViewCellDelegate {
    func offerTapped()
    func hideTapped()
}

class OpenRequestOfferTableViewCell: UITableViewCell {
    let offerButton = UIButton()
    let hideButton = UIButton()
    
    var delegate:OpenRequestOfferTableViewCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(offerButton)
        offerButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.bottom.equalToSuperview().offset(-20)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        offerButton.backgroundColor = Constants.paletteVioletColor
        offerButton.layer.cornerRadius = 10
        offerButton.setTitle("Предложить", for: .normal)
        offerButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        offerButton.addTarget(self, action: #selector(offerTapped), for: .touchUpInside)
        offerButton.addCenterImage(#imageLiteral(resourceName: "offerSpace"), color: .white)

        self.contentView.addSubview(hideButton)
        hideButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.bottom.equalToSuperview().offset(-20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        hideButton.backgroundColor = .clear
        hideButton.layer.cornerRadius = 10
        hideButton.layer.borderWidth = 1
        hideButton.layer.borderColor = Constants.paletteVioletColor.cgColor
        hideButton.setImage(#imageLiteral(resourceName: "hide"), for: .normal)
        hideButton.setTitle("Скрыть", for: .normal)
        hideButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        hideButton.setTitleColor(.white, for: .normal)
        hideButton.addTarget(self, action: #selector(hideTapped), for: .touchUpInside)
        hideButton.addCenterImage(#imageLiteral(resourceName: "hide"), color: Constants.paletteVioletColor)
    }
    
    @objc func offerTapped() {
        self.delegate?.offerTapped()
    }
    
    @objc func hideTapped() {
        self.delegate?.hideTapped()
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
