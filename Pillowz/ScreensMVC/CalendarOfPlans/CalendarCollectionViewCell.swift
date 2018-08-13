//
//  CalendarCollectionViewCell.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 14.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = Constants.paletteBlackColor
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 13)!
        label.clipsToBounds = false
        label.minimumScaleFactor = 0.5
        
        return label
    }()
    
    let spaceImageView = UIImageView()

    var space:Space! {
        didSet {
            label.attributedText = NSAttributedString(string: space.name, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            label.textColor = Constants.paletteVioletColor
            
            if (label.text == "") {
                label.text = "Название объекта отсутствует"
            }
            
            if (space.images!.count != 0) {
                spaceImageView.sd_setImage(with: URL(string: space.images![0].image!), placeholderImage: UIImage())
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        self.contentView.addSubview(spaceImageView)
        spaceImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
        spaceImageView.contentMode = .scaleAspectFill
        spaceImageView.backgroundColor = .lightGray
        spaceImageView.clipsToBounds = true
        spaceImageView.layer.masksToBounds = true
        spaceImageView.layer.cornerRadius = 5
        
        self.contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(0)
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
