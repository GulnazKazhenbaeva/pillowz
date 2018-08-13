//
//  GuideTableViewCell.swift
//  Pillowz
//
//  Created by Mirzhan Gumarov on 10/30/17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit

class GuideTableViewCell: UITableViewCell {
    let guideTextLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(guideTextLabel)
        guideTextLabel.text = "Находите жилье без посредников вместе с Pillowz. Для начала нужно пройти регистрацию. Это займет не больше минуты."
        guideTextLabel.numberOfLines = 3
        guideTextLabel.textAlignment = .center
        guideTextLabel.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
