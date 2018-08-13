//
//  ButtonActionTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 01.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol ExpandActionTableViewCellDelegate {
    func expandButtonTapped()
}

class ExpandActionTableViewCell: UITableViewCell {
    let button = UIButton()
    var delegate:ExpandActionTableViewCellDelegate?
    var isExpanded = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(0)
        }
        button.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        button.setTitle("Расширенный поиск", for: .normal)
        button.setTitleColor(Constants.paletteVioletColor, for: .normal)
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }
    
    @objc func actionTapped() {
        isExpanded = !isExpanded

        if (!isExpanded) {
            button.setTitle("Расширенный поиск", for: .normal)
        } else {
            button.setTitle("Краткий фильтр", for: .normal)
        }        
        
        self.delegate?.expandButtonTapped()
    }
    
    required init(coder aDecoder: NSCoder)
    {
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

