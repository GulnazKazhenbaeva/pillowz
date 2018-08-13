//
//  RequestSpaceInfoTableViewCell.swift
//  Pillowz
//
//  Created by Samat on 10.03.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

protocol RequestSpaceInfoTableViewCellDelegate {
    func openSpaceTapped()
}

class RequestSpaceInfoTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let lookButton = UIButton()
    let subtitleLabel = UILabel()
    let fieldsLabel = UILabel()
    let addressLabel = UILabel()
    
    var delegate: RequestSpaceInfoTableViewCellDelegate?
    
    var shouldShowLookButton: Bool! {
        didSet {
            setupViews()
        }
    }
    
    var title:String! {
        didSet {
            titleLabel.text = title
            
            if let height = self.titleLabel.text?.height(withConstrainedWidth: Constants.screenFrame.size.width - 2*Constants.basicOffset - 87 - 26, font: self.titleLabel.font) {
                titleLabel.snp.updateConstraints { (make) in
                    make.height.equalTo(height + 4)
                }
            }
        }
    }
    
    func setupViews() {
        lookButton.addTarget(self, action: #selector(lookButtonTapped), for: .touchUpInside)
        lookButton.backgroundColor = UIColor.init(hexString: "EBEFF2")
        lookButton.setTitle("посмотреть", for: .normal)
        lookButton.setTitleColor(UIColor.init(hexString: "#5263FF"), for: .normal)
        lookButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)
        lookButton.layer.cornerRadius = 27/2
        lookButton.clipsToBounds = true
        contentView.addSubview(lookButton)
        lookButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.width.equalTo(87)
            make.height.equalTo(27)
        }
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.init(name: "OpenSans-Bold", size: 17)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            if shouldShowLookButton {
                make.top.equalToSuperview().offset(20)
                make.right.equalTo(lookButton.snp.left).offset(-26)
                make.height.equalTo(69)
            } else {
                make.top.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-Constants.basicOffset)
                make.height.equalTo(36)
            }
            make.left.equalToSuperview().offset(Constants.basicOffset)
        }
        subtitleLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 13)
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        
        self.contentView.addSubview(fieldsLabel)
        fieldsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(5)
            make.height.equalTo(16)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
        }
        fieldsLabel.textColor = Constants.paletteBlackColor
        fieldsLabel.font = UIFont.init(name: "OpenSans-SemiBold", size: 11)!
        fieldsLabel.clipsToBounds = false
        
        self.contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fieldsLabel.snp.bottom).offset(5)
            make.height.equalTo(16)
            make.left.equalToSuperview().offset(Constants.basicOffset)
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.bottom.equalToSuperview().offset(-20)
        }
        addressLabel.font = UIFont.init(name: "OpenSans-Regular", size: 13)!
        addressLabel.textColor = Constants.paletteLightGrayColor
        contentView.addSubview(addressLabel)
    }
    
    @objc func lookButtonTapped() {
        delegate?.openSpaceTapped()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
