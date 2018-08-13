//
//  SpaceArrivalTimeTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 02.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

enum ArrivalDepartureType {
    case arrival
    case departure
}

class SpaceArrivalDepartureTimeTableViewCell: UITableViewCell {
    let arrivalTimeTitleLabel : UILabel = {
        let label = UILabel()
        label.text = "Заезд"
        label.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        label.textColor = Constants.paletteBlackColor
        return label
    }()
    let arrivalTimeValueLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-Light", size: 14)!
        label.textAlignment = .right
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()
    
    var type:ArrivalDepartureType!

    var space:Space! {
        didSet {
            if (type == .arrival) {
                arrivalTimeTitleLabel.text = "Заезд"
            } else {
                arrivalTimeTitleLabel.text = "Выезд"
            }

            if (space.arrival_time == 0 && space.checkout_time == 0) {
                arrivalTimeValueLabel.text = "не указано"
                return
            }

            if (type == .arrival) {
                arrivalTimeValueLabel.text = "после " + String(space.arrival_time) + ":00"
            } else {
                arrivalTimeValueLabel.text = "до " + String(space.checkout_time) + ":00"
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let space: CGFloat = Constants.basicOffset
        
        self.addSubview(arrivalTimeTitleLabel)
        arrivalTimeTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(space)
            make.centerY.equalToSuperview()
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
