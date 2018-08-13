//
//  SpaceArrivalTimeTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 02.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class SpaceArrivalDepartureTimeTableViewCell: UITableViewCell {
    
    let arrivalTimeTitleLabel : UILabel = {
        let label = UILabel()
        label.text = "Время заезда"
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = Constants.paletteBlackColor
        return label
    }()
    let arrivalTimeValueLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .right
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    var space:Space! {
        didSet {
            arrivalTimeValueLabel.text = "после 12:00"
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let space: CGFloat = Constants.basicOffset
        
        self.addSubview(arrivalTimeTitleLabel)
        arrivalTimeTitleLabel.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(space)
            make.bottom.equalToSuperview().offset(-space)
        }
        
        self.addSubview(arrivalTimeValueLabel)
        arrivalTimeValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(arrivalTimeTitleLabel)
            make.trailing.equalToSuperview().offset(-space)
        }
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
