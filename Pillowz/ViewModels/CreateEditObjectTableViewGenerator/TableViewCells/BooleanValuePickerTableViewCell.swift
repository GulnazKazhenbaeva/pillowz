//
//  BooleanValuePickerTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 24.10.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit
import SnapKit
import BEMCheckBox

class BooleanValuePickerTableViewCell: HeaderIncludedTableViewCell, EditableCellDelegate {
    let nameLabel = UILabel()
    let valuePickerSwitch = BEMCheckBox()
    let iconImageView = UIImageView()
    let notAllowedIconImageView = UIImageView()
    var didPickValueClosure:DidPickFieldValueClosure!
    var initialValue:Bool? {
        set {
            valuePickerSwitch.setOn(newValue!, animated: false)
        }
        get {
            return valuePickerSwitch.on
        }
    }
    var placeholder:String {
        set {
            nameLabel.text = newValue
            recalculateHeightForNameLabel()
        }
        get {
            return nameLabel.text!
        }
    }
    var icon:String? {
        didSet {
            if (icon != nil) {
                if (self.verifyUrl(urlString: icon)) {
                    notAllowedIconImageView.isHidden = true

                    iconImageView.sd_setImage(with: URL(string: icon!), completed: { (image, error, _, _) in
                        if (error == nil) {
                            let smallerImage = UIImageView.resizeImage(image: image!, targetSize: CGSize(width: 23, height: 23))
                            
                            self.iconImageView.fillImageView(image: smallerImage, color: Constants.paletteLightGrayColor)
                        }
                    })
                } else {
                    iconImageView.fillImageView(image: UIImage(named: icon!)!, color: Constants.paletteLightGrayColor)
                }
                
                nameLabel.snp.updateConstraints({ (make) in
                    make.left.equalToSuperview().offset(Constants.basicOffset + 36 + 16)
                })
                iconImageView.isHidden = false
            } else {
                nameLabel.snp.updateConstraints({ (make) in
                    make.left.equalToSuperview().offset(Constants.basicOffset)
                })
                iconImageView.isHidden = true
            }
        }
    }
    var notAllowed:Bool? {
        didSet {
            if (notAllowed != nil) {
                notAllowedIconImageView.isHidden = notAllowed!
                valuePickerSwitch.isHidden = true
            } else {
                notAllowedIconImageView.isHidden = true                
            }
        }
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func recalculateHeightForNameLabel() {
        let width = Constants.screenFrame.size.width - 90 - Constants.basicOffset
        
        let height = nameLabel.text!.height(withConstrainedWidth: width, font: nameLabel.font)
        nameLabel.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-90)
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(16)
        }
        nameLabel.clipsToBounds = false
        nameLabel.font = UIFont.init(name: "OpenSans-Light", size: 16)!
        nameLabel.numberOfLines = 0
        
        self.contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.width.height.equalTo(36)
        }
        iconImageView.contentMode = .center
        iconImageView.clipsToBounds = true
        
        self.iconImageView.addSubview(notAllowedIconImageView)
        notAllowedIconImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        notAllowedIconImageView.fillImageView(image: #imageLiteral(resourceName: "notAllowed"), color: Constants.paletteLightGrayColor)
        notAllowedIconImageView.isHidden = true
        
        self.contentView.addSubview(valuePickerSwitch)
        valuePickerSwitch.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalTo(nameLabel.snp.centerY)
        }
        valuePickerSwitch.tintColor = Constants.paletteVioletColor
        valuePickerSwitch.onTintColor = Constants.paletteVioletColor
        valuePickerSwitch.onCheckColor = .white
        valuePickerSwitch.onAnimationType = .fill
        valuePickerSwitch.offAnimationType = .fill
        valuePickerSwitch.boxType = .square
        valuePickerSwitch.onFillColor = Constants.paletteVioletColor
        valuePickerSwitch.addTarget(self, action: #selector(didSelectValue(_:)), for: UIControlEvents.valueChanged)
    }
    
    @objc func didSelectValue(_ valuePickerSwitch:BEMCheckBox) {
        didPickValueClosure(valuePickerSwitch.on)
    }
    
    @objc func didSelectValueWithButton(_ button:UIButton) {
        button.isSelected = !button.isSelected
        
        didPickValueClosure(button.isSelected)
    }
    
    func didSetValue(value: String) {
        let newValue = value.toBool()
        
        valuePickerSwitch.setOn(newValue, animated: true)
    }
    
    func didSetCustomText(text: String) {
        self.nameLabel.text = text
        recalculateHeightForNameLabel()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
