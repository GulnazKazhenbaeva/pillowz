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
            
            if (space.images!.count != 0) {
                spaceImageView.sd_setImage(with: URL(string: space.images![0].image!), placeholderImage: UIImage())
            }
        }
    }
    
    var delegate:SpaceOfferDelegate?
    
    var request:Request! {
        didSet {
            let calculatedPrice = space.calculateTotalPriceFor(request.rent_type!, startTimestamp: request.start_time!, endTimestamp: request.end_time!)
            space.offerPrice = calculatedPrice
            
            if (space.offerPrice == 0) {
                space.offerPrice = request.price!
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
            make.bottom.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(spaceImageView.snp.top)
            make.left.equalTo(spaceImageView.snp.right).offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(15)
        }
        nameLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 15)
        
        self.contentView.addSubview(newPricePickerView)
        newPricePickerView.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.width.equalTo(141)
            make.height.equalTo(27)
        }
        
        offerButton.addTarget(self, action: #selector(offerButtonTapped), for: .touchUpInside)
        offerButton.backgroundColor = UIColor.init(hexString: "EBEFF2")
        offerButton.setTitle("предложить", for: .normal)
        offerButton.setTitleColor(UIColor.init(hexString: "#5263FF"), for: .normal)
        offerButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)
        offerButton.layer.cornerRadius = 27/2
        offerButton.clipsToBounds = true
        contentView.addSubview(offerButton)
        offerButton.snp.makeConstraints { (make) in
            make.top.equalTo(newPricePickerView.snp.bottom).offset(10)
            make.left.equalTo(newPricePickerView.snp.left)
            make.width.equalTo(87)
            make.height.equalTo(27)
        }
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
