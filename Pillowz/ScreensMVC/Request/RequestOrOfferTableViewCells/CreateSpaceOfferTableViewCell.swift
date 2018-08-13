//
//  CreateOfferTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 20.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit
import SDWebImage

protocol SpaceOfferDelegate {
    func didOfferSpace(_ space:Space)
}

class CreateSpaceOfferTableViewCell: UITableViewCell {
    let spaceImageView = UIImageView()
    let nameLabel = UILabel()
    let fieldsLabel = UILabel()
    let addressLabel = UILabel()
    let offerButton = UIButton()
    let spaceStatusLabel = UILabel()
    let newPricePickerView = IntValuePickerView(initialValue: 500, step: 500, additionalText: "₸")
    
    var space:Space! {
        didSet {
            if (space.name != "") {
                nameLabel.text = space.name
            } else {
                nameLabel.text = "Название не указано"
            }
            
            let isAvailable = space.offerState == .available
            spaceStatusLabel.isHidden = isAvailable
            offerButton.isHidden = !isAvailable
            
            fieldsLabel.text = space.open_name
            addressLabel.text = space.address
            
            if !isAvailable {
                if space.offerState == .alreadyOffered {
                    spaceStatusLabel.text = "предложен"
                } else if space.offerState == .busy {
                    spaceStatusLabel.text = "занят"
                } else if space.offerState == .notSuitable {
                    spaceStatusLabel.text = "не подходит"
                }
            }
            
            if (space.images!.count != 0) {
                spaceImageView.sd_setImage(with: URL(string: space.images![0].image!), placeholderImage: UIImage())
            }
        }
    }
    
    var delegate:SpaceOfferDelegate?
    
    var request:Request! {
        didSet {
            let calculatedPrice = space.calculateTotalPriceFor(request.rent_type!, startTimestamp: request.start_time!, endTimestamp: request.end_time!)
            
            if request.bargain == true {
                space.offerPrice = calculatedPrice
                self.newPricePickerView.isEnabled = true
            } else {
                space.offerPrice = request.price!
                self.newPricePickerView.isEnabled = false
            }
            
            if (space.offerPrice == 0) {
                space.offerPrice = request.price!
            } else {
                newPricePickerView.maxValue = space.offerPrice
            }
            
            newPricePickerView.value = space.offerPrice
            
            newPricePickerView.didPickValueClosure = { (newValue) in
                let newPrice = newValue as! Int
                self.space.offerPrice = newPrice
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        spaceImageView.layer.cornerRadius = 2
        spaceImageView.contentMode = .scaleAspectFill
        spaceImageView.backgroundColor = .lightGray
        spaceImageView.clipsToBounds = true
        spaceImageView.layer.masksToBounds = true
        contentView.addSubview(spaceImageView)
        spaceImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalTo(80)
            make.height.equalTo(80)
            make.left.equalToSuperview().offset(Constants.basicOffset)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(spaceImageView.snp.top)
            make.left.equalTo(spaceImageView.snp.right).offset(9)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(26)
        }
        nameLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)
        
        
        addressLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        addressLabel.textColor = Constants.paletteLightGrayColor
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(26)
            make.left.equalTo(spaceImageView.snp.right).offset(9)
        }
        
        fieldsLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        fieldsLabel.textColor = Constants.paletteLightGrayColor
        contentView.addSubview(fieldsLabel)
        fieldsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(-4)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(26)
            make.left.equalTo(spaceImageView.snp.right).offset(9)
        }

        
        self.contentView.addSubview(newPricePickerView)
        newPricePickerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.top.equalTo(spaceImageView.snp.bottom).offset(10)
            make.width.equalTo(141)
            make.height.equalTo(27)
        }
        
        offerButton.backgroundColor = Constants.paletteVioletColor
        offerButton.setTitleColor(.white, for: .normal)
        offerButton.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 13)
        offerButton.setTitle("Предложить", for: .normal)
        offerButton.addTarget(self, action: #selector(offerButtonTapped), for: .touchUpInside)
        offerButton.layer.cornerRadius = 3
        contentView.addSubview(offerButton)
        offerButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(newPricePickerView.snp.centerY)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(100)
            make.height.equalTo(27)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        self.contentView.addSubview(spaceStatusLabel)
        spaceStatusLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(offerButton.snp.edges)
        }
        spaceStatusLabel.textAlignment = .center
        spaceStatusLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 10)
        spaceStatusLabel.textColor = Constants.paletteLightGrayColor
    }
    
    @objc func offerButtonTapped() {
        self.delegate?.didOfferSpace(space)
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
