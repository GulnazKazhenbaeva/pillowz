//
//  SpaceView.swift
//  Pillowz
//
//  Created by Samat on 12.12.2017.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class SpaceView: UIView {

    let pictureSliderView = PictureSlider()
    
    let infoView = UIView()
    
    let createDateLabel = UILabel()
    let fieldsLabel = UILabel()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let distanceLabel = UILabel()
    
    let starView = RateView()

    let distanceImageView = UIImageView()
    
    
    var isHorizontalCollectionView = false {
        didSet {
            pictureSliderView.isHorizontalCollectionView = isHorizontalCollectionView
        }
    }
    
    var space:Space! {
        didSet {
            if (space.review == nil) {
                starView.setStars(stars: 0)
            } else {
                starView.setStars(stars: space.review!)
            }            
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "dd MMM"
            
            createDateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(space.published_date!)))
            
            let fieldsText = space.open_name!//Field.getShortFieldsDescriptionText(fields: space.fields)
            fieldsLabel.text = fieldsText
            nameLabel.text = space.name
            
            let nameHeight = space.name.height(withConstrainedWidth: Constants.screenFrame.size.width-2*Constants.basicOffset, font: nameLabel.font)
            nameLabel.snp.updateConstraints { (make) in
                make.height.equalTo(nameHeight+4)
            }
            
            addressLabel.text = space.address
            distanceLabel.text = space.getStringDistanceToCurrentUserLocation()
            
            pictureSliderView.space = space
            
            infoView.snp.updateConstraints { (make) in
                make.height.equalTo(nameHeight + 75)
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(pictureSliderView)
        pictureSliderView.backgroundColor = .clear
        pictureSliderView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.spaceImageHeight)
        }
        
        pictureSliderView.addSubview(createDateLabel)
        createDateLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        createDateLabel.snp.makeConstraints { (make) in
            make.height.equalTo(28)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(70)
        }
        createDateLabel.textColor = .white
        createDateLabel.clipsToBounds = true
        createDateLabel.textAlignment = .left
        
        self.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.top.equalTo(pictureSliderView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(90)
        }
        
        infoView.addSubview(nameLabel)
        nameLabel.font = UIFont.init(name: "OpenSans-Bold", size: 17)!
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(20)
        }
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        
        infoView.addSubview(fieldsLabel)
        fieldsLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        fieldsLabel.textColor = Constants.paletteBlackColor
        fieldsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.height.equalTo(15)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        infoView.addSubview(addressLabel)
        addressLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        addressLabel.textColor = Constants.paletteBlackColor
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fieldsLabel.snp.bottom).offset(2)
            make.height.equalTo(15)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        infoView.addSubview(starView)
        starView.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(68)
            make.height.equalTo(12)
        }
        
        infoView.addSubview(distanceImageView)
        distanceImageView.image = #imageLiteral(resourceName: "smallPin")
        distanceImageView.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
            make.width.equalTo(8)
            make.left.equalToSuperview().offset(Constants.basicOffset)
        }
        distanceImageView.contentMode = .center
        
        infoView.addSubview(distanceLabel)
        distanceLabel.font = UIFont.init(name: "OpenSans-Regular", size: 12)!
        distanceLabel.textColor = Constants.paletteLightGrayColor
        distanceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(distanceImageView.snp.centerY)
            make.height.equalTo(15)
            make.left.equalTo(distanceImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
