//
//  SpaceTitleTableViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 02.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class SpaceTitleTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.init(name: "OpenSans-Bold", size: 20)!
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteLightGrayColor
        label.font = UIFont.init(name: "OpenSans-Light", size: 12)!
        return label
    }()
    let viewNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteLightGrayColor
        label.font = UIFont.init(name: "OpenSans-Light", size: 12)!
        return label
    }()
    let idLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.paletteLightGrayColor
        label.font = UIFont.init(name: "OpenSans-Light", size: 12)!
        return label
    }()
    
    var space:Space! {
        didSet {
            titleLabel.text = space.name
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "dd MMMM yyyy"
            
            dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(space.published_date!)))
            viewNumberLabel.text = "Просмотров: " + String(space.view_count!)
            
            idLabel.text = "ID: " + String(space.space_id.intValue)
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let space: CGFloat = Constants.basicOffset
        
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(space)
            make.top.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-space)
            make.height.equalTo(56)
        }
        
        self.contentView.addSubview(idLabel)
        idLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(titleLabel)
            make.height.equalTo(20)
        }
    
        self.contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(idLabel.snp.bottom).offset(0)
            make.left.equalTo(titleLabel)
            make.height.equalTo(20)
        }
        
        self.contentView.addSubview(viewNumberLabel)
        viewNumberLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(dateLabel)
            make.right.equalToSuperview().offset(-space)
            make.height.equalTo(dateLabel)
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
