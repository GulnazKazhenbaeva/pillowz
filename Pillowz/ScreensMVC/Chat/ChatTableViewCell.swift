//
//  ChatTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 07.01.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import DateToolsSwift
import FirebaseDatabase

class ChatTableViewCell: UITableViewCell {
    let userImageView = UIImageView()
    let nameLabel = UILabel()
    let spaceDescriptionLabel = UILabel()
    let lastMessageLabel = UILabel()
    let dateLabel = UILabel()
    var numberOfMessagesLabel = UILabel()
    
    var ref: DatabaseReference!
    
    var chat:Chat! {
        didSet {
            nameLabel.text = chat.otherUser.name
            
            spaceDescriptionLabel.text = chat.info
            
            if (chat.otherUser.avatar != nil) {
                userImageView.sd_setImage(with: URL(string: chat.otherUser.avatar!), placeholderImage: UIImage())
            }
            
            let date = Date(timeIntervalSince1970: Double(chat.timestamp))
            
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
            
            dateLabel.text = dateText
            lastMessageLabel.text = chat.last_message.text
            
            numberOfMessagesLabel.isHidden = true
            
            ref = Database.database().reference().child("badges").child(User.shared.user_id!.description).child("chat").child(chat.chat_id)
            
            print(chat.chat_id)
            
            ref.observe(DataEventType.value, with: { (snapshot) in
                let count = snapshot.value as? NSNumber
                // ...
                if (count != nil) {
                     self.numberOfMessagesLabel.text = String(count!.intValue)
                    
                    if (count! == 0) {
                        self.numberOfMessagesLabel.isHidden = true
                    } else {
                        self.numberOfMessagesLabel.isHidden = false
                    }
                }
            })
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.height.equalTo(40)
        }
        userImageView.layer.cornerRadius = 20
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = Constants.paletteLightGrayColor
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
        
        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-80)
            make.height.equalTo(16)
        }
        nameLabel.textColor = Constants.paletteBlackColor
        nameLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 16)!
        
        self.contentView.addSubview(lastMessageLabel)
        lastMessageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(16)
        }
        lastMessageLabel.textColor = Constants.paletteLightGrayColor
        lastMessageLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!

        self.contentView.addSubview(spaceDescriptionLabel)
        spaceDescriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lastMessageLabel.snp.bottom).offset(5)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(16)
        }
        spaceDescriptionLabel.textColor = Constants.paletteVioletColor
        spaceDescriptionLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        
        self.contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(16)
            make.width.equalTo(60)
        }
        dateLabel.textColor = Constants.paletteLightGrayColor
        dateLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        dateLabel.textAlignment = .right

        self.contentView.addSubview(numberOfMessagesLabel)
        numberOfMessagesLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.bottom.equalToSuperview().offset(-10)
            make.width.height.equalTo(20)
        }
        numberOfMessagesLabel.backgroundColor = Constants.paletteVioletColor
        numberOfMessagesLabel.textAlignment = .center
        numberOfMessagesLabel.textColor = .white
        numberOfMessagesLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 12)!
        numberOfMessagesLabel.layer.cornerRadius = 10
        numberOfMessagesLabel.clipsToBounds = true
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
