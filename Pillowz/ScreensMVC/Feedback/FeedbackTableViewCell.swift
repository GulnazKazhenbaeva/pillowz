//
//  CompliantTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 22.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class FeedbackTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteBlackColor
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 16)!
        label.clipsToBounds = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteLightGrayColor
        label.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteVioletColor
        label.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteLightGrayColor
        label.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        label.textAlignment = .right
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = Constants.paletteVioletColor
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        return label
    }()
    
    var feedback: Feedback! {
        didSet {
            titleLabel.text = Feedback.getDisplayNameForHeaderType(headerType: feedback.header)["ru"]!
            descriptionLabel.text = feedback.message
            descriptionLabel.adjustsFontSizeToFitWidth = true
            
            var statusString = ""
            if (feedback.status == FeedbackStatus.ANSWERED) {
                statusString = "Есть ответ"
            } else if (feedback.status == FeedbackStatus.CLOSED) {
                statusString = "Закрыто"
            } else if (feedback.status == FeedbackStatus.OPEN) {
                statusString = "Открыто"
            }
                
            statusLabel.text = "Статус: " + statusString
            switch statusString {
            case "Есть ответ":
                statusLabel.textColor = Constants.paletteVioletColor
            case "Закрыто":
                statusLabel.textColor = Constants.paletteLightGrayColor
            case "Открыто":
                statusLabel.textColor = Constants.paletteVioletColor
            default:
                statusLabel.textColor = Constants.paletteLightGrayColor
            }
            
            let date = Date(timeIntervalSince1970: Double(feedback.time))
            
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

            countLabel.text = String(feedback.messages_count)
            if (feedback.messages_count == 0) {
                countLabel.isHidden = true
            } else {
                countLabel.isHidden = false
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-80)
            make.height.equalTo(16)
        }
        self.contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(16)
        }
        self.contentView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(16)
        }
        self.contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(titleLabel)
        }
        self.contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.bottom.equalToSuperview().offset(-10)
            make.width.height.equalTo(20)
        }
        
        self.selectionStyle = .none
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
