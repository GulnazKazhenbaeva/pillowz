//
//  AddressPickerTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 11.02.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class AddressPickerTableViewCell: HeaderIncludedTableViewCell {
    let addressPickerView = AddressPickerView()

    var delegate:AddressPickerDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.header = "Где ищете жилье?"
        
        self.contentView.addSubview(addressPickerView)
        addressPickerView.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.width.equalToSuperview().offset(-Constants.basicOffset)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-10)
        }
        addressPickerView.addressTextFieldBottomSeparatorView.isHidden = true
        addressPickerView.saveAddressWithAPIClosure = { (address, lat, lon, placeID) in
            self.delegate?.didPickAddress(address: address, lat: lat!, lon: lon!)
            self.addressPickerView.text = address
        }
    }
    
    override func fillWithObject(object: AnyObject) {
        let dict = object as! Dictionary<String, Any>
        
        if let delegate = dict["delegate"] as? AddressPickerDelegate {
            self.delegate = delegate
        }
        
        self.addressPickerView.text = dict["address"] as! String
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
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
