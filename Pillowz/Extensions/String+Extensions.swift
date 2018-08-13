//
//  String+Extensions.swift
//  Pillowz
//
//  Created by Kazhenbayeva Gulnaz on 8/12/18.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

// Attributed
extension String {
    
    func attributed(font: UIFont = UIFont.OpenSans.regular(), color: UIColor = UIColor.black) -> NSAttributedString {
        let attr: [NSAttributedStringKey:Any] = [NSAttributedStringKey.font: font,
                                                 NSAttributedStringKey.foregroundColor: color]
        return NSAttributedString.init(string: self, attributes: attr)
    }
    
    
}
