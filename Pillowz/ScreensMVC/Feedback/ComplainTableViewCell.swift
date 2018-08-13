//
//  ComplainTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 18.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol ComplainTableViewCellDelegate {
    func complainTapped()
}

class ComplainTableViewCell: UITableViewCell, FillableCellDelegate {
    let complainLabel = UILabel()
    let complainInvisibleButton = UIButton()
    
    var delegate:ComplainTableViewCellDelegate?
    
    func fillWithObject(object: AnyObject) {
        delegate = object as? ComplainTableViewCellDelegate
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(complainLabel)
        complainLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        complainLabel.font = UIFont.init(name: "OpenSans-Regular", size: 15)!
        complainLabel.textColor = Constants.paletteBlackColor
        complainLabel.text = "Пожаловаться на заявку/владельца"
        
        self.accessoryType = .disclosureIndicator
        
        self.contentView.addSubview(complainInvisibleButton)
        complainInvisibleButton.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        complainInvisibleButton.addTarget(self, action: #selector(complainTapped), for: .touchUpInside)
    }
    
    @objc func complainTapped() {
        self.delegate?.complainTapped()
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
