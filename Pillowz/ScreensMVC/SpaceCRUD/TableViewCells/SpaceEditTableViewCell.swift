//
//  SpaceEditTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 03.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SDWebImage

protocol SpaceAvailabilityDelegate {
    func addAvailabilityForSpace(_ space:Space)
}

class SpaceEditTableViewCell: UITableViewCell {
    let dateLabel = UILabel()
    let statusLabel = UILabel()
    let nameLabel = UILabel()
    let fieldsLabel = UILabel()
    let rentTypePriceLabel = UILabel()
    let addressLabel = UILabel()
    let numberOfViewsLabel = UILabel()
    let spaceImageView = UIImageView()
    
    let addAvailabilityButton = UIButton()
    
    var displayMode:RealtorSpacesDisplayMode = .CRUD
    var delegate:SpaceOfferDelegate?
    var availabilityDelegate:SpaceAvailabilityDelegate?
    
    let rateView = RateView()
    let reviewDetailLabel = UILabel()

    var space:Space! {
        didSet {
            if (space.review == nil) {
                self.rateView.setStars(stars: 0)
            } else {
                self.rateView.setStars(stars: space.review!)
            }
            
            self.reviewDetailLabel.text = String(space.reviews!.count) + " отзывов"
            
            statusLabel.font = UIFont(name: "OpenSans-Bold", size: 10)
            
            if (space.status == .DRAFT) {
                statusLabel.text = "Черновик"
                statusLabel.textColor = Constants.paletteLightGrayColor
            } else if (space.status == .VISUAL) {
                statusLabel.text = "Опубликован"
                statusLabel.textColor = UIColor(hexString: "#B1E37F")
            } else if (space.status == .BLOCKED) {
                statusLabel.text = "Заблокирован"
                statusLabel.textColor = UIColor(hexString: "#FA3C3C")
            } else if (space.status == .ARCHIVED) {
                statusLabel.text = "В архиве"
                statusLabel.textColor = Constants.paletteLightGrayColor
            } else if (space.status == .MODERATION) {
                statusLabel.text = "На модерации"
                statusLabel.textColor = UIColor(hexString: "#FA3C3C")
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            dateFormatter.locale = Locale(identifier: "ru_RU")
            
            dateLabel.text = dateFormatter.string(from: Date())
            
            if (space.name != "") {
                nameLabel.text = space.name
            } else {
                nameLabel.text = "Название не указано"
            }
            
            let fieldsText = space.open_name
            fieldsLabel.text = fieldsText
            
            rentTypePriceLabel.text = space.getPricesText()

            if (space.address != "") {
                addressLabel.text = space.address
            } else {
                addressLabel.text = "Адрес не указан"
            }
            numberOfViewsLabel.text = "Просмотров: " + String(space.view_count!)
            
            if (space.images!.count != 0) {
                spaceImageView.sd_setImage(with: URL(string: space.images![0].image!), placeholderImage: UIImage())
            } else {
                spaceImageView.image = nil
            }
        }
    }
    
    var request:Request! {
        didSet {

        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        spaceImageView.contentMode = .scaleAspectFill
        spaceImageView.backgroundColor = Constants.paletteLightGrayColor
        spaceImageView.clipsToBounds = true
        spaceImageView.layer.masksToBounds = true
        spaceImageView.layer.cornerRadius = 2
        contentView.addSubview(spaceImageView)
        spaceImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(41)
            make.width.equalTo(76)
            make.height.equalTo(76)
            make.left.equalToSuperview().offset(Constants.basicOffset)
        }
        
        self.contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(15)
            make.width.equalTo(Constants.screenFrame.size.width/2-2*Constants.basicOffset)
        }
        dateLabel.textAlignment = .right
        dateLabel.setLightGrayStyle()

        self.contentView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(15)
            make.right.equalTo(dateLabel.snp.left).offset(-10)
        }
        statusLabel.setLightGrayStyle()

        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(statusLabel.snp.bottom).offset(5)
            make.height.equalTo(16)
            make.left.equalTo(spaceImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        nameLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 16)!
        nameLabel.textColor = Constants.paletteBlackColor

        self.contentView.addSubview(fieldsLabel)
        fieldsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.height.equalTo(16)
            make.left.equalTo(spaceImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        fieldsLabel.textColor = Constants.paletteBlackColor
        fieldsLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 11)!
        fieldsLabel.clipsToBounds = false
        
        self.contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fieldsLabel.snp.bottom).offset(5)
            make.height.equalTo(16)
            make.left.equalTo(spaceImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        addressLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        addressLabel.textColor = Constants.paletteLightGrayColor
        contentView.addSubview(addressLabel)

        self.contentView.addSubview(numberOfViewsLabel)
        numberOfViewsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.height.equalTo(16)
            make.right.equalTo(spaceImageView.snp.left).offset(-8)
        }
        numberOfViewsLabel.setLightGrayStyle()
        
        addAvailabilityButton.setImage(#imageLiteral(resourceName: "verticalDots"), for: .normal)
        addAvailabilityButton.imageView?.contentMode = .center
        contentView.addSubview(addAvailabilityButton)
        addAvailabilityButton.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(0)
            make.right.equalToSuperview().offset(0)
            make.width.equalTo(3+Constants.basicOffset*2)
            make.height.equalTo(32)
        }
        addAvailabilityButton.addTarget(self, action: #selector(addAvailabilityTapped), for: .touchUpInside)
        
        contentView.addSubview(rateView)
        rateView.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom)
            make.height.equalTo(20)
            make.width.equalTo(58)
            make.left.equalTo(spaceImageView.snp.right).offset(9)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        reviewDetailLabel.textColor = UIColor.init(hexString: "#5263FF")
        reviewDetailLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        contentView.addSubview(reviewDetailLabel)
        reviewDetailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(rateView.snp.right).offset(9)
            make.height.equalTo(18)
            make.width.equalTo(64)
            make.centerY.equalTo(rateView)
        }
        
        self.selectionStyle = .none
    }
    
    @objc func addAvailabilityTapped() {
        self.availabilityDelegate?.addAvailabilityForSpace(space)
    }
    
    required init(coder aDecoder: NSCoder)
    {
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
