//
//  NotificationTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 05.03.18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    var bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hexString: "828282")
        label.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteVioletColor
        label.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    var topicLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "OpenSans-Bold", size: 14)!
        label.textColor = Constants.paletteVioletColor
        label.numberOfLines = 1
        return label
    }()

    var data: PillowzNotification! {
        didSet {
            bodyLabel.text = data.contents
            
            if let _ = data.data["offer_id"] as? Int {
                topicLabel.text = "Посмотреть предложение"
            } else if let _ = data.data["request_id"] as? Int {
                topicLabel.text = "Открыть заявку"
            } else if let _ = data.data["chat_room"] as? String {
                topicLabel.text = "Открыть переписку"
            }
            
            let height = bodyLabel.text!.height(withConstrainedWidth: Constants.screenFrame.size.width - 2*Constants.basicOffset, font: bodyLabel.font)
            
            bodyLabel.snp.updateConstraints { (make) in
                make.height.equalTo(height+10)
            }
            
            let date = Date(timeIntervalSince1970: Double(data.timestamp))
            
            let dayDateFormatter = DateFormatter()
            dayDateFormatter.dateFormat = "dd MMM"
            dayDateFormatter.locale = Locale(identifier: "ru_RU")
            
            let timeDateFormatter = DateFormatter()
            timeDateFormatter.dateFormat = "HH:mm"
            timeDateFormatter.locale = Locale(identifier: "ru_RU")
            
            let dayString = dayDateFormatter.string(from: date)
            let timeString = timeDateFormatter.string(from: date)
            
            var dateText:String
            
            if dayString == dayDateFormatter.string(from: Date()) {
                dateText = timeString
            } else {
                dateText = dayString
            }
            
            timeLabel.text = dateText
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = .white
        
        addSubview(bodyLabel)
        bodyLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(35)
        }
        
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(50)
            make.height.equalTo(21)
        }
        
        addSubview(topicLabel)
        topicLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeLabel.snp.centerY)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalTo(timeLabel.snp.left)
            make.height.equalTo(21)
        }
    }
}
