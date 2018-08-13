//
//  SortingViewCollectionViewCell.swift
//  Pillowz
//
//  Created by Samat on 09.02.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SortingViewCollectionViewCell: UICollectionViewCell {
    let sortTypeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        
        self.contentView.addSubview(sortTypeLabel)
        sortTypeLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(8)
            make.bottom.right.equalToSuperview().offset(-8)
        }
        sortTypeLabel.layer.borderWidth = 1
        sortTypeLabel.layer.cornerRadius = 8
        sortTypeLabel.textAlignment = .center
        sortTypeLabel.font = UIFont.init(name: "OpenSans-Regular", size: 11)!
        sortTypeLabel.textColor = Constants.paletteBlackColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
