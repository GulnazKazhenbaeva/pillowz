//
//  SpaceEmploymentCalendarTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 02.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class SpaceEmploymentCalendarTableViewCell: UITableViewCell {

    let employmentCalendarTitleLabel : UILabel = {
        let label = UILabel()
        label.text = "Календарь занятости"
        label.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        return label
    }()
    let employmentCalendarValueLabel : UILabel = {
        let label = UILabel()
        label.text = "Проверить"
        label.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        label.textColor = Constants.paletteVioletColor
        label.isUserInteractionEnabled = true
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let space: CGFloat = Constants.basicOffset
        
        self.addSubview(employmentCalendarTitleLabel)
        employmentCalendarTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(space)
            make.height.equalTo(20)
        }
        employmentCalendarTitleLabel.clipsToBounds = false
        
        self.addSubview(employmentCalendarValueLabel)
        employmentCalendarValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(employmentCalendarTitleLabel)
            make.trailing.equalToSuperview().offset(-space)
            make.height.equalTo(20)
        }
        employmentCalendarValueLabel.clipsToBounds = false
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


}
