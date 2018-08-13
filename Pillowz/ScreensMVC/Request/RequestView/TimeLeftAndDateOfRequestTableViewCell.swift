//
//  TimeLeftAndDateOfRequestTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 30.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class TimeLeftAndDateOfRequestTableViewCell: UITableViewCell {
    let dateLabel = UILabel()
    let leftTimeLabel = UILabel()

    var request:Request! {
        didSet {
            leftTimeLabel.text = request.getRequestActiveTimeLeftText()
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "dd MMM"
            
            dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(request.timestamp!)))
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(14)
            make.width.equalTo(Constants.screenFrame.size.width/2-2*Constants.basicOffset)
        }
        dateLabel.textAlignment = .right
        dateLabel.setLightGrayStyle()
        
        self.contentView.addSubview(leftTimeLabel)
        leftTimeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(17)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(14)
            make.right.equalTo(dateLabel.snp.left).offset(-10)
        }
        leftTimeLabel.setLightGrayStyle()
    }
    
    required init(coder aDecoder: NSCoder){
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
