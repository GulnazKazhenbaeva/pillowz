//
//  RejectRequestOrOfferTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 29.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol RejectRequestOrOfferTableViewCellDelegate {
    func rejectTapped()
}

class RejectRequestOrOfferTableViewCell: UITableViewCell {
    var delegate:RejectRequestOrOfferTableViewCellDelegate?
    
    let rejectButton = UIButton()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(rejectButton)
        rejectButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo((Constants.screenFrame.size.width-2*Constants.basicOffset-10)/3)
            make.height.equalTo(60)
        }
        rejectButton.backgroundColor = .white
        rejectButton.layer.borderWidth = 1
        rejectButton.layer.borderColor = UIColor(hexString: "#F10C6F").cgColor
        rejectButton.layer.cornerRadius = 10
        rejectButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 12)!
        rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)
        rejectButton.setTitleColor(UIColor(hexString: "#F10C6F"), for: .normal)
        rejectButton.setTitle("Отменить", for: .normal)
        rejectButton.addCenterImage(#imageLiteral(resourceName: "reject"), color: UIColor(hexString: "#F10C6F"))
    }
    
    @objc func rejectTapped() {
        self.delegate?.rejectTapped()
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
