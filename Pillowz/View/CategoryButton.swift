//
//  RoundedTitledButton.swift
//  Pillowz
//
//  Created by Kazhenbayeva Gulnaz on 8/12/18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class CategoryButton: UIButton {

   static let imageSize: CGFloat = 40
    
    convenience init(category: CategoryType) {
        self.init(frame: CGRect.zero)
        
        setTitle(category.title, for: .normal)
        
        setAttributedTitle(category.title.attributed(font: UIFont.OpenSans.regular(size: 12), color: .pillowBlueDisabled), for: .normal)
        setAttributedTitle(category.title.attributed(font: UIFont.OpenSans.regular(size: 12), color: .black), for: .selected)
        setImage(category.icon, for: .normal)
       
        imageView?.tintColor = .white
        imageView?.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "gradient_rounded"))
        
        titleEdgeInsets = UIEdgeInsetsMake((CategoryButton.imageSize+10), -CategoryButton.imageSize, 0, 0);
        
        let titleSize = self.titleLabel!.bounds.size;
        imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height+10), 0, 0, -titleSize.width);
    }
    
    public func setSelected(_ selected: Bool = true) {
        isSelected = selected
    }
    
    public func setDisabled(_ disabled: Bool = true) {
        isUserInteractionEnabled = !disabled
        let color: UIColor = disabled ? .pillowGrayDisabled : .pillowBlueDisabled
        setTitleColor(color, for: .normal)
    }

}
