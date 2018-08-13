//
//  ButtonActionTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 01.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

protocol ButtonActionCellDelegate {
    func actionButtonTapped()
}

class ButtonActionTableViewCell: UITableViewCell {
    let button = PillowzButton()
    var delegate:ButtonActionCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(button)
        PillowzButton.makeBasicButtonConstraints(button: button, pinToTop: true)
        button.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
        }
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }
    
    @objc func actionTapped() {
        self.delegate?.actionButtonTapped()
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
