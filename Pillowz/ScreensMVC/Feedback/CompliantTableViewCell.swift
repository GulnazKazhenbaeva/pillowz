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
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = DesignHelpers.currentMainColor()
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.init(hex: "828282")
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = "Статус: "
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.init(hex: "F20D70")
        return label
    }()
    
    let countView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(hex: "F20D70")
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    let view = UIView()
    
    var compliant: Feedback! {
        didSet {
            titleLabel.text = compliant.reasonType
            descriptionLabel.text = compliant.compliantDescription
            descriptionLabel.adjustsFontSizeToFitWidth = true
            statusLabel.text = statusLabel.text! + compliant.status
            switch compliant.status {
            case "Есть ответ":
                statusLabel.textColor = UIColor.init(hex: "26AD61")
            case "Закрыто":
                statusLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            case "Открыто":
                statusLabel.textColor = UIColor.init(hex: "F20D70")
            default:
                statusLabel.textColor = UIColor.black
            }
            timeLabel.text = compliant.time
            if compliant.messageCount == "0" {
                countView.isHidden = true
            } else {
                countLabel.text = compliant.messageCount
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(view)
        view.backgroundColor = .white
        view.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(10)
            make.height.equalTo(18)
        }
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(titleLabel)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.left.equalTo(descriptionLabel)
            make.bottom.equalToSuperview().offset(-10)
        }
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(titleLabel)
        }
        view.addSubview(countView)
        countView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-5)
            make.width.height.equalTo(30)
        }
        countView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
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
